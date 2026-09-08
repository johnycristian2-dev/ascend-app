import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_label.dart';

/// Cabeçalho de tela: voltar + título + informação à direita.
class ScreenBar extends StatelessWidget {
  final String title;
  final String? sub;
  final String? trailing;
  final VoidCallback? onBack;
  const ScreenBar(this.title, {this.sub, this.trailing, this.onBack, super.key});

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (onBack != null) ...[
              InkWell(
                onTap: onBack,
                borderRadius: r4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: r4,
                  ),
                  child: const Icon(Icons.arrow_back, size: 15, color: AppColors.text),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLabel(title, color: AppColors.text, size: 17, tracking: 0.16),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(sub!, style: AppTypography.body(size: 10, color: AppColors.text3)),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: r4,
                ),
                child: AppLabel(trailing!, color: AppColors.dim, size: 9, tracking: 0.16),
              ),
          ],
        ),
      );
}
