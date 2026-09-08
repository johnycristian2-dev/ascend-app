import 'package:flutter/material.dart';
import '../main.dart';
import '../state/calc.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

/// Detalhes da rota: o efeito isolado de cada decisão tomada nas outras telas.
class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final core = s.core;
    final cond = condData[s.trail]!;
    final delta = <String>[
      if (core.km > baseKm) '+${fmtDec(core.km - baseKm)} km',
      if (core.m > baseM) '+${core.m - baseM} m',
      if (s.varMin > 0) '+${fmtDelta(s.varMin)} de desvio',
      if (s.loadMin > 0) '+${fmtDelta(s.loadMin)} de peso',
    ];

    return Column(
      children: [
        ScreenBar('DETALHES DA ROTA',
            sub: 'Travessia Ruy Braga · via chaminé',
            trailing: 'RANK B',
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              Panel(
                borderColor: core.conflicts.isEmpty ? Ink_.border : Ink_.borderWarn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('O QUE SUAS DECISÕES MUDARAM',
                        size: 9, tracking: 0.26),
                    const SizedBox(height: 10),
                    Text(
                      delta.isEmpty
                          ? 'Rota limpa e carga leve — nada foi acrescentado.'
                          : '${delta.join(' · ')} sobre a rota limpa',
                      style: T.body(
                          size: 10.5,
                          color: delta.isEmpty ? Ink_.green : Ink_.text),
                    ),
                    if (core.variants.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ...core.variants.map((v) => Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: 2,
                                    height: 34,
                                    color: Ink_.amber,
                                    margin: const EdgeInsets.only(right: 10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Lbl(v.name, color: Ink_.text, size: 10),
                                      const SizedBox(height: 3),
                                      Text(v.why,
                                          style: T.body(size: 9, color: Ink_.text3)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '+${v.km > 0 ? '${fmtDec(v.km)} km · +' : ''}${v.m > 0 ? '${v.m} m · +' : ''}${v.min} min',
                                        style: T.body(size: 9, color: Ink_.amber),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                    if (core.conflicts.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: Ink_.bgWarn,
                          border: Border.all(color: Ink_.borderWarn),
                          borderRadius: r4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              core.conflicts.length == 1
                                  ? 'A partida escolhida exige 1 item que você deixou em casa.'
                                  : 'A partida escolhida exige ${core.conflicts.length} itens que você deixou em casa.',
                              style: T.body(size: 10, color: Ink_.amber),
                            ),
                            const SizedBox(height: 7),
                            ...core.conflicts.map((n) =>
                                Lbl('✕  $n', color: Ink_.text2, size: 9)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('TOTAL DA TRAVESSIA'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Stat('DISTÂNCIA', '${fmtDec(core.km)} km')),
                        Expanded(child: Stat('SUBIDA', '+${fmtMil(core.m)} m')),
                        Expanded(child: Stat('EM PÉ', fmtHm(s.walk))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Panel(
                bg: s.dark ? Ink_.bgWarn : Ink_.surface,
                borderColor: s.dark ? Ink_.borderWarn : Ink_.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Lbl('DIA 1 · ATÉ O ABRIGO'),
                        Lbl('${s.slot.depDay} · ${s.slot.dep}',
                            color: Ink_.dim, size: 9),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Stat('PARTIDA', s.slot.dep, size: 18)),
                        Expanded(child: Stat('TRECHO', fmtDelta(s.day1), size: 18)),
                        Expanded(
                          child: Stat('CHEGADA', s.arrive,
                              size: 18,
                              color: s.dark ? Ink_.amber : Ink_.textStrong),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Text(
                      s.lightMargin >= 0
                          ? 'Você chega ${fmtDelta(s.lightMargin)} antes do escuro.'
                          : 'Você chega ${fmtDelta(-s.lightMargin)} depois do escuro.',
                      style: T.body(
                          size: 11,
                          color: s.lightMargin >= 0 ? Ink_.text2 : Ink_.amber),
                    ),
                    const SizedBox(height: 5),
                    Text(s.slot.sleep, style: T.body(size: 9, color: Ink_.dim)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Lbl('CONDIÇÃO DA ROTA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              Row(
                children: TrailState.values.map((t) {
                  final on = s.trail == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Panel(
                        onTap: () => s.setTrail(t),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        bg: on ? Ink_.raised : Ink_.surface,
                        borderColor: on ? Ink_.borderRaised : Ink_.border,
                        child: Center(
                          child: Lbl(t.name.toUpperCase(),
                              color: on ? Ink_.text : Ink_.dim,
                              size: 9,
                              tracking: 0.14),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Panel(
                bg: Ink_.surfaceAlt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Lbl(cond.label, color: Ink_.tagInks[0], size: 10),
                    const SizedBox(height: 7),
                    Text(cond.note, style: T.body(size: 10)),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Expanded(child: Stat('CUME', cond.temp, size: 15)),
                        Expanded(child: Stat('VENTO', '${cond.wind} km/h', size: 15)),
                        Expanded(
                            child: Stat('TÉCNICA MÍN.',
                                cond.need == 0 ? '—' : 'RANK ${['E', 'D', 'C', 'B'][cond.need]}',
                                size: 15)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Btn('AJUSTAR MOCHILA', onTap: () => s.go('pack'))),
                  const SizedBox(width: 10),
                  Expanded(child: Btn('VER RECADOS', onTap: () => s.go('relay'))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
