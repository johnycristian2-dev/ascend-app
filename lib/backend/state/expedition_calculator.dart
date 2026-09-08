// Dart puro — nenhum import de Flutter. Valores extraídos do protótipo.

/// Condição real da rota. `minutes` é o tempo TOTAL de referência do trecho,
/// não uma penalidade — entra cru no cálculo de day1Min.
enum TrailState { seca, lama, neve, gelo }

class CondInfo {
  final String label;
  final String note;
  final String temp;
  final String wind;
  final int need; // rank técnico mínimo exigido
  final int minutes;
  const CondInfo(this.label, this.note, this.temp, this.wind, this.need, this.minutes);
}

const condData = <TrailState, CondInfo>{
  TrailState.seca: CondInfo('SECA E FIRME',
      'Piso consolidado até a crista. Sem trechos de barro ou gelo reportados.',
      '6°', '34', 0, 560),
  TrailState.lama: CondInfo('COM LAMA',
      'Chuva de anteontem. Trechos escorregadios no vale — conte 40 min extras.',
      '3°', '34', 0, 600),
  TrailState.neve: CondInfo('COM NEVE',
      'Neve fresca acima de 2 200 m. Progressão exige crampons e piqueta.',
      '-4°', '48', 3, 700),
  TrailState.gelo: CondInfo('COM GELO VIVO',
      'Placa de gelo na face sul. Terreno de queda exposta em 800 m de crista.',
      '-9°', '62', 3, 760),
};

/// Item da mochila. A chave de identidade é o NOME — é assim que packOut
/// referencia os itens em todo o app.
class PackItem {
  final String nome;
  final String note;
  final int gramas;
  final bool fixo;
  final String consequencia;
  const PackItem(this.nome, this.note, this.gramas, this.fixo, this.consequencia);
}

const packBaseG = 1350;

const packData = <PackItem>[
  PackItem('ÁGUA · 2 L', 'consumo até a fonte do vale', 2000, true, ''),
  PackItem('COMIDA · 2 DIAS', 'ração fria e barras', 1400, true, ''),
  PackItem('CASACO DE PLUMA', 'obrigatório acima de 2 000 m', 620, true, ''),
  PackItem('KIT DE SOCORROS', 'coletivo — hoje é você que leva', 340, true, ''),
  PackItem('FRONTAL + PILHAS', 'ninguém sai do abrigo sem', 98, true, ''),
  PackItem('MAPA + BÚSSOLA', 'papel não descarrega', 110, true, ''),
  PackItem('CORDA 60 M', 'passagem da chaminé', 1240, false,
      'Sem corda a chaminé sai da rota. Variante longa: +40 min e 180 m de desnível extra.'),
  PackItem('BARRACA 2P', 'dividida com Kai', 1980, false,
      'Sem barraca você aposta que o Abrigo 2 esteja vazio. Ontem estava cheio.'),
  PackItem('SACO DE DORMIR -5°', 'noite a 1 900 m', 1100, false,
      'A mínima prevista é -2°. Sem saco, a noite fica no limite do suportável.'),
  PackItem('COLCHONETE', 'isolamento do chão', 380, false,
      'O chão rouba mais calor que o ar. Você dorme, mas dorme mal.'),
  PackItem('FOGAREIRO + GÁS', 'água quente, neve derretida', 610, false,
      'Derreter neve deixa de ser plano B para a água. Você depende da fonte estar correndo.'),
  PackItem('CRAMPONS', 'face sul acima de 2 200 m', 890, false,
      'A face sul fica interditada. Só a via normal, que é 2,8 km mais longa.'),
  PackItem('PIOLET', 'neve dura na crista', 520, false,
      'Um escorregão na neve dura passa a não ter freio.'),
  PackItem('CÂMERA', 'não é equipamento', 740, false,
      'Nada muda na rota. É peso que você escolhe carregar.'),
];

/// Peso total: itens fixos sempre entram; os demais só se não estiverem em casa.
int packWeight(Set<String> packOut) {
  var g = packBaseG;
  for (final d in packData) {
    if (d.fixo || !packOut.contains(d.nome)) g += d.gramas;
  }
  return g;
}

class VariantRule {
  final String item;
  final String name;
  final String why;
  final double km;
  final int m;
  final int min;
  const VariantRule(this.item, this.name, this.why, this.km, this.m, this.min);
}

const variantRules = <VariantRule>[
  VariantRule('CORDA 60 M', 'VARIANTE DA CHAMINÉ',
      'sem corda, a chaminé sai da rota', 0, 180, 40),
  VariantRule('CRAMPONS', 'VIA NORMAL',
      'sem crampons, a face sul fica interditada', 2.8, 0, 35),
  VariantRule('PIOLET', 'DESVIO DA NEVE DURA',
      'sem piolet, a crista dura passa pelo flanco', 1.1, 60, 20),
];

const baseKm = 28.4;
const baseM = 1640;
const baseMin = 560;

/// Núcleo da propagação: partida escolhida + itens em casa -> rota resultante.
class LinkCore {
  final List<VariantRule> variants;
  final double km;
  final int m;
  final int min;
  final List<String> conflicts;
  const LinkCore(this.variants, this.km, this.m, this.min, this.conflicts);
}

LinkCore linkCore({
  required Set<String> packOut,
  required List<String> slotNeeds,
}) {
  final variants = variantRules.where((v) => packOut.contains(v.item)).toList();
  var km = baseKm, m = baseM, min = baseMin;
  for (final v in variants) {
    km += v.km;
    m += v.m;
    min += v.min;
  }
  final conflicts = slotNeeds.where(packOut.contains).toList();
  return LinkCore(variants, km, m, min, conflicts);
}

/// Tempo em pé corrigido pelo peso da mochila.
int walkMin({required Set<String> packOut, required List<String> slotNeeds}) {
  final c = linkCore(packOut: packOut, slotNeeds: slotNeeds);
  final kg = packWeight(packOut) / 1000;
  return (c.min * (1 + (kg - 10) * 0.022)).round();
}

/// Trecho do primeiro dia. FONTE ÚNICA para chegada, margem de luz e veredito.
int day1Min({
  required Set<String> packOut,
  required List<String> slotNeeds,
  required TrailState trail,
}) {
  final w = walkMin(packOut: packOut, slotNeeds: slotNeeds);
  return ((w + condData[trail]!.minutes - baseMin) * 0.56).round();
}

double paceKmh(int gramas) => 4.1 - 0.075 * (gramas / 1000);
int kcal(int gramas) => (1780 + 132 * (gramas / 1000)).round();

// ---------------------------------------------------------------- formatação

/// 140 -> "2 h 20"; 120 -> "2 h" (minuto zero é omitido, como no protótipo).
String fmtHm(int min) {
  final r = min % 60;
  return '${min ~/ 60} h${r != 0 ? ' ${r.toString().padLeft(2, '0')}' : ''}';
}

/// 20 -> "20 min"; 140 -> "2 h 20". SEMPRE use este para deltas.
String fmtDelta(int min) => min >= 60 ? fmtHm(min) : '$min min';

/// Soma minutos a um horário "05:00" e devolve "07:20".
String addTime(String dep, int min) {
  final p = dep.split(':').map(int.parse).toList();
  final t = p[0] * 60 + p[1] + min;
  return '${((t ~/ 60) % 24).toString().padLeft(2, '0')}:'
      '${(t % 60).toString().padLeft(2, '0')}';
}

/// Contagem regressiva em segundos -> "37:12:44".
String fmtClock(int total) {
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(total ~/ 3600)}:${p((total % 3600) ~/ 60)}:${p(total % 60)}';
}

/// 1640 -> "1 640" — espaço fino como separador de milhar (decisão do
/// protótipo: "sem mais pontos", ver ESPEC-Flutter.md §4.6).
String fmtMil(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

String fmtDec(double v, [int casas = 1]) =>
    v.toStringAsFixed(casas).replaceAll('.', ',');

const darkMin = 18 * 60 + 20;

/// Chegada é escura se passa das 18:20 ou se a janela tem pouca luz.
bool isDark(String arrive, int lightPct) =>
    arrive.compareTo('18:20') > 0 || lightPct < 60;
