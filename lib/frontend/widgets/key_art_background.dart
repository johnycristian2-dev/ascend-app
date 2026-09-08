import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fundo de key art com véu gradiente escurecendo até [background] — o
/// "momento de arte" da abertura, do acesso e da nova classificação
/// (ver ESPEC-Flutter.md / chat de design: só essas três telas usam a
/// ilustração cheia, o resto do app permanece instrumento).
class KeyArtBackground extends StatelessWidget {
  /// Opacidade da imagem antes do véu (o protótipo usa .3 a .55).
  final double opacity;

  /// Corte da imagem: `Alignment(0, y)`, `y` = `posição% * 2 - 1`.
  final Alignment alignment;

  /// Paradas do gradiente (0 a 1, de cima pra baixo).
  final List<double> stops;

  /// Opacidade de [background] em cada parada — mesma ordem de [stops].
  final List<double> veilOpacities;

  final Color background;

  const KeyArtBackground({
    required this.opacity,
    required this.alignment,
    required this.stops,
    required this.veilOpacities,
    this.background = AppColors.bg,
    super.key,
  });

  @override
  Widget build(BuildContext c) => Positioned.fill(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: opacity,
              child: Image.asset(
                'assets/art/keyart-limpa.png',
                alignment: alignment,
                fit: BoxFit.cover,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: stops,
                  colors: [for (final o in veilOpacities) background.withValues(alpha: o)],
                ),
              ),
            ),
          ],
        ),
      );
}
