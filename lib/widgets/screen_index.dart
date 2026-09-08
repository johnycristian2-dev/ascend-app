import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import 'atoms.dart';

/// Índice das 20 telas — atalho de navegação para revisão do protótipo.
const screenJumps = <(String, String)>[
  ('01 · Abertura', 'splash'),
  ('02 · Mapa da trilha', 'home'),
  ('03 · Detalhes da rota', 'route'),
  ('04 · Caderno / Perfil', 'profile'),
  ('05 · Equipamento', 'inv'),
  ('06 · Carimbos', 'ach'),
  ('07 · Cordada / Chat', 'chat'),
  ('08 · Resumo pós-trilha', 'summary'),
  ('09 · Nova classificação', 'rankup'),
  ('10 · Trilhas por rank', 'discover'),
  ('11 · Avaliação inicial', 'onboard'),
  ('12 · Convocar cordada', 'party'),
  ('13 · Histórico mensal', 'history'),
  ('14 · Acesso / cadastro', 'auth'),
  ('15 · Nova expedição', 'plan'),
  ('16 · Modo espectador', 'watch'),
  ('17 · Primeiro acesso (vazio)', 'empty'),
  ('18 · Janela de tempo', 'window'),
  ('19 · Passagem de bastão', 'relay'),
  ('20 · Peso da mochila', 'pack'),
];

class ScreenIndexButton extends StatelessWidget {
  const ScreenIndexButton({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.readOf(c);
    return Padding(
      padding: const EdgeInsets.only(bottom: 58),
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: c,
          backgroundColor: Ink_.surfaceAlt,
          builder: (_) => SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Lbl('ÍNDICE DE TELAS', color: Ink_.text3, size: 9, tracking: 0.26),
                const SizedBox(height: 10),
                ...screenJumps.map((j) => InkWell(
                      onTap: () {
                        Navigator.pop(c);
                        j.$2 == 'empty' ? s.goEmptyHome() : s.go(j.$2);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Lbl(j.$1, color: Ink_.text2, size: 10),
                      ),
                    )),
              ],
            ),
          ),
        ),
        borderRadius: r4,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Ink_.surface,
            border: Border.all(color: Ink_.border),
            borderRadius: r4,
          ),
          child: const Icon(Icons.list, size: 16, color: Ink_.text3),
        ),
      ),
    );
  }
}
