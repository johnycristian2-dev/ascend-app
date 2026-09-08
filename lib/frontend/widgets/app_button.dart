import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_label.dart';

/// Botão retangular. `primary` usa a superfície mais clara do protótipo.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final Color? ink;
  final Color? bg;
  final Color? border;
  const AppButton(this.label,
      {this.onTap, this.primary = false, this.ink, this.bg, this.border, super.key});

  @override
  Widget build(BuildContext c) => InkWell(
        onTap: onTap,
        borderRadius: r4,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: bg ?? (primary ? AppColors.raised : AppColors.surface),
            border: Border.all(color: border ?? (primary ? AppColors.borderRaised : AppColors.border)),
            borderRadius: r4,
          ),
          child: Center(
            child: AppLabel(label,
                color: ink ?? (primary ? AppColors.text : AppColors.text2),
                size: 11,
                tracking: 0.16),
          ),
        ),
      );
}
