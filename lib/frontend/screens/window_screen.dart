import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/data/weather_forecast.dart';
import '../../backend/state/expedition_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Janela de tempo: escolher a partida recalcula carga, rota e luz.
class WindowScreen extends StatelessWidget {
  const WindowScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('JANELA DE TEMPO',
            sub: 'previsão de 72 h · Travessia Ruy Braga',
            trailing: fmtClock(s.wxSec),
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('BLOCOS DE 6 H · VENTO E TETO',
                        size: 9, tracking: 0.26),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 62,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: wxBlocks.map((b) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1.5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 12 + b.wind * .62,
                                    decoration: BoxDecoration(
                                      color: AppColors.q[b.q].withValues(alpha: .8),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(2)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: wxBlocks
                          .map((b) => Expanded(
                                child: Center(
                                  child: AppLabel(b.h,
                                      color: AppColors.dim, size: 7, tracking: 0.1),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        _Legend('BOM', AppColors.green),
                        SizedBox(width: 12),
                        _Legend('MARGINAL', AppColors.blue),
                        SizedBox(width: 12),
                        _Legend('RUIM', AppColors.amber),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppLabel('ESCOLHA A PARTIDA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              ...List.generate(wxSlots.length, (i) {
                final w = wxSlots[i];
                final meta = slotMeta[i];
                final on = s.wxPick == i;
                final arrive = addTime(meta.dep, s.day1);
                final dark = isDark(arrive, meta.lightPct);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppPanel(
                    onTap: () => s.pickWx(i),
                    bg: on ? AppColors.raised : AppColors.surfaceAlt,
                    borderColor: on ? AppColors.borderRaised : AppColors.border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppLabel(w.label,
                                      color: on ? AppColors.textStrong : AppColors.text,
                                      size: 14,
                                      tracking: 0.12),
                                  const SizedBox(height: 3),
                                  Text(w.sub, style: AppTypography.body(size: 9, color: AppColors.dim)),
                                ],
                              ),
                            ),
                            AppTag(w.tag, AppColors.tagInks[w.tagInk]),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(w.note, style: AppTypography.body(size: 10)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppStat('CHEGADA', arrive,
                                  size: 15,
                                  color: dark ? AppColors.amber : AppColors.textStrong),
                            ),
                            Expanded(
                                child: AppStat('NOITE',
                                    '${meta.nightM > 0 ? '+' : ''}${meta.nightM} °C',
                                    size: 15)),
                            Expanded(
                              child: AppStat('LUZ', '${meta.lightPct}%',
                                  size: 15,
                                  color: meta.lightPct < 60 ? AppColors.amber : AppColors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(meta.sleep, style: AppTypography.body(size: 9, color: AppColors.text3)),
                        if (meta.noturna) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.flashlight_on_outlined,
                                  size: 12, color: AppColors.amber),
                              const SizedBox(width: 6),
                              Expanded(
                                child: AppLabel(
                                    'FRONTAL OBRIGATÓRIA · ${6 - int.parse(meta.dep.split(':')[0])} H NO ESCURO ANTES DA LUZ',
                                    color: AppColors.amber,
                                    size: 8,
                                    tracking: 0.14),
                              ),
                            ],
                          ),
                        ],
                        if (on) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              border: Border.all(
                                  color: const Color(0xFF3A424C), style: BorderStyle.solid),
                              borderRadius: r4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppLabel('O QUE A CORDADA VÊ',
                                    color: AppColors.text3, size: 9, tracking: 0.24),
                                const SizedBox(height: 6),
                                Text(w.social, style: AppTypography.body(size: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          AppButton(w.cta, onTap: () => s.go('route'), primary: true),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 4),
              const AppLabel('EXIGÊNCIAS DA PARTIDA ESCOLHIDA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              AppPanel(
                borderColor: s.core.conflicts.isEmpty ? AppColors.border : AppColors.borderWarn,
                child: Column(
                  children: s.slot.needs.map((n) {
                    final falta = s.packOut.contains(n);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(falta ? Icons.close : Icons.check,
                              size: 13, color: falta ? AppColors.amber : AppColors.green),
                          const SizedBox(width: 9),
                          Expanded(child: AppLabel(n, color: AppColors.text, size: 10)),
                          AppLabel(falta ? 'EM CASA' : 'NA MOCHILA',
                              color: falta ? AppColors.amber : AppColors.green, size: 8),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color ink;
  const _Legend(this.label, this.ink);

  @override
  Widget build(BuildContext c) => Row(
        children: [
          Container(width: 8, height: 8, color: ink),
          const SizedBox(width: 5),
          AppLabel(label, color: AppColors.dim, size: 8, tracking: 0.14),
        ],
      );
}
