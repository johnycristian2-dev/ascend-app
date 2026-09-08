import 'package:flutter/material.dart';
import '../main.dart';
import '../state/calc.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

/// Caderno: rank, atributos e a meta de desnível da temporada.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 26),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Lbl('CADERNO DE CAMPO', color: Ink_.dim, size: 9, tracking: 0.26),
                  const SizedBox(height: 5),
                  Text(s.name.toUpperCase(), style: T.num(size: 26, color: Ink_.text)),
                  const SizedBox(height: 3),
                  Text(s.baseName, style: T.body(size: 10, color: Ink_.text3)),
                ],
              ),
            ),
            InkWell(
              onTap: () => s.go('settings'),
              borderRadius: r4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Ink_.surface,
                  border: Border.all(color: Ink_.border),
                  borderRadius: r4,
                ),
                child: const Icon(Icons.tune, size: 15, color: Ink_.text2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('RANK ${s.rank}', style: T.num(size: 40, color: Ink_.amber)),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Lbl('NÍVEL ${s.level}', color: Ink_.text2, size: 11),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Lbl('DESNÍVEL DA TEMPORADA', color: Ink_.dim, size: 9),
                  Text('${fmtMil(s.elev)} / ${fmtMil(s.elevGoal)} m',
                      style: T.num(size: 13, color: Ink_.text2)),
                ],
              ),
              const SizedBox(height: 8),
              Bar(s.elev / s.elevGoal, color: Ink_.amber, height: 4),
              const SizedBox(height: 8),
              Text(
                s.elev >= s.elevGoal
                    ? 'Meta batida. A reavaliação de rank abre no próximo registro.'
                    : 'Faltam ${fmtMil(s.elevGoal - s.elev)} m para a reavaliação de rank.',
                style: T.body(size: 10, color: Ink_.text3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Lbl('ATRIBUTOS'),
              const SizedBox(height: 14),
              ...s.attrs.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Lbl(a.nome, color: Ink_.text2, size: 9),
                            Text('${a.val}', style: T.num(size: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Bar(a.val / 100, color: Ink_.green),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Btn('EQUIPAMENTO', onTap: () => s.go('inv'))),
            const SizedBox(width: 10),
            Expanded(child: Btn('CARIMBOS', onTap: () => s.go('ach'))),
          ],
        ),
        const SizedBox(height: 8),
        Btn('HISTÓRICO MENSAL', onTap: () => s.go('history')),
        const SizedBox(height: 8),
        Btn('SOLICITAR REAVALIAÇÃO DE RANK', onTap: s.demoRankUp, ink: Ink_.blue),
      ],
    );
  }
}
