import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Caderno: rank, atributos e a meta de desnível da temporada.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 26),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLabel('CADERNO DE CAMPO', color: AppColors.dim, size: 9, tracking: 0.26),
                  const SizedBox(height: 5),
                  Text(s.name.toUpperCase(), style: AppTypography.num(size: 26, color: AppColors.text)),
                  const SizedBox(height: 3),
                  Text(s.baseName, style: AppTypography.body(size: 10, color: AppColors.text3)),
                ],
              ),
            ),
            InkWell(
              onTap: () => s.go('settings'),
              borderRadius: r4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: r4,
                ),
                child: const Icon(Icons.tune, size: 15, color: AppColors.text2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('RANK ${s.rank}', style: AppTypography.num(size: 40, color: AppColors.amber)),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: AppLabel('NÍVEL ${s.level}', color: AppColors.text2, size: 11),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLabel('DESNÍVEL DA TEMPORADA', color: AppColors.dim, size: 9),
                  Text('${fmtMil(s.elev)} / ${fmtMil(s.elevGoal)} m',
                      style: AppTypography.num(size: 13, color: AppColors.text2)),
                ],
              ),
              const SizedBox(height: 8),
              AppProgressBar(s.elev / s.elevGoal, color: AppColors.amber, height: 4),
              const SizedBox(height: 8),
              Text(
                s.elev >= s.elevGoal
                    ? 'Meta batida. A reavaliação de rank abre no próximo registro.'
                    : 'Faltam ${fmtMil(s.elevGoal - s.elev)} m para a reavaliação de rank.',
                style: AppTypography.body(size: 10, color: AppColors.text3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLabel('ATRIBUTOS'),
              const SizedBox(height: 14),
              ...s.attrs.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppLabel(a.nome, color: AppColors.text2, size: 9),
                            Text('${a.val}', style: AppTypography.num(size: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppProgressBar(a.val / 100, color: AppColors.green),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: AppButton('EQUIPAMENTO', onTap: () => s.go('inv'))),
            const SizedBox(width: 10),
            Expanded(child: AppButton('CARIMBOS', onTap: () => s.go('ach'))),
          ],
        ),
        const SizedBox(height: 8),
        AppButton('HISTÓRICO MENSAL', onTap: () => s.go('history')),
        const SizedBox(height: 8),
        AppButton('SOLICITAR REAVALIAÇÃO DE RANK', onTap: s.demoRankUp, ink: AppColors.blue),
      ],
    );
  }
}
