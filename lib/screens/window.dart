import 'package:flutter/material.dart';
import '../main.dart';
import '../data/wx.dart';
import '../state/calc.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

/// Janela de tempo: escolher a partida recalcula carga, rota e luz.
class WindowScreen extends StatelessWidget {
  const WindowScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('JANELA DE TEMPO',
            sub: 'previsão de 72 h · Travessia Ruy Braga',
            trailing: fmtClock(s.wxSec),
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('BLOCOS DE 6 H · VENTO E TETO',
                        size: 9, tracking: 0.26),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 62,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: wxBlocks.map((b) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1.5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 12 + b.wind * .62,
                                    decoration: BoxDecoration(
                                      color: Ink_.q[b.q].withValues(alpha: .8),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(2)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: wxBlocks
                          .map((b) => Expanded(
                                child: Center(
                                  child: Lbl(b.h,
                                      color: Ink_.dim, size: 7, tracking: 0.1),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Legend('BOM', Ink_.green),
                        const SizedBox(width: 12),
                        _Legend('MARGINAL', Ink_.blue),
                        const SizedBox(width: 12),
                        _Legend('RUIM', Ink_.amber),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Lbl('ESCOLHA A PARTIDA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              ...List.generate(wxSlots.length, (i) {
                final w = wxSlots[i];
                final meta = slotMeta[i];
                final on = s.wxPick == i;
                final arrive = addTime(meta.dep, s.day1);
                final dark = isDark(arrive, meta.lightPct);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Panel(
                    onTap: () => s.pickWx(i),
                    bg: on ? Ink_.raised : Ink_.surfaceAlt,
                    borderColor: on ? Ink_.borderRaised : Ink_.border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Lbl(w.label,
                                      color: on ? Ink_.textStrong : Ink_.text,
                                      size: 14,
                                      tracking: 0.12),
                                  const SizedBox(height: 3),
                                  Text(w.sub, style: T.body(size: 9, color: Ink_.dim)),
                                ],
                              ),
                            ),
                            Tag(w.tag, Ink_.tagInks[w.tagInk]),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(w.note, style: T.body(size: 10)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Stat('CHEGADA', arrive,
                                  size: 15,
                                  color: dark ? Ink_.amber : Ink_.textStrong),
                            ),
                            Expanded(
                                child: Stat('NOITE',
                                    '${meta.nightM > 0 ? '+' : ''}${meta.nightM} °C',
                                    size: 15)),
                            Expanded(
                              child: Stat('LUZ', '${meta.lightPct}%',
                                  size: 15,
                                  color: meta.lightPct < 60 ? Ink_.amber : Ink_.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(meta.sleep, style: T.body(size: 9, color: Ink_.text3)),
                        if (meta.noturna) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.flashlight_on_outlined,
                                  size: 12, color: Ink_.amber),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Lbl(
                                    'FRONTAL OBRIGATÓRIA · ${6 - int.parse(meta.dep.split(':')[0])} H NO ESCURO ANTES DA LUZ',
                                    color: Ink_.amber,
                                    size: 8,
                                    tracking: 0.14),
                              ),
                            ],
                          ),
                        ],
                        if (on) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: Ink_.surfaceAlt,
                              border: Border.all(
                                  color: const Color(0xFF3A424C), style: BorderStyle.solid),
                              borderRadius: r4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Lbl('O QUE A CORDADA VÊ',
                                    color: Ink_.text3, size: 9, tracking: 0.24),
                                const SizedBox(height: 6),
                                Text(w.social, style: T.body(size: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Btn(w.cta, onTap: () => s.go('route'), primary: true),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 4),
              const Lbl('EXIGÊNCIAS DA PARTIDA ESCOLHIDA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              Panel(
                borderColor: s.core.conflicts.isEmpty ? Ink_.border : Ink_.borderWarn,
                child: Column(
                  children: s.slot.needs.map((n) {
                    final falta = s.packOut.contains(n);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(falta ? Icons.close : Icons.check,
                              size: 13, color: falta ? Ink_.amber : Ink_.green),
                          const SizedBox(width: 9),
                          Expanded(child: Lbl(n, color: Ink_.text, size: 10)),
                          Lbl(falta ? 'EM CASA' : 'NA MOCHILA',
                              color: falta ? Ink_.amber : Ink_.green, size: 8),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color ink;
  const _Legend(this.label, this.ink);

  @override
  Widget build(BuildContext c) => Row(
        children: [
          Container(width: 8, height: 8, color: ink),
          const SizedBox(width: 5),
          Lbl(label, color: Ink_.dim, size: 8, tracking: 0.14),
        ],
      );
}
