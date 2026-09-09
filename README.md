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

Autenticação, o caderno de expedição (perfil), o circuito de decisão
(mochila, partida escolhida, votos e dívidas de bastão), o plano de
expedição, a convocação de cordada, o chat e o equipamento agora são
reais — Firebase Auth + Firestore. Só a contagem regressiva da janela
(`wxSec` — um número decrescendo a partir de uma constante, não ancorado
num horário real; persistir isso direito pediria guardar o horário-alvo,
não o segundo atual) continua local.

**Equipamento é o caso especial:** ao contrário do resto, não existia
nenhuma interação que mudasse desgaste/uso — os números do catálogo
(`gear_catalog.dart`) eram só conteúdo estático de demonstração. Adicionei
"REGISTRAR SAÍDA" na tela (`InventoryScreen`), que soma 1 uso, avança o
odômetro e soma 2 pontos de desgaste (`GearUsage.logOuting`, em
`gear_usage_model.dart`) — uma aproximação simples, documentada no código,
não derivada de odômetro/limite porque os dados de demonstração já não
seguiam essa proporção de propósito (cada peça desgasta em ritmo próprio:
a corda por uso intenso, a barraca por sazonalidade). Ajuste a fórmula se
quiser outro ritmo. Uma conta nova começa com equipamento zerado; a conta
que já existia (johnycristian2) mantém os números atuais até a primeira
saída registrada.

**Identidade pública:** o caderno agora tem foto de perfil, plano de fundo,
biografia, redes sociais (Instagram, Strava, YouTube, site pessoal) e um
"sobre você" (praticando desde, trilha dos sonhos, equipamento favorito) —
tudo editável em Ajustes, tudo opcional (campo vazio simplesmente não
aparece no caderno). Foto e capa são **link**, não upload: o app não guarda
arquivo nenhum, só o endereço de uma imagem já hospedada em outro lugar —
sem isso não precisa de Firebase Storage, de pacote de câmera/galeria, nem
de permissão nativa nenhuma. Sem link definido, usa a key art do app como
retrato/fundo padrão (`ProfileAvatar`/`ProfileCover`, em
`lib/frontend/widgets/`). Redes sociais aparecem como chip com ícone e
identificador — não são link clicável ainda; isso pediria o pacote
`url_launcher` e configuração nativa (Android/iOS) que não dá pra testar
sem o SDK aqui.

**1. Projeto criado** ✅ — `ascend-1d51e`, na conta johnycristian2@gmail.com.

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
desnível, nível, rank, desnível acumulado, os quatro atributos, os itens
deixados em casa (mochila), a partida escolhida (janela), os votos/dívidas
de confirmação de bastão, a trilha e data do plano de expedição, quem foi
convocado pra cordada e quem leva cada item coletivo, o histórico do chat,
uso/desgaste de equipamento, e a identidade pública (foto, capa, bio,
redes sociais, sobre você) — tudo em `users/{uid}` no Firestore. Cadastro cria o documento na avaliação
inicial (rank de partida definido pelo quiz, resto zerado — ver
`UserProfile.starter`; a conversa inicial da cordada é a exceção, é cenário
e não decisão, então já vem preenchida); login recupera a sessão inteira,
decisões incluídas; "AJUSTES" grava as edições; "SAIR DA CONTA" desloga de
verdade.

Cada ação de decisão (marcar/desmarcar item da mochila, escolher partida,
votar num recado, convocar alguém, marcar quem leva o quê, escolher trilha/
data, mandar mensagem, registrar saída de equipamento) grava no Firestore
na hora — silencioso, sem travar a navegação se a rede cair (a escrita fica
enfileirada e sincroniza quando voltar). Selecionar um item pra ver detalhe
(recado, recado de bastão em campo, peça de equipamento, carimbo) e o que
ainda está sendo digitado (rascunho de recado/mensagem) são estado de
tela, não decisão — não persistem, e não deveriam.

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
      user_profile_model.dart            o que persiste em users/{uid} no Firestore (perfil + mochila +
                                          janela + bastão + plano + cordada + chat + equip. + identidade pública)
      attr_model.dart                    um atributo físico (Resistência, Força…)
      chat_message_model.dart            uma mensagem da cordada
      gear_usage_model.dart              uso/desgaste registrado de uma peça (GearUsage.logOuting)
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
                                          AppTag, TwoColumnRow, AppProgressBar, AppStat, nav, índice,
                                          ProfileAvatar, ProfileCover (foto/capa do caderno, com
                                          fallback pra key art), KeyArtBackground, KeyArtPortrait
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

## Arte

`assets/art/keyart-limpa.png` (ilustração de personagem) e `emblema-alpha.png`
(marca) são as duas artes do protótipo que o app usa de verdade — as únicas
referenciadas em `Ascend Expedição.dc.html` (`art/keyart.png`, `logo.png` e as
variantes `-frio` ficaram de fora por não estarem em uso ali). `KeyArtBackground`
(`lib/frontend/widgets/`) reproduz o fundo com véu gradiente da abertura, do
acesso e da nova classificação — o "momento de arte" do app, o resto é
instrumento sóbrio. `KeyArtPortrait` reproduz o recorte de rosto usado como
retrato no caderno e nas configurações.

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
