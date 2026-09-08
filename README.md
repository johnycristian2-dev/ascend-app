# Ascend (Flutter)

Reconstrução do app a partir do protótipo de interface `Ascend Expedição.dc.html`.
A especificação está em `ESPEC-Flutter.md`, na raiz do projeto de design.

Ambiente: **VSCode** + extensão Flutter oficial. Android Studio ao lado, só pelo
SDK e emulador. Visual Studio não serve para Flutter.

## Rodar

Precisa do Firebase configurado primeiro — veja "Backend (Firebase)" abaixo.
Sem isso o app abre, mas login/cadastro falham com um erro explicando o que falta.

```bash
flutter pub get
flutter test    # cadeia de cálculo + degradação dos recados de bastão
flutter run
```

## Backend (Firebase)

Autenticação e o caderno de expedição (perfil) agora são reais — Firebase
Auth + Firestore. O resto (mochila, janela, bastão, chat, equipamento) segue
com dados de demonstração locais; é a próxima fatia de backend a fazer.

**1. Projeto criado** ✅ — `ascend-ff71d`, na conta johnycristian2@gmail.com.

**2. Ativar login por e-mail/senha** — confirme que está feito:
- No projeto → Build → Authentication → Sign-in method → ative **E-mail/senha**.

**3. Criar o banco Firestore** — confirme que está feito:
- No projeto → Build → Firestore Database → Criar banco de dados → modo de
  produção → escolha uma região (`southamerica-east1` = São Paulo, mais perto).

**4. Publicar as regras de segurança** — confirme que está feito:
- Firestore Database → Regras → cole o conteúdo de `firestore.rules` (na raiz
  deste projeto) → Publicar.

**5. Ligar o app Flutter ao projeto** ✅ — `lib/backend/config/firebase_options.dart`
já tem os valores reais do app Web registrado no console. Funciona para rodar e
testar (`flutter run -d chrome` ou emulador Android/iOS).

Antes de gerar um build de verdade pra loja (APK/IPA assinado), registre um
app Android e um app iOS próprios no console (Configurações → Seus apps) e
rode `flutterfire configure` — isso gera os arquivos nativos
(`google-services.json` / `GoogleService-Info.plist`) que o build de
produção espera. Não é preciso pra desenvolver/testar agora.

**O que persiste hoje:** nome de campo, base/região, unidades, meta de
desnível, nível, rank, desnível acumulado e os quatro atributos — em
`users/{uid}` no Firestore. Cadastro cria o documento na avaliação inicial
(rank de partida definido pelo quiz); login recupera a sessão; "AJUSTES"
grava as edições; "SAIR DA CONTA" desloga de verdade.

## Estrutura

O código é dividido em dois ramos dentro de `lib/`: `backend/` (estado, dados,
persistência — nada de `Widget`) e `frontend/` (tema, widgets e as 20 telas —
nada de Firebase). `lib/main.dart` é só o bootstrap: inicializa o Firebase e
chama `runApp`.

```
lib/
  main.dart                              bootstrap: Firebase + runApp
  backend/
    config/firebase_options.dart         config do Firebase — placeholder, veja "Backend" acima
    state/
      expedition_state.dart              estado global (ChangeNotifier), derivados e ponte com o backend
      expedition_calculator.dart         Dart puro: peso, variantes de rota, day1Min, formatação
    models/
      user_profile_model.dart            o que persiste em users/{uid} no Firestore
      attr_model.dart                    um atributo físico (Resistência, Força…)
    services/
      auth_service.dart                  fina camada sobre o Firebase Auth
      profile_repository.dart            fina camada sobre o Firestore (CRUD do perfil)
    data/
      weather_forecast.dart              blocos de previsão, 4 slots de partida, exigências
      relay_notes.dart                   os 5 recados ancorados
      gear_catalog.dart                  equipamento com odômetro, e carimbos
  frontend/
    app.dart                             AscendApp, Shell (troca de tela) e o InheritedNotifier Expedition
    theme/
      app_colors.dart                    paleta do protótipo
      app_typography.dart                Barlow Condensed (rótulos/números) + Inter (corpo)
    widgets/                             AppLabel, AppPanel, AppButton, AppTextField, ScreenBar,
                                          AppTag, TwoColumnRow, AppProgressBar, AppStat, nav, índice
                                          (import único: widgets/widgets.dart)
    screens/                             as 20 telas (*_screen.dart) + field_screen.dart (modo campo)

firestore.rules                          regras de segurança do Firestore (cole no console)
```

`frontend/` pode importar de `backend/` (uma tela lê o estado), mas nunca o
contrário — nada em `backend/` depende de `Widget`, `BuildContext` ou de
qualquer arquivo dentro de `frontend/`.

## As 20 telas

01 splash · 02 home (mapa) · 03 route · 04 profile · 05 inventory · 06 achievements
· 07 chat · 08 summary · 09 rankup · 10 discover · 11 onboard · 12 party
· 13 history · 14 auth · 15 plan · 16 watch · 17 home vazia · 18 window · 19 relay
· 20 pack. O botão de lista no canto abre o índice e salta para qualquer uma.

A navegação é por estado (`s.go('route')`), como no protótipo — não por
`Navigator`. O mapa `ExpeditionState.depth` decide se a transição entra pela
direita ou volta pela esquerda.

**Modo campo** (`FieldScreen`, `ExpeditionState.fieldMode`) não é uma tela do
fluxo — é uma sobreposição acessível pelo ícone de relevo no topo do mapa,
exatamente como no protótipo (não entra no mapa `depth`). É de lá, não da
tela de leitura em casa, que um recado de bastão nasce: "ANCORAR RECADO"
abre o mesmo composer da tela `relay`, ancorado no ponto onde você está.

## Duas regras que não podem se perder

`packOut` guarda o que **ficou em casa**, referenciado pelo NOME do item. Toda a
propagação de decisão depende disso.

`day1Min` é a **fonte única** de hora de chegada, margem de luz e veredito de
equipamento. Não recalcule em outro lugar — foi o bug que já custou uma rodada.

## O que é fiel e o que é aproximado

Fiéis ao protótipo: paleta, tipografia, todos os números e textos de dados
(gramagens, variantes, slots, recados, equipamento, carimbos) e a cadeia de
cálculo inteira.

Aproximados: o mapa de relevo (silhueta desenhada, no lugar do mapa real), os
ícones (Material em vez dos SVGs desenhados à mão) e o layout fino de algumas
telas secundárias. As telas do circuito de decisão — home, route, window, pack,
relay — são as mais próximas.

## As três pendências (agora implementadas)

- **Bastão em campo**: `FieldScreen` tem um botão "ANCORAR RECADO" que abre o
  mesmo composer da tela `relay`, mas contextualizado no ponto onde você está
  — não mais só na leitura de mesa depois da trilha.
- **Dívida de confirmação**: `ExpeditionState.relayUsed` registra todo recado
  que você abriu (`pickPin`); `relayDebts` são os que ainda não têm voto. A
  tela `summary` mostra um card "DÍVIDA DE CONFIRMAÇÃO" e trava o botão de
  arquivar até você confirmar ou marcar "não achei" em cada um.
- **Recado que apaga**: `RelayNote.fadeOpacity()` calcula uma opacidade
  contínua a partir de `diasDesdeConfirmacao` (não da data de postagem — um
  recado de 1 ano confirmado há 6 dias continua vivo), com piso em .35 aos
  182 dias. Nunca um aviso de texto, só o traço ficando mais claro.
