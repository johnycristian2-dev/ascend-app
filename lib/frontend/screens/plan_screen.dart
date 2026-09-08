import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

const _planTrails = ['PEDRA DO BAÚ', 'TRAVESSIA RUY BRAGA', 'PRATELEIRAS'];

/// Nova expedição: trilha, data e o que a cordada leva.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('NOVA EXPEDIÇÃO',
            sub: 'julho de 2026', onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              const AppLabel('TRILHA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              ...List.generate(_planTrails.length, (i) {
                final on = s.planTrail == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AppPanel(
                    onTap: () => s.setPlanTrail(i),
                    bg: on ? AppColors.raised : AppColors.surface,
                    borderColor: on ? AppColors.borderRaised : AppColors.border,
                    child: Row(
                      children: [
                        Icon(on ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 14, color: on ? AppColors.amber : AppColors.dim),
                        const SizedBox(width: 10),
                        AppLabel(_planTrails[i],
                            color: on ? AppColors.text : AppColors.text2, size: 11),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              const AppLabel('DATA DE PARTIDA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              AppPanel(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(14, (i) {
                    final d = i + 8;
                    final on = s.planDate == d;
                    return InkWell(
                      onTap: () => s.setPlanDate(d),
                      borderRadius: r4,
                      child: Container(
                        width: 38,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: on ? AppColors.raised : AppColors.surfaceAlt,
                          border: Border.all(color: on ? AppColors.amber : AppColors.border),
                          borderRadius: r4,
                        ),
                        child: Center(
                          child: Text('$d',
                              style: AppTypography.num(
                                  size: 13,
                                  color: on ? AppColors.textStrong : AppColors.text2,
                                  weight: FontWeight.w500)),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              AppButton('CONVOCAR CORDADA', onTap: () => s.go('party'), primary: true),
              const SizedBox(height: 9),
              Text('Ou entre na cordada de alguém — dá para acompanhar sem subir.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 9.5, color: AppColors.dim)),
            ],
          ),
        ),
      ],
    );
  }
}
