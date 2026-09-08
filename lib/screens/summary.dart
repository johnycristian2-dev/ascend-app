import 'package:flutter/material.dart';
import '../main.dart';
import '../data/relay.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';
import '../state/calc.dart';

/// Resumo pós-trilha: o que foi registrado, antes de arquivar.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('TRAVESSIA CONCLUÍDA',
            sub: 'Travessia Ruy Braga · 2 dias',
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              Panel(
                bg: Ink_.bgOk,
                borderColor: Ink_.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('DESNÍVEL REGISTRADO', color: Ink_.green, size: 9, tracking: 0.26),
                    const SizedBox(height: 8),
                    Text('+1 640 m', style: T.num(size: 38, color: Ink_.textStrong)),
                    const SizedBox(height: 10),
                    Text(
                      s.pending
                          ? 'A meta da temporada caiu. Arquivar o registro abre a reavaliação de rank.'
                          : 'Somado à temporada: ${fmtMil(s.elev)} de ${fmtMil(s.elevGoal)} m.',
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
                    const Lbl('O QUE VOCÊ FEZ'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Stat('DISTÂNCIA', '${fmtDec(s.core.km)} km')),
                        Expanded(child: Stat('EM PÉ', fmtHm(s.walk))),
                        Expanded(child: Stat('CARGA', '${fmtDec(s.kg)} kg')),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Ink_.border, height: 1),
                    const SizedBox(height: 10),
                    const Row2('PARTIDA', 'SEX 10 · 05:00'),
                    const Row2('ABRIGO', 'Abrigo 2 · 1 900 m'),
                    const Row2('CUME', '11:40 · 2 421 m'),
                    const Row2('COMPANHEIROS', 'Kai, Nina'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('ATRIBUTOS · GANHO'),
                    const SizedBox(height: 12),
                    ...List.generate(s.attrs.length, (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(child: Lbl(s.attrs[i].nome, color: Ink_.text2, size: 9)),
                              Text('+${ExpeditionStateDeltas.of(i)}',
                                  style: T.num(size: 13, color: Ink_.green)),
                              const SizedBox(width: 10),
                              Text('${s.attrs[i].val}', style: T.num(size: 13)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              if (s.relayDebts.isNotEmpty) ...[
                const SizedBox(height: 10),
                Panel(
                  bg: Ink_.bgWarn,
                  borderColor: Ink_.borderWarn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Lbl(
                          s.relayDebts.length == 1
                              ? 'DÍVIDA DE CONFIRMAÇÃO · 1 RECADO'
                              : 'DÍVIDA DE CONFIRMAÇÃO · ${s.relayDebts.length} RECADOS',
                          color: Ink_.amber,
                          size: 9,
                          tracking: 0.24),
                      const SizedBox(height: 7),
                      Text(
                        'Você usou estes recados de bastão em campo. Confirme se ainda valem antes de arquivar — é o que fecha o ciclo para quem vier depois.',
                        style: T.body(size: 10, color: Ink_.text2),
                      ),
                      const SizedBox(height: 11),
                      ...s.relayDebts.map((i) {
                        final n = relayData[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Lbl('${n.who} · ${n.at}',
                                          color: Ink_.text, size: 10)),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Expanded(
                                    child: Btn('AINDA VALE',
                                        onTap: () => s.voteRelay(i, 'y'),
                                        bg: Ink_.surfaceAlt,
                                        border: Ink_.border,
                                        ink: Ink_.green),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Btn('NÃO ACHEI',
                                        onTap: () => s.voteRelay(i, 'n'),
                                        bg: Ink_.surfaceAlt,
                                        border: Ink_.border,
                                        ink: Ink_.dim),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Btn('DEIXAR RECADO NA ROTA', onTap: () => s.go('relay')),
              const SizedBox(height: 8),
              Btn(
                  s.relayDebts.isNotEmpty
                      ? 'CONFIRME OS RECADOS USADOS'
                      : s.pending
                          ? 'ARQUIVAR E REAVALIAR'
                          : 'ARQUIVAR REGISTRO',
                  onTap: s.relayDebts.isEmpty ? s.fileRecord : null,
                  primary: s.relayDebts.isEmpty,
                  ink: s.relayDebts.isNotEmpty ? Ink_.dim : null,
                  border: s.relayDebts.isNotEmpty ? Ink_.border : null,
                  bg: s.relayDebts.isNotEmpty ? Ink_.surface : null),
            ],
          ),
        ),
      ],
    );
  }
}

/// Ganho fixo por atributo, espelhando o protótipo.
class ExpeditionStateDeltas {
  static int of(int i) => const [4, 3, 5, 2][i];
}
