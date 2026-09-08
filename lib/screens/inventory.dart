import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';
import '../data/gear.dart';

/// Equipamento: odômetro real de cada peça e o que ela pede de manutenção.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('EQUIPAMENTO',
            sub: '${gearData.length} peças registradas',
            onBack: () => s.go('profile')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: gearData.map((g) {
              final sel = s.gearSel == g.id;
              final ink = g.wear > 65
                  ? Ink_.amber
                  : g.wear > 40
                      ? Ink_.blue
                      : Ink_.green;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Panel(
                  onTap: () => s.selectGear(g.id),
                  borderColor: sel ? Ink_.borderRaised : Ink_.border,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g.nome, style: T.body(size: 12, color: Ink_.text)),
                                const SizedBox(height: 3),
                                Text(g.spec, style: T.body(size: 9, color: Ink_.dim)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tag(g.tag, Ink_.tagInks[g.tagInk]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Lbl('DESGASTE ${g.wear}%', color: Ink_.dim, size: 9),
                          Text('${g.od} / ${g.lim} ${g.unit}',
                              style: T.num(size: 12, color: Ink_.text2, weight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Bar(g.wear / 100, color: ink),
                      if (sel) ...[
                        const SizedBox(height: 12),
                        Text(g.wearNote, style: T.body(size: 10)),
                        const SizedBox(height: 10),
                        Row2('MANUTENÇÃO', g.svc,
                            ink: g.svc == 'em dia' ? Ink_.green : Ink_.amber),
                        Row2('PRÓXIMA', g.svcAt),
                        Row2('SAÍDAS', '${g.uses}'),
                        Row2('PESO', '${g.kg} kg'),
                      ],
                    ],
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
