import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';
import '../../backend/data/achievement_catalog.dart';
import '../../backend/data/gear_catalog.dart';

/// Carimbos: conquistas geradas pelo que você realmente fez, e metas
/// roteirizadas com progresso de demonstração.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final feitos = stampData.where((e) => e.pct == null).length;
    return Column(
      children: [
        ScreenBar('CARIMBOS',
            sub: '$feitos de ${stampData.length} conquistados',
            onBack: () => s.go('profile')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              const AppLabel('CONQUISTAS DA SUA JORNADA', size: 9, tracking: 0.26),
              const SizedBox(height: 4),
              Text(
                'Desbloqueadas pelo que você realmente fez no app — não um roteiro.',
                style: AppTypography.body(size: 9.5, color: AppColors.dim),
              ),
              const SizedBox(height: 8),
              ...achievementCatalog.map((a) {
                final done = s.unlockedAchievements.contains(a.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Opacity(
                    opacity: done ? 1 : .6,
                    child: AppPanel(
                      bg: done ? AppColors.bgOk : AppColors.surfaceAlt,
                      borderColor: done ? AppColors.green : AppColors.border,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(done ? Icons.emoji_events_outlined : Icons.lock_outline,
                              size: 15, color: done ? AppColors.green : AppColors.dim),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppLabel(a.title,
                                    color: done ? AppColors.text : AppColors.text3, size: 11),
                                const SizedBox(height: 4),
                                Text(a.description,
                                    style: AppTypography.body(
                                        size: 9.5,
                                        color: done ? AppColors.text2 : AppColors.text3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),
              const AppLabel('METAS DA TEMPORADA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              ...List.generate(stampData.length, (i) {
                final st = stampData[i];
                final done = st.pct == null;
                final open = s.stampIdx == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Opacity(
                    opacity: done ? 1 : .8,
                    child: AppPanel(
                      onTap: () => s.openStamp(i),
                      bg: done ? AppColors.surface : AppColors.surfaceAlt,
                      borderColor: open ? AppColors.borderRaised : AppColors.border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                  done
                                      ? Icons.verified_outlined
                                      : Icons.radio_button_unchecked,
                                  size: 15,
                                  color: done ? AppColors.green : AppColors.dim),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: AppLabel(st.titulo,
                                      color: done ? AppColors.text : AppColors.text3, size: 11)),
                              if (!done) AppLabel('${st.pct}%', color: AppColors.dim, size: 9),
                            ],
                          ),
                          if (!done) ...[
                            const SizedBox(height: 10),
                            AppProgressBar(st.pct! / 100, color: AppColors.blue),
                          ],
                          if (open) ...[
                            const SizedBox(height: 12),
                            ...st.rows.map((r) => TwoColumnRow(r[0], r[1])),
                            if (st.rows.isNotEmpty) const SizedBox(height: 8),
                            Text(st.note,
                                style: AppTypography.body(
                                    size: 10, color: done ? AppColors.text2 : AppColors.text3)),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
