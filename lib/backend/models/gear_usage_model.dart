/// O que muda numa peça de equipamento quando ela é de fato usada —
/// separado do catálogo (`GearItem`, em `gear_catalog.dart`), que é
/// referência estática (nome, peso, categoria, dicas de manutenção).
///
/// Uma conta nova começa com todo equipamento zerado (ver
/// `UserProfile.starter`); uma conta que já existia antes desta função
/// existir não tem nada gravado ainda — nesse caso `ExpeditionState.
/// gearUsage` cai de volta nos números de demonstração do catálogo, pra
/// não regredir visualmente pra zero peças "novas em folha".
class GearUsage {
  final int uses;
  final int wear;
  final int od;
  const GearUsage({this.uses = 0, this.wear = 0, this.od = 0});

  /// Registra uma saída: soma 1 uso, avança o odômetro (pelo tamanho de
  /// uma expedição-base — 28 km, ESPEC-Flutter.md §4.4 — pra peças
  /// medidas em km; 1 unidade pra saídas/noites) e soma 2 pontos de
  /// desgaste. O desgaste não deriva de od/lim de propósito: os dados de
  /// demonstração já não seguem essa proporção (cada peça carrega desgaste
  /// próprio, não só "quilômetros rodados") — é uma aproximação simples
  /// pra ter *algum* incremento, ajustável depois sem mexer no formato.
  GearUsage logOuting(String unit) => GearUsage(
        uses: uses + 1,
        od: od + (unit == 'km' ? 28 : 1),
        wear: (wear + 2).clamp(0, 100),
      );

  Map<String, dynamic> toMap() => {'uses': uses, 'wear': wear, 'od': od};

  factory GearUsage.fromMap(Map<String, dynamic> m) => GearUsage(
        uses: ((m['uses'] as num?) ?? 0).toInt(),
        wear: ((m['wear'] as num?) ?? 0).toInt(),
        od: ((m['od'] as num?) ?? 0).toInt(),
      );
}
