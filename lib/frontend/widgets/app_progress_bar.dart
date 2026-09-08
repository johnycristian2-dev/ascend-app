import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  final double pct;
  final Color color;
  final double height;
  const AppProgressBar(this.pct, {this.color = AppColors.green, this.height = 3, super.key});

  @override
  Widget build(BuildContext c) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        child: LinearProgressIndicator(
          value: pct.clamp(0, 1),
          minHeight: height,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      );
}
