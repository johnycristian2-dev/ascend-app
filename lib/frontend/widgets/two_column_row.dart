import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_label.dart';

/// Linha rótulo/valor usada em listas de detalhe.
class TwoColumnRow extends StatelessWidget {
  final String label;
  final String value;
  final Color ink;
  const TwoColumnRow(this.label, this.value, {this.ink = AppColors.text, super.key});

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppLabel(label.toUpperCase(), color: AppColors.dim, size: 9),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right, style: AppTypography.body(size: 10, color: ink)),
            ),
          ],
        ),
      );
}
