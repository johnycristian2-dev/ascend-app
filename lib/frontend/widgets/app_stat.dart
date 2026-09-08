import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_label.dart';

/// Rótulo + valor, para grades de estatística.
class AppStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double size;
  const AppStat(this.label, this.value,
      {this.color = AppColors.textStrong, this.size = 21, super.key});

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabel(label, color: AppColors.dim, size: 9),
          const SizedBox(height: 5),
          Text(value, style: AppTypography.num(size: size, color: color)),
        ],
      );
}
