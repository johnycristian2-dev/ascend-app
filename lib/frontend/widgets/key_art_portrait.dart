import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Recorte do rosto na key art, usado como retrato no caderno de expedição
/// e nas configurações de perfil — o mesmo enquadramento do protótipo
/// (`45% 4% / 230%`), só que via `Transform.scale` em vez de
/// `background-size`, que o Flutter não tem.
class KeyArtPortrait extends StatelessWidget {
  final double width;
  final double height;
  const KeyArtPortrait({this.width = 72, this.height = 88, super.key});

  @override
  Widget build(BuildContext c) => Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: r4,
        ),
        child: Transform.scale(
          scale: 2.3,
          alignment: const Alignment(-0.1, -0.92),
          child: Image.asset('assets/art/keyart-limpa.png', fit: BoxFit.cover),
        ),
      );
}
