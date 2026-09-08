import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

/// Nova classificação: o rank muda e o que ele abre.
class RankUpScreen extends StatelessWidget {
  const RankUpScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        const ScreenBar('REAVALIAÇÃO', sub: 'meta de desnível concluída'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              Panel(
                bg: Ink_.bgWarn,
                borderColor: Ink_.borderWarn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('NOVA CLASSIFICAÇÃO',
                        color: Ink_.amber, size: 9, tracking: 0.26),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(s.prevRank, style: T.num(size: 34, color: Ink_.dim)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Icon(Icons.arrow_forward, size: 18, color: Ink_.text3),
                        ),
                        Text(s.rank, style: T.num(size: 54, color: Ink_.amber)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Nível ${s.level}. O contador de desnível zera e a temporada recomeça.',
                      style: T.body(size: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('O QUE ABRE AGORA'),
                    const SizedBox(height: 12),
                    const Row2('TRILHAS', 'rotas do novo rank liberadas'),
                    const Row2('BASTÃO', 'pode ancorar recado em rota nova'),
                    const Row2('CORDADA', 'pode liderar convocação'),
                    const SizedBox(height: 10),
                    Text(
                      'Rank não expira, mas rota de rank alto sem saída registrada nos últimos 6 meses volta a pedir confirmação de técnica.',
                      style: T.body(size: 9.5, color: Ink_.dim),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Btn('VER TRILHAS LIBERADAS', onTap: () => s.go('discover'), primary: true),
              const SizedBox(height: 8),
              Btn('IR PARA O CADERNO', onTap: () => s.go('profile')),
            ],
          ),
        ),
      ],
    );
  }
}
