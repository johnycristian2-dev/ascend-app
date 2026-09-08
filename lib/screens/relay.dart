import 'package:flutter/material.dart';
import '../main.dart';
import '../data/relay.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

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
                      child: Panel(
                        onTap: () => s.pickPin(i),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        bg: on ? Ink_.raised : Ink_.surfaceAlt,
                        borderColor: on ? Ink_.blue : const Color(0xFF242930),
                        child: Column(
                          children: [
                            Text(relayData[i].km,
                                style: T.num(
                                    size: 12,
                                    color: on ? Ink_.textStrong : Ink_.text2,
                                    weight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Lbl(relayData[i].who.split(' ')[0],
                                color: Ink_.dim, size: 7, tracking: 0.1),
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
                    child: Panel(
                      onTap: () => s.pickPin(i),
                      borderColor: sel
                          ? Ink_.blue
                          : n.stale
                              ? Ink_.borderStale
                              : Ink_.border,
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
                                      color: n.stale ? Ink_.dim : Ink_.green),
                                  shape: BoxShape.circle,
                                ),
                                child: Lbl(n.rank,
                                    color: n.stale ? Ink_.dim : Ink_.green,
                                    size: 9,
                                    tracking: 0.1),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Lbl(n.who, color: Ink_.text, size: 11),
                                    const SizedBox(height: 3),
                                    Text('${n.at} · ${n.ago}',
                                        style: T.body(size: 9, color: Ink_.dim)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 11),
                          Text(n.text, style: T.body(size: 10.5, height: 1.55)),
                          const SizedBox(height: 10),
                          Text(
                            v == 'n'
                                ? 'você marcou como não encontrado'
                                : '$conf confirmações · última ${v == 'y' ? 'agora' : n.last}',
                            style: T.body(size: 9, color: Ink_.dim),
                          ),
                          if (sel) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Btn(v == 'y' ? 'CONFIRMADO' : 'AINDA VALE',
                                      onTap: () => s.voteRelay(i, 'y'),
                                      bg: v == 'y' ? Ink_.bgOk : Ink_.surfaceAlt,
                                      border: v == 'y' ? Ink_.green : Ink_.border,
                                      ink: v == 'y' ? Ink_.green : Ink_.text2),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Btn(v == 'n' ? 'REGISTRADO' : 'NÃO ACHEI',
                                      onTap: () => s.voteRelay(i, 'n'),
                                      bg: v == 'n' ? Ink_.bgWarn : Ink_.surfaceAlt,
                                      border: v == 'n' ? Ink_.borderWarn : Ink_.border,
                                      ink: v == 'n' ? Ink_.amber : Ink_.dim),
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
              Panel(
                bg: Ink_.surfaceAlt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Lbl('DEIXAR PARA QUEM VEM',
                            color: Ink_.text3, size: 9, tracking: 0.24),
                        Text('${s.relayDraft.length} / 180',
                            style: T.body(size: 9.5, color: Ink_.dim)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text('preso em VALE DAS PEDRAS · 1 620 m — onde você está agora',
                        style: T.body(size: 10, color: Ink_.dim)),
                    const SizedBox(height: 9),
                    Container(
                      decoration: BoxDecoration(
                        color: Ink_.surface,
                        border: Border.all(color: Ink_.borderInput),
                        borderRadius: r4,
                      ),
                      child: TextField(
                        maxLines: 3,
                        maxLength: 180,
                        onChanged: s.setRelayDraft,
                        style: T.body(size: 11, color: Ink_.text),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(11),
                          hintText: 'O que você viu que o mapa não conta.',
                          hintStyle: T.body(size: 11, color: Ink_.dim),
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Btn(
                      s.relaySent
                          ? 'RECADO ANCORADO · AGUARDA CONFIRMAÇÃO'
                          : s.relayDraft.trim().isNotEmpty
                              ? 'ANCORAR NESTE PONTO'
                              : 'ESCREVA ALGO ÚTIL',
                      onTap: s.sendRelay,
                      bg: s.relaySent
                          ? Ink_.bgOk
                          : s.relayDraft.trim().isNotEmpty
                              ? Ink_.raised
                              : Ink_.surfaceAlt,
                      border: s.relaySent
                          ? Ink_.green
                          : s.relayDraft.trim().isNotEmpty
                              ? Ink_.borderRaised
                              : Ink_.border,
                      ink: s.relaySent
                          ? Ink_.green
                          : s.relayDraft.trim().isNotEmpty
                              ? Ink_.text
                              : Ink_.dim,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Só quem arquivou a rota inteira pode ancorar recado. Recado sem confirmação por 6 meses vai apagando.',
                      style: T.body(size: 9.5, color: Ink_.dim),
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
