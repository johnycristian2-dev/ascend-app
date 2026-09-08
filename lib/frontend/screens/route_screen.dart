import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

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
              AppPanel(
                borderColor: core.conflicts.isEmpty ? AppColors.border : AppColors.borderWarn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('O QUE SUAS DECISÕES MUDARAM',
                        size: 9, tracking: 0.26),
                    const SizedBox(height: 10),
                    Text(
                      delta.isEmpty
                          ? 'Rota limpa e carga leve — nada foi acrescentado.'
                          : '${delta.join(' · ')} sobre a rota limpa',
                      style: AppTypography.body(
                          size: 10.5,
                          color: delta.isEmpty ? AppColors.green : AppColors.text),
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
                                    color: AppColors.amber,
                                    margin: const EdgeInsets.only(right: 10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppLabel(v.name, color: AppColors.text, size: 10),
                                      const SizedBox(height: 3),
                                      Text(v.why,
                                          style: AppTypography.body(size: 9, color: AppColors.text3)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '+${v.km > 0 ? '${fmtDec(v.km)} km · +' : ''}${v.m > 0 ? '${v.m} m · +' : ''}${v.min} min',
                                        style: AppTypography.body(size: 9, color: AppColors.amber),
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
                          color: AppColors.bgWarn,
                          border: Border.all(color: AppColors.borderWarn),
                          borderRadius: r4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              core.conflicts.length == 1
                                  ? 'A partida escolhida exige 1 item que você deixou em casa.'
                                  : 'A partida escolhida exige ${core.conflicts.length} itens que você deixou em casa.',
                              style: AppTypography.body(size: 10, color: AppColors.amber),
                            ),
                            const SizedBox(height: 7),
                            ...core.conflicts.map((n) =>
                                AppLabel('✕  $n', color: AppColors.text2, size: 9)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('TOTAL DA TRAVESSIA'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: AppStat('DISTÂNCIA', '${fmtDec(core.km)} km')),
                        Expanded(child: AppStat('SUBIDA', '+${fmtMil(core.m)} m')),
                        Expanded(child: AppStat('EM PÉ', fmtHm(s.walk))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppPanel(
                bg: s.dark ? AppColors.bgWarn : AppColors.surface,
                borderColor: s.dark ? AppColors.borderWarn : AppColors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppLabel('DIA 1 · ATÉ O ABRIGO'),
                        AppLabel('${s.slot.depDay} · ${s.slot.dep}',
                            color: AppColors.dim, size: 9),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: AppStat('PARTIDA', s.slot.dep, size: 18)),
                        Expanded(child: AppStat('TRECHO', fmtDelta(s.day1), size: 18)),
                        Expanded(
                          child: AppStat('CHEGADA', s.arrive,
                              size: 18,
                              color: s.dark ? AppColors.amber : AppColors.textStrong),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Text(
                      s.lightMargin >= 0
                          ? 'Você chega ${fmtDelta(s.lightMargin)} antes do escuro.'
                          : 'Você chega ${fmtDelta(-s.lightMargin)} depois do escuro.',
                      style: AppTypography.body(
                          size: 11,
                          color: s.lightMargin >= 0 ? AppColors.text2 : AppColors.amber),
                    ),
                    const SizedBox(height: 5),
                    Text(s.slot.sleep, style: AppTypography.body(size: 9, color: AppColors.dim)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppLabel('CONDIÇÃO DA ROTA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              Row(
                children: TrailState.values.map((t) {
                  final on = s.trail == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AppPanel(
                        onTap: () => s.setTrail(t),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        bg: on ? AppColors.raised : AppColors.surface,
                        borderColor: on ? AppColors.borderRaised : AppColors.border,
                        child: Center(
                          child: AppLabel(t.name.toUpperCase(),
                              color: on ? AppColors.text : AppColors.dim,
                              size: 9,
                              tracking: 0.14),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              AppPanel(
                bg: AppColors.surfaceAlt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppLabel(cond.label, color: AppColors.tagInks[0], size: 10),
                    const SizedBox(height: 7),
                    Text(cond.note, style: AppTypography.body(size: 10)),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Expanded(child: AppStat('CUME', cond.temp, size: 15)),
                        Expanded(child: AppStat('VENTO', '${cond.wind} km/h', size: 15)),
                        Expanded(
                            child: AppStat('TÉCNICA MÍN.',
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
                  Expanded(child: AppButton('AJUSTAR MOCHILA', onTap: () => s.go('pack'))),
                  const SizedBox(width: 10),
                  Expanded(child: AppButton('VER RECADOS', onTap: () => s.go('relay'))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
