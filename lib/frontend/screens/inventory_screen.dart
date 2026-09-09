import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';
import '../../backend/data/gear_catalog.dart';

/// Equipamento: odômetro real de cada peça e o que ela pede de manutenção.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('EQUIPAMENTO',
            sub: '${gearData.length} peças registradas',
            onBack: () => s.go('profile')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: gearData.map((g) {
              final sel = s.gearSel == g.id;
              final usage = s.gearUsage(g.id);
              final ink = usage.wear > 65
                  ? AppColors.amber
                  : usage.wear > 40
                      ? AppColors.blue
                      : AppColors.green;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppPanel(
                  onTap: () => s.selectGear(g.id),
                  borderColor: sel ? AppColors.borderRaised : AppColors.border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g.nome, style: AppTypography.body(size: 12, color: AppColors.text)),
                                const SizedBox(height: 3),
                                Text(g.spec, style: AppTypography.body(size: 9, color: AppColors.dim)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppTag(g.tag, AppColors.tagInks[g.tagInk]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppLabel('DESGASTE ${usage.wear}%', color: AppColors.dim, size: 9),
                          Text('${usage.od} / ${g.lim} ${g.unit}',
                              style: AppTypography.num(size: 12, color: AppColors.text2, weight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 7),
                      AppProgressBar(usage.wear / 100, color: ink),
                      if (sel) ...[
                        const SizedBox(height: 12),
                        Text(g.wearNote, style: AppTypography.body(size: 10)),
                        const SizedBox(height: 10),
                        TwoColumnRow('MANUTENÇÃO', g.svc,
                            ink: g.svc == 'em dia' ? AppColors.green : AppColors.amber),
                        TwoColumnRow('PRÓXIMA', g.svcAt),
                        TwoColumnRow('SAÍDAS', '${usage.uses}'),
                        TwoColumnRow('PESO', '${g.kg} kg'),
                        const SizedBox(height: 10),
                        AppButton('REGISTRAR SAÍDA', onTap: () => s.logGearOuting(g.id)),
                      ],
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
