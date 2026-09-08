import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Modo espectador: acompanhar sem subir, com limites de privacidade.
class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('ACOMPANHANDO',
            sub: 'Cordada Sul · Pico dos Marins, face leste · dia 1',
            trailing: 'SOMENTE LEITURA',
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('ÚLTIMA POSIÇÃO CONHECIDA'),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(child: AppStat('ALTITUDE', '1 940 m')),
                        Expanded(child: AppStat('SUBIDA HOJE', '+820 m')),
                        Expanded(child: AppStat('ATUALIZADO', '08:26')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Kai fora de alcance desde 08:26. Nina e Téo em movimento.',
                        style: AppTypography.body(size: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const AppPanel(
                bg: AppColors.surfaceAlt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppLabel('MARCOS DO DIA', color: AppColors.text3, size: 9, tracking: 0.24),
                    SizedBox(height: 10),
                    TwoColumnRow('06:38', 'saída da portaria norte'),
                    TwoColumnRow('07:52', 'fonte do vale · água reposta'),
                    TwoColumnRow('08:26', 'crista leste · último sinal'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppButton(s.cheered ? 'TORCIDA ENVIADA' : 'MANDAR FORÇA',
                  onTap: s.cheer,
                  bg: s.cheered ? AppColors.bgOk : AppColors.raised,
                  border: s.cheered ? AppColors.green : AppColors.borderRaised,
                  ink: s.cheered ? AppColors.green : AppColors.text),
              const SizedBox(height: 9),
              Text(
                'Espectadores não veem posição exata em terreno de queda, nem recebem contato até a cordada marcar o próximo ponto.',
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 9.5, color: AppColors.dim),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
