import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_label.dart';

/// Campo de formulário somente-leitura, para telas de demonstração.
class AppTextField extends StatelessWidget {
  final String label;
  final String value;
  const AppTextField({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabel(label, color: AppColors.dim, size: 9),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderInput),
              borderRadius: r4,
            ),
            child: Text(value, style: AppTypography.body(size: 11, color: AppColors.text)),
          ),
        ],
      );
}
