import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/data/relay_notes.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';
import '../../backend/state/expedition_calculator.dart';

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
              AppPanel(
                bg: AppColors.bgOk,
                borderColor: AppColors.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('DESNÍVEL REGISTRADO', color: AppColors.green, size: 9, tracking: 0.26),
                    const SizedBox(height: 8),
                    Text('+1 640 m', style: AppTypography.num(size: 38, color: AppColors.textStrong)),
                    const SizedBox(height: 10),
                    Text(
                      s.pending
                          ? 'A meta da temporada caiu. Arquivar o registro abre a reavaliação de rank.'
                          : 'Somado à temporada: ${fmtMil(s.elev)} de ${fmtMil(s.elevGoal)} m.',
                      style: AppTypography.body(size: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('O QUE VOCÊ FEZ'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: AppStat('DISTÂNCIA', '${fmtDec(s.core.km)} km')),
                        Expanded(child: AppStat('EM PÉ', fmtHm(s.walk))),
                        Expanded(child: AppStat('CARGA', '${fmtDec(s.kg)} kg')),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 10),
                    const TwoColumnRow('PARTIDA', 'SEX 10 · 05:00'),
                    const TwoColumnRow('ABRIGO', 'Abrigo 2 · 1 900 m'),
                    const TwoColumnRow('CUME', '11:40 · 2 421 m'),
                    const TwoColumnRow('COMPANHEIROS', 'Kai, Nina'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('ATRIBUTOS · GANHO'),
                    const SizedBox(height: 12),
                    ...List.generate(s.attrs.length, (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(child: AppLabel(s.attrs[i].nome, color: AppColors.text2, size: 9)),
                              Text('+${ExpeditionStateDeltas.of(i)}',
                                  style: AppTypography.num(size: 13, color: AppColors.green)),
                              const SizedBox(width: 10),
                              Text('${s.attrs[i].val}', style: AppTypography.num(size: 13)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              if (s.relayDebts.isNotEmpty) ...[
                const SizedBox(height: 10),
                AppPanel(
                  bg: AppColors.bgWarn,
                  borderColor: AppColors.borderWarn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppLabel(
                          s.relayDebts.length == 1
                              ? 'DÍVIDA DE CONFIRMAÇÃO · 1 RECADO'
                              : 'DÍVIDA DE CONFIRMAÇÃO · ${s.relayDebts.length} RECADOS',
                          color: AppColors.amber,
                          size: 9,
                          tracking: 0.24),
                      const SizedBox(height: 7),
                      Text(
                        'Você usou estes recados de bastão em campo. Confirme se ainda valem antes de arquivar — é o que fecha o ciclo para quem vier depois.',
                        style: AppTypography.body(size: 10, color: AppColors.text2),
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
                                      child: AppLabel('${n.who} · ${n.at}',
                                          color: AppColors.text, size: 10)),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton('AINDA VALE',
                                        onTap: () => s.voteRelay(i, 'y'),
                                        bg: AppColors.surfaceAlt,
                                        border: AppColors.border,
                                        ink: AppColors.green),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppButton('NÃO ACHEI',
                                        onTap: () => s.voteRelay(i, 'n'),
                                        bg: AppColors.surfaceAlt,
                                        border: AppColors.border,
                                        ink: AppColors.dim),
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
              AppButton('DEIXAR RECADO NA ROTA', onTap: () => s.go('relay')),
              const SizedBox(height: 8),
              AppButton(
                  s.relayDebts.isNotEmpty
                      ? 'CONFIRME OS RECADOS USADOS'
                      : s.pending
                          ? 'ARQUIVAR E REAVALIAR'
                          : 'ARQUIVAR REGISTRO',
                  onTap: s.relayDebts.isEmpty ? s.fileRecord : null,
                  primary: s.relayDebts.isEmpty,
                  ink: s.relayDebts.isNotEmpty ? AppColors.dim : null,
                  border: s.relayDebts.isNotEmpty ? AppColors.border : null,
                  bg: s.relayDebts.isNotEmpty ? AppColors.surface : null),
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
