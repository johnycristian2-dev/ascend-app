import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/backend/state/expedition_calculator.dart';

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

  group('índice de confiança da rota', () {
    test('sem votos, confiança reflete o decaimento natural dos recados', () {
      final t = computeRouteTrust(const {});
      expect(t.pct, greaterThanOrEqualTo(95));
      expect(t.pct, lessThan(100));
    });

    test('freshestDias e stalestDias refletem os dias sem voto nenhum', () {
      final t = computeRouteTrust(const {});
      expect(t.freshestDias, 2);
      expect(t.stalestDias, 60);
    });

    test('"não achei" no recado mais confirmado derruba bastante a confiança', () {
      final base = computeRouteTrust(const {});
      final comVoto = computeRouteTrust({4: 'n'});
      expect(comVoto.pct, lessThan(base.pct - 30));
    });

    test('confirmar o recado mais velho pode levar a confiança a 100%', () {
      final t = computeRouteTrust({2: 'y'});
      expect(t.pct, 100);
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

  group('xp e rank real', () {
    test('xpGanho aplica a fórmula e o multiplicador de dificuldade', () {
      // (28,4×10 + 1640×0,5) × 1,3 (moderada) = (284 + 820) × 1,3 = 1435,2 → 1435
      expect(xpGanho(km: 28.4, m: 1640, dificuldade: Dificuldade.moderada), 1435);
      // mesma rota em dificuldade extrema: ×2,0 = 2208
      expect(xpGanho(km: 28.4, m: 1640, dificuldade: Dificuldade.extrema), 2208);
    });

    test('dificuldadeDe mapeia a condição real da trilha', () {
      expect(dificuldadeDe(TrailState.seca), Dificuldade.moderada);
      expect(dificuldadeDe(TrailState.lama), Dificuldade.moderada);
      expect(dificuldadeDe(TrailState.neve), Dificuldade.dificil);
      expect(dificuldadeDe(TrailState.gelo), Dificuldade.extrema);
    });

    test('isTecnica só é true quando a condição exige rank técnico', () {
      for (final t in TrailState.values) {
        expect(isTecnica(t), condData[t]!.need > 0);
      }
    });

    test('rankIdxForXp respeita os limiares cumulativos de CLAUDE.md', () {
      expect(rankIdxForXp(0), 0); // E
      expect(rankIdxForXp(999), 0); // E
      expect(rankIdxForXp(1000), 1); // D
      expect(rankIdxForXp(2999), 1); // D
      expect(rankIdxForXp(3000), 2); // C
      expect(rankIdxForXp(6999), 2); // C
      expect(rankIdxForXp(7000), 3); // B
      expect(rankIdxForXp(14999), 3); // B
      expect(rankIdxForXp(15000), 4); // A
      expect(rankIdxForXp(29999), 4); // A
      expect(rankIdxForXp(30000), 5); // S
      expect(rankIdxForXp(999999), 5); // S
    });

    test('attrGains soma resistência/força e bônus fixo de técnica', () {
      final g = attrGains(km: 28.4, m: 1640, tecnica: false);
      expect(g.resistencia, (28.4 * 0.3).round());
      expect(g.forca, (1640 * 0.02).round());
      expect(g.tecnica, 0);

      final gTec = attrGains(km: 28.4, m: 1640, tecnica: true);
      expect(gTec.tecnica, 5);
    });
  });
}
