import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_label.dart';

/// Chip de estado (RECOMENDADO, RISCO, TÉCNICO…).
class AppTag extends StatelessWidget {
  final String label;
  final Color ink;
  const AppTag(this.label, this.ink, {super.key});

  @override
  Widget build(BuildContext c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: ink.withValues(alpha: .5)),
          borderRadius: r4,
        ),
        child: AppLabel(label, color: ink, size: 8, tracking: 0.16),
      );
}
