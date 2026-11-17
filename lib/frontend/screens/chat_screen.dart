import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/data/cordada_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Cordada: mensagens e posições, com recado preso ao ponto do mapa.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final cd = s.cordada;
    if (cd == null) return const _SemCordada();
    final total = cd.membros.length + 1;
    final online = cd.membros.where((m) => m.online).length + 1;
    // As mensagens de exemplo são da Cordada Sul; nas outras, só as suas.
    final msgs = cd.id == 'sul' ? s.msgs : s.msgs.where((m) => m.me).toList();
    return Column(
      children: [
        ScreenBar(cd.nome, sub: '$total integrantes · $online online · demonstração'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            children: [
              _Participantes(cd, rank: s.rank),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: AppButton('TROCAR DE CORDADA', onTap: () => s.go('cordadas'))),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton('SAIR DA CORDADA', onTap: s.sairCordada)),
                ],
              ),
              const SizedBox(height: 8),
              AppButton('AMIGOS${s.friendsIn.isEmpty ? '' : ' · ${s.friendsIn.length} PEDIDO(S)'}',
                  onTap: () => s.go('friends')),
              const SizedBox(height: 12),
              ...msgs.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: AppPanel(
                          bg: m.sos ? AppColors.bgWarn : (m.me ? AppColors.raised : AppColors.surface),
                          borderColor: m.sos ? AppColors.amber : (m.me ? AppColors.borderRaised : AppColors.border),
                          padding: const EdgeInsets.all(11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (m.sos) ...[
                                    const Icon(Icons.warning_amber_rounded, size: 11, color: AppColors.amber),
                                    const SizedBox(width: 4),
                                  ],
                                  AppLabel(m.who, color: m.sos ? AppColors.amber : AppColors.text3, size: 8, tracking: 0.16),
                                  const SizedBox(width: 7),
                                  Text(m.time, style: AppTypography.body(size: 8.5, color: AppColors.dim)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(m.text, style: AppTypography.body(size: 11, color: AppColors.text)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 4),
              AppPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(11),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, size: 15, color: AppColors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Integrantes e posições são fictícios (demonstração). Compartilhar a posição com a cordada ainda não existe.',
                              style: AppTypography.body(size: 10.5, color: AppColors.text3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.hair, height: 1),
                    InkWell(
                      onTap: () => s.go('relay'),
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: Row(
                          children: [
                            const Icon(Icons.push_pin_outlined, size: 15, color: AppColors.blue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('Recado fica preso ao ponto do mapa.',
                                  style: AppTypography.body(size: 10.5, color: AppColors.text3)),
                            ),
                            const Icon(Icons.chevron_right, size: 15, color: AppColors.dim),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: AppColors.chrome,
            border: Border(top: BorderSide(color: AppColors.hair)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.borderInput),
                    borderRadius: r4,
                  ),
                  child: TextField(
                    onChanged: s.setDraft,
                    onSubmitted: (_) => s.send(),
                    style: AppTypography.body(size: 11, color: AppColors.text),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
                      hintText: 'Mensagem para a cordada…',
                      hintStyle: AppTypography.body(size: 11, color: AppColors.dim),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 74,
                child: AppButton('ENVIAR', onTap: s.send, primary: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Quem está na cordada: o usuário e os integrantes fictícios.
class _Participantes extends StatelessWidget {
  final Cordada cd;
  final String rank;
  const _Participantes(this.cd, {required this.rank});

  @override
  Widget build(BuildContext c) => AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLabel('INTEGRANTES', size: 9, tracking: 0.26),
            const SizedBox(height: 8),
            _Linha('VOCÊ', rank, 'online', true),
            for (final m in cd.membros) _Linha(m.nome, m.rank, m.status, m.online),
          ],
        ),
      );
}

class _Linha extends StatelessWidget {
  final String nome;
  final String rank;
  final String status;
  final bool online;
  const _Linha(this.nome, this.rank, this.status, this.online);

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: online ? AppColors.green : AppColors.border),
              ),
              child: AppLabel(rank,
                  color: online ? AppColors.green : AppColors.dim, size: 9, tracking: 0.1),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLabel(nome, color: online ? AppColors.text : AppColors.text3, size: 11),
                  const SizedBox(height: 2),
                  Text(status, style: AppTypography.body(size: 9, color: AppColors.dim)),
                ],
              ),
            ),
            Icon(Icons.circle, size: 8, color: online ? AppColors.green : AppColors.dim),
          ],
        ),
      );
}

class _SemCordada extends StatelessWidget {
  const _SemCordada();

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        const ScreenBar('CORDADA', sub: 'você não está em nenhuma'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sem cordada.', style: AppTypography.num(size: 26, color: AppColors.text)),
                const SizedBox(height: 10),
                Text('Entre numa cordada para ver os integrantes e conversar com o grupo.',
                    style: AppTypography.body(size: 11)),
                const SizedBox(height: 20),
                AppButton('VER CORDADAS', onTap: () => s.go('cordadas'), primary: true),
                const SizedBox(height: 8),
                AppButton('AMIGOS', onTap: () => s.go('friends')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
