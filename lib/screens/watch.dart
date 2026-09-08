import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

/// Modo espectador: acompanhar sem subir, com limites de privacidade.
class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('ACOMPANHANDO',
            sub: 'Cordada Sul · Pico dos Marins, face leste · dia 1',
            trailing: 'SOMENTE LEITURA',
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('ÚLTIMA POSIÇÃO CONHECIDA'),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: Stat('ALTITUDE', '1 940 m')),
                        Expanded(child: Stat('SUBIDA HOJE', '+820 m')),
                        Expanded(child: Stat('ATUALIZADO', '08:26')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Kai fora de alcance desde 08:26. Nina e Téo em movimento.',
                        style: T.body(size: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Panel(
                bg: Ink_.surfaceAlt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('MARCOS DO DIA', color: Ink_.text3, size: 9, tracking: 0.24),
                    const SizedBox(height: 10),
                    const Row2('06:38', 'saída da portaria norte'),
                    const Row2('07:52', 'fonte do vale · água reposta'),
                    const Row2('08:26', 'crista leste · último sinal'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Btn(s.cheered ? 'TORCIDA ENVIADA' : 'MANDAR FORÇA',
                  onTap: s.cheer,
                  bg: s.cheered ? Ink_.bgOk : Ink_.raised,
                  border: s.cheered ? Ink_.green : Ink_.borderRaised,
                  ink: s.cheered ? Ink_.green : Ink_.text),
              const SizedBox(height: 9),
              Text(
                'Espectadores não veem posição exata em terreno de queda, nem recebem contato até a cordada marcar o próximo ponto.',
                textAlign: TextAlign.center,
                style: T.body(size: 9.5, color: Ink_.dim),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
