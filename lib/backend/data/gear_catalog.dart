/// Equipamento com odômetro real: uso, desgaste e manutenção.
class GearItem {
  final String id, nome, spec, tag, kg;
  final int tagInk; // 0 azul(técnico) 1 âmbar(segurança) 2 cinza(base) 3 verde(abrigo)
  final int uses, wear, od, lim;
  final String unit, svc, svcAt, wearNote;
  const GearItem({
    required this.id,
    required this.nome,
    required this.spec,
    required this.tag,
    required this.tagInk,
    required this.kg,
    required this.uses,
    required this.wear,
    required this.od,
    required this.lim,
    required this.unit,
    required this.svc,
    required this.svcAt,
    required this.wearNote,
  });
}

const gearData = <GearItem>[
  GearItem(
      id: 'piolet', nome: 'Piqueta de gelo', spec: '58 cm · 0,55 kg',
      tag: 'TÉCNICO', tagInk: 0, kg: '0,55',
      uses: 9, wear: 22, od: 9, lim: 40, unit: 'saídas',
      svc: 'em dia', svcAt: 'revisão de fixação em 11 saídas',
      wearNote: 'Lâmina afiada, cabo sem folga. Revisar fixação a cada 20 saídas.'),
  GearItem(
      id: 'corda', nome: 'Corda dinâmica 60 m', spec: '9,4 mm · 3,4 kg',
      tag: 'SEGURANÇA', tagInk: 1, kg: '3,4',
      uses: 41, wear: 68, od: 41, lim: 60, unit: 'saídas',
      svc: 'inspecionar', svcAt: 'inspeção de capa antes de cada saída',
      wearNote:
          'Uso intenso. Inspecionar capa antes de cada saída — substituir a 5 anos ou 60 %.'),
  GearItem(
      id: 'mochila', nome: 'Mochila cargueira 45 L',
      spec: 'Estrutura interna · 1,2 kg', tag: 'BASE', tagInk: 2, kg: '1,2',
      uses: 63, wear: 44, od: 1840, lim: 4000, unit: 'km',
      svc: 'em dia', svcAt: 'reforço de costura recomendado',
      wearNote: 'Costuras do painel traseiro pedem reforço antes da próxima temporada.'),
  GearItem(
      id: 'bota', nome: 'Bota B3 crampon-ready', spec: 'Nº 42 · 1,8 kg',
      tag: 'TÉCNICO', tagInk: 0, kg: '1,8',
      uses: 58, wear: 71, od: 1620, lim: 2200, unit: 'km',
      svc: 'revisar', svcAt: 'solado no limite de aderência',
      wearNote: 'Solado gasto no antepé. Aderência em rocha molhada já caiu.'),
  GearItem(
      id: 'bussola', nome: 'Bússola de placa', spec: 'Declinação ajustável · 0,04 kg',
      tag: 'BASE', tagInk: 2, kg: '0,04',
      uses: 71, wear: 8, od: 71, lim: 400, unit: 'saídas',
      svc: 'em dia', svcAt: 'sem manutenção prevista',
      wearNote: 'Cápsula sem bolha. Nada a fazer.'),
  GearItem(
      id: 'lanterna', nome: 'Lanterna frontal 900 lm', spec: 'Bateria 12 h · 0,15 kg',
      tag: 'BASE', tagInk: 2, kg: '0,15',
      uses: 34, wear: 31, od: 34, lim: 200, unit: 'saídas',
      svc: 'em dia', svcAt: 'trocar bateria em 20 saídas',
      wearNote: 'Autonomia medida caiu para 10 h no frio.'),
  GearItem(
      id: 'barraca', nome: 'Barraca 4 estações', spec: 'Dupla parede · 2,6 kg',
      tag: 'ABRIGO', tagInk: 3, kg: '2,6',
      uses: 12, wear: 26, od: 34, lim: 130, unit: 'noites',
      svc: 'revisar', svcAt: 'reimpermeabilizar antes do inverno',
      wearNote: 'Impermeabilização do sobreteto vencendo — reaplicar antes do inverno.'),
  GearItem(
      id: 'crampons', nome: 'Crampons 12 pontas', spec: 'Aço · 0,95 kg',
      tag: 'TÉCNICO', tagInk: 0, kg: '0,95',
      uses: 7, wear: 18, od: 7, lim: 50, unit: 'saídas',
      svc: 'em dia', svcAt: 'afiação a cada 15 saídas',
      wearNote: 'Pontas frontais dentro da tolerância. Amarração sem desgaste.'),
  GearItem(
      id: 'fogareiro', nome: 'Fogareiro ultraleve', spec: 'Gás · 0,3 kg',
      tag: 'BASE', tagInk: 2, kg: '0,3',
      uses: 47, wear: 39, od: 47, lim: 120, unit: 'saídas',
      svc: 'em dia', svcAt: 'limpeza de válvula em 13 saídas',
      wearNote: 'Chama estável. Limpar válvula na próxima revisão.'),
];

/// Carimbos: conquistas com registro, e metas ainda em progresso.
class Stamp {
  final String titulo;
  final List<List<String>> rows;
  final String note;
  final int? pct; // null = já conquistado
  const Stamp(this.titulo, this.rows, this.note, {this.pct});
}

const stampData = <Stamp>[
  Stamp('PRIMEIRA NOITE EM ALTITUDE', [
    ['data', '14 MAR 2026'],
    ['trilha', 'Pedra do Baú — via normal'],
    ['companheiros', 'Nina, Téo'],
    ['altitude máx.', '1 950 m'],
  ], 'Primeira vez que dormi em barraca com vento. Não dormi nada, mas o nascer do sol pagou.'),
  Stamp('ACIMA DE 2 400 M', [
    ['data', '08 JUL 2026'],
    ['trilha', 'Agulhas Negras — face sul'],
    ['companheiros', 'Kai'],
    ['altitude máx.', '2 421 m'],
  ], 'Passamos dos 2 000 m às 11h40. Ar mais fino do que eu esperava.'),
  Stamp('SETE DIAS SEGUIDOS', [
    ['período', '26 JUN – 02 JUL'],
    ['saídas', '7 dias consecutivos'],
    ['desnível total', '3 840 m'],
    ['companheiros', 'variados'],
  ], 'A semana que mudou meu ritmo. No quinto dia o corpo parou de reclamar.'),
  Stamp('TRAVESSIA NOTURNA', [
    ['data', '21 JUN 2026'],
    ['trecho', 'Vale das Pedras · 22h10 – 02h40'],
    ['companheiros', 'Téo'],
    ['visibilidade', 'lua cheia'],
  ], 'Frontal desligada por dez minutos. Só a lua na pedra branca. Nunca vou esquecer.'),
  Stamp('FRIO EXTREMO', [], 
      'Registre uma saída completa com temperatura medida abaixo de -5 °C. O sensor precisa estar ativo durante todo o trecho.',
      pct: 0),
  Stamp('TRÍPLICE COROA', [],
      'Concluir Agulhas Negras, Pedra do Sino e Prateleiras dentro da mesma temporada.',
      pct: 66),
  Stamp('QUARENTA MIL', [],
      'Acumular 40 000 m de desnível positivo e concluir três travessias de rank A.',
      pct: 18),
];
