/// Meteorologia como personagem: 12 blocos de 6 h e 4 opções de partida.
class WxBlock {
  final String h;
  final int q; // 0 bom, 1 marginal, 2 ruim
  final int wind, rain, ceil;
  const WxBlock(this.h, this.q, this.wind, this.rain, this.ceil);
}

const wxBlocks = <WxBlock>[
  WxBlock('00', 2, 54, 70, 20), WxBlock('06', 1, 38, 35, 45),
  WxBlock('12', 0, 22, 10, 80), WxBlock('18', 0, 18, 5, 90),
  WxBlock('00', 0, 16, 0, 95), WxBlock('06', 0, 20, 0, 92),
  WxBlock('12', 0, 26, 5, 85), WxBlock('18', 1, 34, 20, 62),
  WxBlock('00', 1, 42, 30, 50), WxBlock('06', 1, 48, 40, 40),
  WxBlock('12', 2, 66, 75, 15), WxBlock('18', 2, 72, 85, 10),
];

class WxSlot {
  final String label, sub, tag, note, cta, social;
  final int tagInk; // índice em Ink_.tagInks
  const WxSlot(this.label, this.sub, this.tag, this.tagInk, this.note, this.cta,
      this.social);
}

/// tagInk: 0 azul, 1 verde, 2 âmbar, 3 cinza
const wxSlots = <WxSlot>[
  WxSlot('HOJE · QUI 12:00', 'em 3 h', 'APERTADO', 0,
      'A janela acabou de abrir. Sobram 26 h úteis, mas você chega no Abrigo 2 depois do escuro.',
      'FIXAR PARTIDA HOJE, 12:00',
      'Kai já respondeu: consegue sair hoje. Nina só depois do almoço — ela chega no abrigo 2 h atrás de vocês.'),
  WxSlot('SEX 05:00', 'em 20 h', 'RECOMENDADO', 1,
      '33 h de janela e luz do início ao fim. Cume por volta das 11 h, descida inteira antes da frente.',
      'FIXAR PARTIDA SEX, 05:00',
      'Kai e Nina confirmam sexta. Téo pediu para sair uma hora mais tarde — dá, sem custo.'),
  WxSlot('SÁB 04:00', 'em 43 h', 'RISCO', 2,
      'Só 10 h antes da frente entrar. Dá para o cume. Não dá para a descida — e a descida é metade.',
      'FIXAR PARTIDA SÁB, 04:00',
      'Nina marcou este horário como recusado. Ela já foi pega por frente nessa crista.'),
  WxSlot('ESPERAR A PRÓXIMA', 'ter 14 JUL', 'CUSTO SOCIAL', 3,
      'A próxima janela dura 14 h — menos da metade desta. E é dia de semana.',
      'DESMARCAR E ESPERAR',
      'Kai e Nina não podem terça. Se você esperar, sobe sozinho ou remonta a cordada do zero.'),
];

class SlotMeta {
  final String dep, depDay, sleep;
  final List<String> needs;
  final int nightM, lightPct;
  const SlotMeta(this.dep, this.depDay, this.sleep, this.needs, this.nightM,
      this.lightPct);

  bool get noturna {
    final h = int.parse(dep.split(':')[0]);
    return h < 6;
  }
}

const slotMeta = <SlotMeta>[
  SlotMeta('12:00', 'QUI 09', 'Abrigo 2 · 1 900 m — chegada depois do escuro',
      ['SACO DE DORMIR -5°', 'FOGAREIRO + GÁS'], -2, 62),
  SlotMeta('05:00', 'SEX 10', 'Abrigo 2 · 1 900 m — chegada com luz',
      ['SACO DE DORMIR -5°'], 1, 96),
  SlotMeta('04:00', 'SÁB 11',
      'Bivaque na crista · 2 240 m — sem descida antes da frente',
      ['BARRACA 2P', 'SACO DE DORMIR -5°', 'FOGAREIRO + GÁS'], -6, 48),
  SlotMeta('05:00', 'TER 14', 'Abrigo 2 · 1 900 m — provavelmente sozinho',
      ['SACO DE DORMIR -5°', 'BARRACA 2P', 'KIT DE SOCORROS'], 0, 88),
];
