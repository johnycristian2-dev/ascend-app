import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

const _trails = [
  ('TRAVESSIA RUY BRAGA', 'B', '28,4 km · +1 640 m', '2 dias', 'chaminé de 12 m no km 26', 1),
  ('PEDRA DO BAÚ', 'D', '9,2 km · +780 m', '1 dia', 'escadas de ferro expostas', 3),
  ('AGULHAS NEGRAS · FACE SUL', 'A', '14,6 km · +1 180 m', '2 dias', 'gelo vivo de junho a agosto', 2),
  ('PRATELEIRAS', 'C', '11,8 km · +640 m', '1 dia', 'campo de blocos sem marcação', 0),
  ('PICO DOS MARINS', 'C', '12,4 km · +1 020 m', '1 dia', 'vento constante na crista', 0),
];

/// Trilhas por rank: o que está aberto e o que ainda não.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    const order = ['E', 'D', 'C', 'B', 'A', 'S'];
    return Column(
      children: [
        ScreenBar('TRILHAS POR RANK',
            sub: 'seu rank: ${s.rank} · nível ${s.level}',
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: _trails.map((t) {
              final locked = order.indexOf(t.$2) > s.rankIdx;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Opacity(
                  opacity: locked ? .55 : 1,
                  child: Panel(
                    onTap: locked ? null : () => s.go('plan'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Lbl(t.$1, color: Ink_.text, size: 13, tracking: 0.12)),
                            const SizedBox(width: 8),
                            Tag('RANK ${t.$2}',
                                locked ? Ink_.dim : Ink_.amber),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text('${t.$3} · ${t.$4}',
                            style: T.body(size: 10, color: Ink_.text2)),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(locked ? Icons.lock_outline : Icons.warning_amber_rounded,
                                size: 12, color: locked ? Ink_.dim : Ink_.blue),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                locked
                                    ? 'Bloqueada até o rank ${t.$2}.'
                                    : t.$5,
                                style: T.body(size: 9, color: Ink_.text3),
                              ),
                            ),
                          ],
                        ),
                        if (t.$6 > 0) ...[
                          const SizedBox(height: 8),
                          Lbl('${t.$6} ${t.$6 == 1 ? 'RECADO NOVO' : 'RECADOS NOVOS'}',
                              color: Ink_.green, size: 8, tracking: 0.14),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
