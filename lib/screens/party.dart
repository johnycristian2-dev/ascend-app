import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

const _people = [
  ('kai', 'KAI', 'B', 'confirmou · sai hoje'),
  ('nina', 'NINA', 'A', 'confirmou · só após o almoço'),
  ('teo', 'TÉO', 'D', 'não respondeu'),
  ('mai', 'MAI', 'C', 'recusou · trabalho'),
];

const _gear = [
  ('corda', 'CORDA 60 M', '3,4 kg'),
  ('barraca', 'BARRACA 2P', '2,6 kg'),
  ('kit', 'KIT DE SOCORROS', '0,8 kg'),
  ('radio', 'RÁDIO', '0,4 kg'),
  ('fogo', 'FOGAREIRO', '0,9 kg'),
  ('mapa', 'MAPA + BÚSSOLA', '0,1 kg'),
];

/// Convocar cordada: quem vem e quem leva o equipamento coletivo.
class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    const kgs = {'corda': 3.4, 'barraca': 2.6, 'kit': 0.8, 'radio': 0.4, 'fogo': 0.9, 'mapa': 0.1};
    final total = kgs.entries
        .where((e) => s.checked[e.key] ?? false)
        .fold(0.0, (a, e) => a + e.value);
    final missing = kgs.keys.where((k) => !(s.checked[k] ?? false)).length;

    return Column(
      children: [
        ScreenBar('CONVOCAR CORDADA',
            sub: 'Travessia Ruy Braga · partida 12 JUL, 06:00',
            onBack: () => s.go('plan')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              const Lbl('CONVIDADOS', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              ..._people.map((p) {
                final on = s.invited[p.$1] ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Panel(
                    onTap: () => s.toggleInvite(p.$1),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: on ? Ink_.green : Ink_.border),
                            shape: BoxShape.circle,
                          ),
                          child: Lbl(p.$3,
                              color: on ? Ink_.green : Ink_.dim, size: 9, tracking: 0.1),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Lbl(p.$2, color: on ? Ink_.text : Ink_.text3, size: 11),
                              const SizedBox(height: 3),
                              Text(p.$4, style: T.body(size: 9, color: Ink_.dim)),
                            ],
                          ),
                        ),
                        Icon(on ? Icons.check_circle_outline : Icons.circle_outlined,
                            size: 15, color: on ? Ink_.green : Ink_.dim),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              const Lbl('EQUIPAMENTO COLETIVO · QUEM LEVA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              Panel(
                borderColor: missing > 0 ? Ink_.borderWarn : Ink_.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._gear.map((g) {
                      final on = s.checked[g.$1] ?? false;
                      return InkWell(
                        onTap: () => s.toggleCheck(g.$1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Icon(on ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                                  size: 15, color: on ? Ink_.green : Ink_.dim),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Lbl(g.$2,
                                      color: on ? Ink_.text : Ink_.dim, size: 10)),
                              Text(g.$3,
                                  style: T.num(
                                      size: 12,
                                      color: on ? Ink_.text2 : Ink_.dim,
                                      weight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    const Divider(color: Ink_.border, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Lbl('CARGA COLETIVA', color: Ink_.dim, size: 9),
                        Text('${total.toStringAsFixed(1).replaceAll('.', ',')} kg',
                            style: T.num(size: 15)),
                      ],
                    ),
                    if (missing > 0) ...[
                      const SizedBox(height: 10),
                      Text(
                        missing == 1
                            ? 'Falta 1 item coletivo. Ninguém marcou quem leva.'
                            : 'Faltam $missing itens coletivos. Ninguém marcou quem leva.',
                        style: T.body(size: 10, color: Ink_.amber),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Btn('ENVIAR CONVOCAÇÃO', onTap: () => s.go('chat'), primary: true),
            ],
          ),
        ),
      ],
    );
  }
}
