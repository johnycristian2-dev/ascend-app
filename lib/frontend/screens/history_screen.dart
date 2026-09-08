import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

const _months = [
  ('JUL 2026', 4, 3840, 'Agulhas Negras, Marins, Baú, Prateleiras'),
  ('JUN 2026', 7, 5120, 'semana de sete dias seguidos'),
  ('MAI 2026', 2, 1180, 'chuva na maior parte do mês'),
  ('ABR 2026', 5, 2960, 'primeira travessia de dois dias'),
  ('MAR 2026', 3, 1740, 'primeira noite em altitude'),
];

/// Histórico mensal: saídas e desnível acumulado.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final maxD = _months.map((m) => m.$3).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        ScreenBar('HISTÓRICO MENSAL',
            sub: 'últimos 5 meses', onBack: () => s.go('profile')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: _months.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: AppLabel(m.$1, color: AppColors.text, size: 12)),
                          Text('+${m.$3} m', style: AppTypography.num(size: 16)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      AppProgressBar(m.$3 / maxD, color: AppColors.green),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppLabel('${m.$2} ${m.$2 == 1 ? 'SAÍDA' : 'SAÍDAS'}',
                              color: AppColors.dim, size: 9),
                          Expanded(
                            child: Text(m.$4,
                                textAlign: TextAlign.right,
                                style: AppTypography.body(size: 9, color: AppColors.text3)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
