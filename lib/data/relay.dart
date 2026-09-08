/// Recados ancorados em pontos da rota, deixados por quem passou antes.
class RelayNote {
  final String who, rank, ago, km, at, last, text;
  final int conf;
  final bool stale;

  /// Dias desde a última confirmação (não desde a postagem original — um
  /// recado de 1 ano confirmado há 6 dias está vivo, não velho).
  final int diasDesdeConfirmacao;

  const RelayNote({
    required this.who,
    required this.rank,
    required this.ago,
    required this.km,
    required this.at,
    required this.conf,
    required this.last,
    required this.stale,
    required this.text,
    required this.diasDesdeConfirmacao,
  });

  /// Opacidade contínua: plena até 30 dias, decaindo até um piso de .35
  /// aos 182 dias (6 meses) sem confirmação — degradação visual, nunca
  /// um aviso de texto. [diasOverride] permite refletir uma confirmação
  /// feita nesta sessão sem reescrever os dados.
  double fadeOpacity({int? diasOverride}) {
    final d = (diasOverride ?? diasDesdeConfirmacao).clamp(0, 182);
    if (d <= 30) return 1;
    final t = (d - 30) / (182 - 30);
    return (1 - t * 0.65).clamp(0.35, 1.0);
  }
}

const relayData = <RelayNote>[
  RelayNote(
      who: 'ANA V.', rank: 'B', ago: 'há 3 semanas', km: '4,2',
      at: 'KM 4,2 · 1 240 m', conf: 12, last: 'há 4 dias', stale: false,
      diasDesdeConfirmacao: 4,
      text:
          'A marcação amarela some depois da porteira de arame. Não procure fita: siga o riacho pela margem direita até ouvir a queda. A trilha reaparece ali.'),
  RelayNote(
      who: 'DEDO', rank: 'C', ago: 'há 2 meses', km: '7,8',
      at: 'KM 7,8 · 1 620 m', conf: 8, last: 'há 11 dias', stale: false,
      diasDesdeConfirmacao: 11,
      text:
          'A fonte do vale é a última água antes do cume. Enchi 3 L aqui e ainda faltou no fim.'),
  RelayNote(
      who: 'R. MOTTA', rank: 'A', ago: 'há 5 meses', km: '11,4',
      at: 'KM 11,4 · 2 050 m', conf: 3, last: 'há 2 meses', stale: true,
      diasDesdeConfirmacao: 60,
      text:
          'A corrente fixa do paredão estava frouxa no terceiro grampo. Testei com o peso todo e não confiei. Levem corda.'),
  RelayNote(
      who: 'JUNO', rank: 'D', ago: 'há 8 dias', km: '13,0',
      at: 'KM 13,0 · 2 240 m', conf: 5, last: 'há 2 dias', stale: false,
      diasDesdeConfirmacao: 2,
      text:
          'O vento entra na crista a partir das 13 h, sem aviso. Passei 11h40 e foi tranquilo. Uma hora depois não seria.'),
  RelayNote(
      who: 'SEM NOME', rank: 'S', ago: 'há 1 ano', km: 'CUME',
      at: 'CUME · 2 421 m', conf: 41, last: 'há 6 dias', stale: false,
      diasDesdeConfirmacao: 6,
      text:
          'Tem uma lata enterrada sob a terceira pedra a leste do marco. Assine, leia os outros e devolva onde estava.'),
];
