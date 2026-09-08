# Ascend — Especificação de reconstrução (Flutter)

Derivada do protótipo `Ascend Expedição.dc.html`. Tudo aqui já existe funcionando lá — use o protótipo como referência visual e este arquivo como mapa de implementação.

Ambiente: **VSCode** + extensão Flutter oficial. Android Studio instalado ao lado só pelo SDK/emulador. Visual Studio não serve para Flutter.

---

## 1. Tokens

Alvo do canvas: 390 × 844 (iPhone 14).

| uso | hex |
|---|---|
| fundo da tela | `#14161A` |
| superfície / card | `#1A1D21` |
| superfície alternativa | `#191C20` |
| borda | `#2E333A` |
| borda de alerta | `#4A3427` |
| fundo de alerta | `#1D1A18` |
| fundo de sucesso | `#1E2420` |
| texto primário | `#E6E8E5` |
| texto forte / números | `#F2F4F0` |
| texto secundário | `#9DA29E` |
| texto terciário | `#8A8F8B` |
| texto apagado | `#6E736F` |
| acento âmbar (risco, urgência) | `#C2703F` |
| verde (ok, recomendado) | `#7C8A6E` |
| azul (informação, apertado) | `#8FA9C0` |

Tipografia: **Barlow Condensed** para rótulos, títulos e números (peso 500–700, `letter-spacing` de .16em a .24em, quase sempre caixa alta); **Inter** para texto corrido (peso 400, 9–11px). Raio de canto: 4px em tudo. Números sempre com `FontFeature.tabularFigures()`.

```dart
class Ink {
  static const bg = Color(0xFF14161A);
  static const surface = Color(0xFF1A1D21);
  static const border = Color(0xFF2E333A);
  static const amber = Color(0xFFC2703F);
  static const green = Color(0xFF7C8A6E);
  static const blue = Color(0xFF8FA9C0);
  static const text = Color(0xFFE6E8E5);
  static const dim = Color(0xFF6E736F);
}
```

---

## 2. Telas (20) e profundidade de navegação

O protótipo usa um `depth` por tela para escolher a direção da animação (entra pela direita, volta pela esquerda). No Flutter isso vira `PageRouteBuilder` com `SlideTransition` — guarde o mesmo mapa para decidir o sentido.

| depth | telas |
|---|---|
| 0 | `splash`, `auth` |
| 1 | `onboard`, `home`, `chat`, `profile` |
| 2 | `inv`, `ach`, `history`, `settings`, `discover`, `route`, `plan`, `watch`, `relay` |
| 3 | `party`, `summary`, `window` |
| 4 | `rankup`, `pack` |

`splash` roda um boot de 0→100 em passos de 4 a cada 70 ms e cai em `auth`.

Barra inferior: `home` | `chat` | `profile`. Telas de depth ≥2 mantêm a aba raiz destacada (`route`/`discover`/`plan`/`window`/`pack`/`relay` → home; `rankup`/`summary`/`settings`/`history` → profile).

---

## 3. Modelo de estado

Um `ExpeditionState` (Riverpod `Notifier` ou `ChangeNotifier`) concentra tudo. Campos que importam:

```dart
class ExpeditionState {
  String screen;            // tela atual
  int level, elev, elevGoal;// 27, 4360, 6000
  int rankIdx;              // índice em ['E','D','C','B','A','S']
  int wxSec;                // segundos até a janela fechar (133964, decresce 1/s)
  int wxPick;               // 0..3 — partida escolhida
  Set<String> packOut;      // itens DEIXADOS EM CASA
  Map<int,String?> relayVote; // índice do recado -> 'y' | 'n' | null
  int? relaySel;            // pino de bastão selecionado
  List<Attr> attrs;         // Resistência 78, Força 64, Técnica 71, Altitude 62
  TrailState trail;         // seca | lama | neve | gelo
}
```

Regra que não pode se perder: `packOut` guarda o que **ficou em casa**, não o que foi levado. Toda a propagação depende disso.

---

## 4. Os três sistemas e a propagação

Este é o núcleo do app e a parte que mais custa reescrever. As fórmulas abaixo são exatas.

### 4.1 Janela de partida (`window`)

Quatro slots, com metadados que alimentam as outras duas telas:

| i | partida | dorme | exige | mín. noturna | luz |
|---|---|---|---|---|---|
| 0 | QUI 09 · 12:00 | Abrigo 2, chegada após o escuro | saco -5°, fogareiro | -2 °C | 62% |
| 1 | SEX 10 · 05:00 | Abrigo 2, chegada com luz | saco -5° | +1 °C | 96% |
| 2 | SÁB 11 · 04:00 | bivaque na crista 2 240 m | barraca, saco -5°, fogareiro | -6 °C | 48% |
| 3 | TER 14 · 05:00 | Abrigo 2, provavelmente sozinho | saco -5°, barraca, kit | 0 °C | 88% |

Previsão: 12 blocos de 6 h com `q` (0 bom / 1 marginal / 2 ruim), vento, chuva e teto — desenhe como barras coloridas por `qInk = [verde, azul, âmbar]`.

Partida antes do nascer do sol (04:00) mostra aviso de frontal e horas de escuro antes da luz.

### 4.2 Peso da mochila (`pack`)

Base da mochila vazia: **1 350 g**. 14 itens; seis são fixos (água, comida, pluma, kit, frontal, mapa) e não podem sair.

```
peso = 1350 + soma(itens não removidos)
kg   = peso / 1000
ritmo (km/h) = 4.1 - 0.075 * kg
kcal         = 1780 + 132 * kg
```

Limiares: verde até 10,8 kg, azul até 12 kg, **acima de 12 kg** vira alerta âmbar e o veredito muda para "acima do que seu rank sustenta em 2 dias".

### 4.3 Passagem de bastão (`relay`)

Cinco recados ancorados em km da rota, com autor, rank, idade, contagem de confirmações e sinalizador `stale` (>4 meses fica esmaecido a 66% de opacidade e com anel cinza). Voto: "ainda vale" (+1 confirmação) ou "não achei". Ambos alternáveis.

### 4.4 Cadeia de cálculo — implemente nesta ordem

```
base:  28,4 km · +1 640 m · 560 min

variantes disparadas por item deixado em casa:
  CORDA 60 M  -> variante da chaminé:   +0 km,  +180 m, +40 min
  CRAMPONS    -> via normal:            +2,8 km, +0 m,  +35 min
  PIOLET      -> desvio da neve dura:   +1,1 km, +60 m, +20 min

min      = 560 + soma(min das variantes)
walkMin  = round(min * (1 + (kg - 10) * 0,022))     // peso encarece o tempo
condMin  = penalidade da condição da rota (seca/lama/neve/gelo)
day1Min  = round((walkMin + condMin - 560) * 0,56)  // trecho do primeiro dia
chegada  = partida + day1Min
```

**`day1Min` é a fonte única.** Hora de chegada, margem de luz e veredito de equipamento leem daí. Não duplique esse cálculo em três lugares — foi exatamente o bug que a gente já corrigiu uma vez.

Chegada depois das 18:20, ou luz do slot abaixo de 60%, pinta a hora de âmbar.

### 4.5 Conflitos

`conflitos = itens exigidos pela partida ∩ itens deixados em casa`. Aparecem como card de borda âmbar na rota, com rótulo no singular/plural.

### 4.6 Formatação (cuidado)

```dart
String fmtHm(int min);    // 140 -> "2 h 20"  (só use quando min >= 60)
String fmtDelta(int min); // 20 -> "20 min", 140 -> "2 h 20"
```

Deltas **sempre** por `fmtDelta`. Usar `fmtHm` em delta produz "0 h 20". Vale também para as strings de portão de luz.

Números em pt-BR: vírgula decimal, espaço fino como separador de milhar (`1 640 m`).

---

## 5. Estrutura de pastas sugerida

```
lib/
  main.dart
  theme/          ink.dart, type.dart
  state/          expedition_state.dart, calc.dart   <- seção 4 inteira
  data/           wx_slots.dart, pack_items.dart, relay_notes.dart
  screens/        splash, auth, onboard, home, route, discover, plan, party,
                  window, pack, relay, watch, summary, rankup, profile,
                  chat, inv, ach, history, settings
  widgets/        label.dart, stat_card.dart, forecast_bars.dart,
                  weight_bar.dart, relay_pin.dart, bottom_nav.dart
```

`calc.dart` deve ser Dart puro, sem Flutter — assim dá para cobrir a seção 4 com testes unitários antes de qualquer UI. Comece por ele.

---

## 6. Ordem de reconstrução

1. `calc.dart` + testes das fórmulas da seção 4.
2. Tema e os widgets de rótulo/card — a identidade toda sai daí.
3. `home` → `route` → `window` → `pack`, que é o circuito de decisão.
4. `relay`.
5. O resto das telas (perfil, conquistas, histórico, chat, ajustes).

---

## 7. Pendências de produto (não implementadas no protótipo)

- Escrever o bastão **em campo**, não em casa.
- Dívida de confirmação: o app cobra a volta de quem prometeu.
- Recado que **apaga ao longo de 6 meses** — degradação visual, nunca um aviso.
