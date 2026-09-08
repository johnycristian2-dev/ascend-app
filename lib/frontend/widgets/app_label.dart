import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Rótulo caixa-alta espaçado — a voz visual do app.
class AppLabel extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double tracking;
  const AppLabel(this.text,
      {this.color = AppColors.text3, this.size = 10, this.tracking = 0.2, super.key});

  @override
  Widget build(BuildContext c) => Text(text,
      style: AppTypography.label(size: size, color: color, tracking: tracking));
}
