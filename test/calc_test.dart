import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/state/calc.dart';

// Nomes exatamente como o app os usa: packOut referencia itens pelo NOME.
const semNada = <String>{};

void main() {
  group('mochila', () {
    test('mochila cheia soma base + todos os itens', () {
      var esperado = packBaseG;
      for (final d in packData) {
        esperado += d.gramas;
      }
      expect(packWeight(semNada), esperado);
    });

    test('item fixo não pode sair', () {
      expect(packWeight({'ÁGUA · 2 L'}), packWeight(semNada));
    });

    test('deixar a corda em casa tira 1240 g', () {
      expect(packWeight(semNada) - packWeight({'CORDA 60 M'}), 1240);
    });

    test('estado inicial do app fica abaixo do limite de 12 kg', () {
      expect(packWeight({'CRAMPONS', 'CÂMERA'}) / 1000, lessThan(12));
    });

    test('ritmo cai e energia sobe com o peso', () {
      final cheia = packWeight(semNada);
      final leve = packWeight({'CORDA 60 M', 'BARRACA 2P'});
      expect(paceKmh(leve), greaterThan(paceKmh(cheia)));
      expect(kcal(leve), lessThan(kcal(cheia)));
    });
  });

  group('rota', () {
    const needs = ['SACO DE DORMIR -5°'];

    test('sem variantes fica na rota limpa', () {
      final c = linkCore(packOut: semNada, slotNeeds: needs);
      expect(c.variants, isEmpty);
      expect(c.km, baseKm);
      expect(c.m, baseM);
      expect(c.min, baseMin);
    });

    test('deixar crampons abre a via normal', () {
      final c = linkCore(packOut: {'CRAMPONS'}, slotNeeds: needs);
      expect(c.variants.single.name, 'VIA NORMAL');
      expect(c.km, closeTo(31.2, 0.001));
      expect(c.min, baseMin + 35);
    });

    test('duas variantes acumulam km, desnível e tempo', () {
      final c = linkCore(packOut: {'CORDA 60 M', 'PIOLET'}, slotNeeds: needs);
      expect(c.variants.length, 2);
      expect(c.m, baseM + 180 + 60);
      expect(c.min, baseMin + 40 + 20);
    });

    test('conflito é o cruzamento entre exigidos e deixados em casa', () {
      final c = linkCore(
          packOut: {'SACO DE DORMIR -5°', 'CÂMERA'},
          slotNeeds: ['SACO DE DORMIR -5°', 'FOGAREIRO + GÁS']);
      expect(c.conflicts, ['SACO DE DORMIR -5°']);
    });

    test('mochila mais leve encurta o tempo em pé', () {
      final cheia = walkMin(packOut: semNada, slotNeeds: needs);
      final leve = walkMin(packOut: {'BARRACA 2P', 'CÂMERA'}, slotNeeds: needs);
      expect(leve, lessThan(cheia));
    });
  });

  group('day1Min é a fonte única', () {
    const needs = ['SACO DE DORMIR -5°'];

    test('condição pior alonga o trecho do dia 1', () {
      final seca = day1Min(packOut: semNada, slotNeeds: needs, trail: TrailState.seca);
      final gelo = day1Min(packOut: semNada, slotNeeds: needs, trail: TrailState.gelo);
      expect(gelo, greaterThan(seca));
    });

    test('trilha seca com carga leve encurta o dia', () {
      final cheia = day1Min(packOut: semNada, slotNeeds: needs, trail: TrailState.seca);
      final leve = day1Min(
          packOut: {'BARRACA 2P', 'CÂMERA', 'COLCHONETE'},
          slotNeeds: needs,
          trail: TrailState.seca);
      expect(leve, lessThan(cheia));
    });

    test('partida às 05:00 chega antes do escuro', () {
      final d = day1Min(packOut: {'CRAMPONS', 'CÂMERA'}, slotNeeds: needs, trail: TrailState.lama);
      expect(isDark(addTime('05:00', d), 96), isFalse);
    });

    test('partida ao meio-dia no gelo chega depois do escuro', () {
      final d = day1Min(packOut: semNada, slotNeeds: needs, trail: TrailState.gelo);
      expect(isDark(addTime('12:00', d), 62), isTrue);
    });

    test('luz baixa marca risco mesmo chegando cedo', () {
      final d = day1Min(packOut: semNada, slotNeeds: needs, trail: TrailState.seca);
      expect(isDark(addTime('04:00', d), 48), isTrue);
    });
  });

  group('formatação', () {
    test('fmtDelta nunca produz "0 h 20"', () {
      expect(fmtDelta(20), '20 min');
      expect(fmtDelta(59), '59 min');
      expect(fmtDelta(140), '2 h 20');
    });

    test('fmtHm omite o minuto zero, como no protótipo', () {
      expect(fmtHm(120), '2 h');
      expect(fmtHm(125), '2 h 05');
    });

    test('addTime vira o dia corretamente', () {
      expect(addTime('05:00', 140), '07:20');
      expect(addTime('23:30', 90), '01:00');
    });

    test('fmtClock formata a contagem regressiva', () {
      expect(fmtClock(133964), '37:12:44');
    });

    test('fmtMil e fmtDec seguem o padrão pt-BR', () {
      expect(fmtMil(1640), '1 640');
      expect(fmtDec(11.35, 2), '11,35');
      expect(fmtDec(28.4), '28,4');
    });
  });
}
