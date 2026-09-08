import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Card padrão: superfície, borda de 1 px, raio 4.
class AppPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? bg;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool dashed;
  const AppPanel({
    required this.child,
    this.padding = const EdgeInsets.all(13),
    this.bg,
    this.borderColor,
    this.onTap,
    this.dashed = false,
    super.key,
  });

  @override
  Widget build(BuildContext c) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: bg ?? AppColors.surface,
        border: Border.all(color: borderColor ?? AppColors.border),
        borderRadius: r4,
      ),
      child: child,
    );
    return onTap == null
        ? box
        : InkWell(onTap: onTap, borderRadius: r4, child: box);
  }
}
