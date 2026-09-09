/// Conquista desbloqueada por algo que você **realmente fez**, não um
/// roteiro fixo como `stampData` (em `gear_catalog.dart`). Uma vez
/// desbloqueada (`ExpeditionState.unlockedAchievements`), fica pra
/// sempre — mesmo que a condição que a disparou deixe de valer depois
/// (ex.: você tirar peso da mochila de novo não tira a conquista de
/// "já carregou mais de 12 kg").
class Achievement {
  final String id;
  final String title;
  final String description;
  const Achievement(this.id, this.title, this.description);
}

const achievementCatalog = <Achievement>[
  Achievement(
    'peso_no_limite',
    'NO LIMITE DA MOCHILA',
    'Sua carga passou de 12 kg pela primeira vez — acima do que o rank sustenta em 2 dias.',
  ),
  Achievement(
    'mochila_leve',
    'VIAGEM LEVE',
    'Você arrumou a mochila com menos de 10 kg pela primeira vez.',
  ),
  Achievement(
    'primeiro_recado',
    'PRIMEIRO RECADO',
    'Você ancorou seu primeiro recado de bastão pra quem vem depois.',
  ),
  Achievement(
    'primeira_confirmacao',
    'ELO DA CORRENTE',
    'Você confirmou um recado de bastão pela primeira vez — a rota fica mais confiável por sua causa.',
  ),
  Achievement(
    'confirmou_recado_velho',
    'GUARDIÃO DA MEMÓRIA',
    'Você confirmou um recado com mais de 6 meses sem confirmação — ele não vai apagar por enquanto.',
  ),
  Achievement(
    'primeira_saida_equip',
    'ODÔMETRO LIGADO',
    'Você registrou a primeira saída de uma peça de equipamento.',
  ),
  Achievement(
    'primeira_mensagem',
    'NA ESCUTA',
    'Você mandou sua primeira mensagem pra cordada.',
  ),
  Achievement(
    'rank_up',
    'NOVA CLASSIFICAÇÃO',
    'Seu rank subiu pela primeira vez.',
  ),
];
