import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Nova classificação: o rank muda e o que ele abre.
class RankUpScreen extends StatelessWidget {
  const RankUpScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Stack(
      children: [
        const KeyArtBackground(
          opacity: .5,
          alignment: Alignment(0, -0.8),
          stops: [0, .3, .6, 1],
          veilOpacities: [.35, .55, .88, 1],
        ),
        Column(
          children: [
            const ScreenBar('REAVALIAÇÃO', sub: 'meta de desnível concluída'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
                children: [
                  AppPanel(
                    bg: AppColors.bgWarn,
                    borderColor: AppColors.borderWarn,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppLabel('NOVA CLASSIFICAÇÃO',
                            color: AppColors.amber, size: 9, tracking: 0.26),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(s.prevRank,
                                style: AppTypography.num(size: 34, color: AppColors.dim)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Icon(Icons.arrow_forward, size: 18, color: AppColors.text3),
                            ),
                            Text(s.rank,
                                style: AppTypography.num(size: 54, color: AppColors.amber)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Nível ${s.level}. O contador de desnível zera e a temporada recomeça.',
                          style: AppTypography.body(size: 10.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppLabel('O QUE ABRE AGORA'),
                        const SizedBox(height: 12),
                        const TwoColumnRow('TRILHAS', 'rotas do novo rank liberadas'),
                        const TwoColumnRow('BASTÃO', 'pode ancorar recado em rota nova'),
                        const TwoColumnRow('CORDADA', 'pode liderar convocação'),
                        const SizedBox(height: 10),
                        Text(
                          'Rank não expira, mas rota de rank alto sem saída registrada nos últimos 6 meses volta a pedir confirmação de técnica.',
                          style: AppTypography.body(size: 9.5, color: AppColors.dim),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton('VER TRILHAS LIBERADAS', onTap: () => s.go('discover'), primary: true),
                  const SizedBox(height: 8),
                  AppButton('IR PARA O CADERNO', onTap: () => s.go('profile')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
