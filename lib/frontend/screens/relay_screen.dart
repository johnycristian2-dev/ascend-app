import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/data/relay_notes.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Passagem de bastão: o que o mapa não conta, deixado por quem passou antes.
class RelayScreen extends StatelessWidget {
  const RelayScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('PASSAGEM DE BASTÃO',
            sub: '${s.relayCount} recados deixados nesta rota',
            trailing: '${s.routeTrust.pct}% CONFIÁVEL',
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              // Pinos ancorados por quilômetro.
              Row(
                children: List.generate(relayData.length, (i) {
                  final on = s.relaySel == i;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: AppPanel(
                        onTap: () => s.pickPin(i),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        bg: on ? AppColors.raised : AppColors.surfaceAlt,
                        borderColor: on ? AppColors.blue : const Color(0xFF242930),
                        child: Column(
                          children: [
                            Text(relayData[i].km,
                                style: AppTypography.num(
                                    size: 12,
                                    color: on ? AppColors.textStrong : AppColors.text2,
                                    weight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            AppLabel(relayData[i].who.split(' ')[0],
                                color: AppColors.dim, size: 7, tracking: 0.1),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              ...List.generate(relayData.length, (i) {
                final n = relayData[i];
                final v = s.relayVote[i];
                final sel = s.relaySel == i;
                final conf = n.conf + (v == 'y' ? 1 : 0);
                return Opacity(
                  // Recado apaga de forma contínua conforme o tempo desde a
                  // última confirmação — nunca um aviso, só o próprio traço
                  // ficando mais claro. Confirmar agora devolve a opacidade plena.
                  opacity: sel ? 1 : n.fadeOpacity(diasOverride: v == 'y' ? 0 : null),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppPanel(
                      onTap: () => s.pickPin(i),
                      borderColor: sel
                          ? AppColors.blue
                          : n.stale
                              ? AppColors.borderStale
                              : AppColors.border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: n.stale ? AppColors.dim : AppColors.green),
                                  shape: BoxShape.circle,
                                ),
                                child: AppLabel(n.rank,
                                    color: n.stale ? AppColors.dim : AppColors.green,
                                    size: 9,
                                    tracking: 0.1),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppLabel(n.who, color: AppColors.text, size: 11),
                                    const SizedBox(height: 3),
                                    Text('${n.at} · ${n.ago}',
                                        style: AppTypography.body(size: 9, color: AppColors.dim)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 11),
                          Text(n.text, style: AppTypography.body(size: 10.5, height: 1.55)),
                          const SizedBox(height: 10),
                          Text(
                            v == 'n'
                                ? 'você marcou como não encontrado'
                                : '$conf confirmações · última ${v == 'y' ? 'agora' : n.last}',
                            style: AppTypography.body(size: 9, color: AppColors.dim),
                          ),
                          if (sel) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(v == 'y' ? 'CONFIRMADO' : 'AINDA VALE',
                                      onTap: () => s.voteRelay(i, 'y'),
                                      bg: v == 'y' ? AppColors.bgOk : AppColors.surfaceAlt,
                                      border: v == 'y' ? AppColors.green : AppColors.border,
                                      ink: v == 'y' ? AppColors.green : AppColors.text2),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppButton(v == 'n' ? 'REGISTRADO' : 'NÃO ACHEI',
                                      onTap: () => s.voteRelay(i, 'n'),
                                      bg: v == 'n' ? AppColors.bgWarn : AppColors.surfaceAlt,
                                      border: v == 'n' ? AppColors.borderWarn : AppColors.border,
                                      ink: v == 'n' ? AppColors.amber : AppColors.dim),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              AppPanel(
                bg: AppColors.surfaceAlt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppLabel('DEIXAR PARA QUEM VEM',
                            color: AppColors.text3, size: 9, tracking: 0.24),
                        Text('${s.relayDraft.length} / 180',
                            style: AppTypography.body(size: 9.5, color: AppColors.dim)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text('preso em VALE DAS PEDRAS · 1 620 m — onde você está agora',
                        style: AppTypography.body(size: 10, color: AppColors.dim)),
                    const SizedBox(height: 9),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.borderInput),
                        borderRadius: r4,
                      ),
                      child: TextField(
                        maxLines: 3,
                        maxLength: 180,
                        onChanged: s.setRelayDraft,
                        style: AppTypography.body(size: 11, color: AppColors.text),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(11),
                          hintText: 'O que você viu que o mapa não conta.',
                          hintStyle: AppTypography.body(size: 11, color: AppColors.dim),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    AppButton(
                      s.relaySent
                          ? 'RECADO ANCORADO · AGUARDA CONFIRMAÇÃO'
                          : s.relayDraft.trim().isNotEmpty
                              ? 'ANCORAR NESTE PONTO'
                              : 'ESCREVA ALGO ÚTIL',
                      onTap: s.sendRelay,
                      bg: s.relaySent
                          ? AppColors.bgOk
                          : s.relayDraft.trim().isNotEmpty
                              ? AppColors.raised
                              : AppColors.surfaceAlt,
                      border: s.relaySent
                          ? AppColors.green
                          : s.relayDraft.trim().isNotEmpty
                              ? AppColors.borderRaised
                              : AppColors.border,
                      ink: s.relaySent
                          ? AppColors.green
                          : s.relayDraft.trim().isNotEmpty
                              ? AppColors.text
                              : AppColors.dim,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Só quem arquivou a rota inteira pode ancorar recado. Recado sem confirmação por 6 meses vai apagando.',
                      style: AppTypography.body(size: 9.5, color: AppColors.dim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
