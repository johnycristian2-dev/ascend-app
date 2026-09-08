import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';
import '../data/gear.dart';

/// Carimbos: registro do que foi feito, e metas com progresso real.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final feitos = stampData.where((e) => e.pct == null).length;
    return Column(
      children: [
        ScreenBar('CARIMBOS',
            sub: '$feitos de ${stampData.length} conquistados',
            onBack: () => s.go('profile')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: List.generate(stampData.length, (i) {
              final st = stampData[i];
              final done = st.pct == null;
              final open = s.stampIdx == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Opacity(
                  opacity: done ? 1 : .8,
                  child: Panel(
                    onTap: () => s.openStamp(i),
                    bg: done ? Ink_.surface : Ink_.surfaceAlt,
                    borderColor: open ? Ink_.borderRaised : Ink_.border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                                done
                                    ? Icons.verified_outlined
                                    : Icons.radio_button_unchecked,
                                size: 15,
                                color: done ? Ink_.green : Ink_.dim),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Lbl(st.titulo,
                                    color: done ? Ink_.text : Ink_.text3, size: 11)),
                            if (!done) Lbl('${st.pct}%', color: Ink_.dim, size: 9),
                          ],
                        ),
                        if (!done) ...[
                          const SizedBox(height: 10),
                          Bar(st.pct! / 100, color: Ink_.blue),
                        ],
                        if (open) ...[
                          const SizedBox(height: 12),
                          ...st.rows.map((r) => Row2(r[0], r[1])),
                          if (st.rows.isNotEmpty) const SizedBox(height: 8),
                          Text(st.note,
                              style: T.body(size: 10, color: done ? Ink_.text2 : Ink_.text3)),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
