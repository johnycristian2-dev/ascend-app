import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

const _questions = [
  (
    '1 DE 3',
    'Qual foi o maior desnível que você subiu em um dia?',
    'Desnível pesa mais que distância na classificação inicial.',
    [('Menos de 500 m', '', 0), ('500 a 1 000 m', '', 1), ('Mais de 1 000 m', 'com carga', 2)],
  ),
  (
    '2 DE 3',
    'Já dormiu em barraca acima de 1 500 m?',
    'Noite em altitude muda o que você pode planejar sozinho.',
    [('Nunca', '', 0), ('Uma ou duas vezes', '', 1), ('Várias', 'inclusive no frio', 2)],
  ),
  (
    '3 DE 3',
    'Sabe usar crampons e piqueta em terreno de gelo?',
    'Sem treino formal, rotas de rank B ou acima ficam bloqueadas.',
    [('Nunca usei', '', 0), ('Já experimentei', 'sem curso', 1), ('Uso com segurança', 'com curso', 2)],
  ),
];

/// Avaliação inicial: três perguntas que definem o rank de partida.
class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});
  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  int step = 0;
  final answers = <int>[];

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    if (step >= _questions.length) {
      final sum = answers.fold(0, (a, b) => a + b);
      final rankIdx = sum <= 2 ? 0 : sum <= 5 ? 1 : 2; // E, D, C
      final rank = ranks[rankIdx];
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLabel('CLASSIFICAÇÃO INICIAL', color: AppColors.dim, size: 9, tracking: 0.26),
            const SizedBox(height: 12),
            Text('RANK $rank', style: AppTypography.num(size: 54, color: AppColors.amber)),
            const SizedBox(height: 14),
            Text(
              'Você começa aqui. O rank sobe com desnível registrado e travessias concluídas, não com tempo de uso.',
              style: AppTypography.body(size: 11),
            ),
            const SizedBox(height: 24),
            AppButton('VER TRILHAS DO MEU RANK',
                onTap: () => s.completeOnboarding(rankIdx: rankIdx, goTo: 'discover'),
                primary: true),
            const SizedBox(height: 8),
            AppButton('IR PARA O MAPA',
                onTap: () => s.completeOnboarding(rankIdx: rankIdx, goTo: 'home')),
          ],
        ),
      );
    }

    final q = _questions[step];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          AppLabel(q.$1, color: AppColors.dim, size: 9, tracking: 0.26),
          const SizedBox(height: 10),
          AppProgressBar((step + 1) / _questions.length, color: AppColors.amber),
          const SizedBox(height: 26),
          Text(q.$2, style: AppTypography.num(size: 24, color: AppColors.text)),
          const SizedBox(height: 10),
          Text(q.$3, style: AppTypography.body(size: 11)),
          const SizedBox(height: 22),
          ...q.$4.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppPanel(
                  onTap: () => setState(() {
                    answers.add(o.$3);
                    step++;
                  }),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.$1, style: AppTypography.body(size: 12, color: AppColors.text)),
                            if (o.$2.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(o.$2, style: AppTypography.body(size: 9, color: AppColors.dim)),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.dim),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
