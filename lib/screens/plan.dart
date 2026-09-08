import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

const _planTrails = ['PEDRA DO BAÚ', 'TRAVESSIA RUY BRAGA', 'PRATELEIRAS'];

/// Nova expedição: trilha, data e o que a cordada leva.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('NOVA EXPEDIÇÃO',
            sub: 'julho de 2026', onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              const Lbl('TRILHA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              ...List.generate(_planTrails.length, (i) {
                final on = s.planTrail == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Panel(
                    onTap: () => s.setPlanTrail(i),
                    bg: on ? Ink_.raised : Ink_.surface,
                    borderColor: on ? Ink_.borderRaised : Ink_.border,
                    child: Row(
                      children: [
                        Icon(on ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 14, color: on ? Ink_.amber : Ink_.dim),
                        const SizedBox(width: 10),
                        Lbl(_planTrails[i],
                            color: on ? Ink_.text : Ink_.text2, size: 11),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              const Lbl('DATA DE PARTIDA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              Panel(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(14, (i) {
                    final d = i + 8;
                    final on = s.planDate == d;
                    return InkWell(
                      onTap: () => s.setPlanDate(d),
                      borderRadius: r4,
                      child: Container(
                        width: 38,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: on ? Ink_.raised : Ink_.surfaceAlt,
                          border: Border.all(color: on ? Ink_.amber : Ink_.border),
                          borderRadius: r4,
                        ),
                        child: Center(
                          child: Text('$d',
                              style: T.num(
                                  size: 13,
                                  color: on ? Ink_.textStrong : Ink_.text2,
                                  weight: FontWeight.w500)),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 14),
              Btn('CONVOCAR CORDADA', onTap: () => s.go('party'), primary: true),
              const SizedBox(height: 9),
              Text('Ou entre na cordada de alguém — dá para acompanhar sem subir.',
                  textAlign: TextAlign.center,
                  style: T.body(size: 9.5, color: Ink_.dim)),
            ],
          ),
        ),
      ],
    );
  }
}
