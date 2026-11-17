import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/data/friends_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Amigos: de onde saem as pessoas das cordadas.
///
/// DEMONSTRAÇÃO: as pessoas são fictícias (friends_catalog.dart). O fluxo é
/// o real — buscar, pedir, aceitar, remover — e o que ele alimenta também:
/// só amigos entram numa cordada montada pelo usuário.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String _q = '';

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final q = _q.trim().toLowerCase();
    final achados = [
      for (final p in peopleDemo)
        if (!s.ehAmigo(p.id) &&
            !s.friendsIn.contains(p.id) &&
            (q.isEmpty || p.nome.toLowerCase().contains(q) || p.regiao.toLowerCase().contains(q)))
          p
    ];
    return Column(
      children: [
        ScreenBar('AMIGOS', sub: 'demonstração · pessoas fictícias', onBack: () => s.go('chat')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              if (s.friendsIn.isNotEmpty) ...[
                const AppLabel('PEDIDOS RECEBIDOS', color: AppColors.amber, size: 9, tracking: 0.26),
                const SizedBox(height: 8),
                for (final id in s.friendsIn) _PedidoRecebido(pessoaPorId(id)!),
                const SizedBox(height: 10),
              ],
              AppLabel('SEUS AMIGOS · ${s.friends.length}', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              if (s.friends.isEmpty)
                Text('Nenhum amigo ainda. Busque abaixo e envie um pedido.',
                    style: AppTypography.body(size: 10.5, color: AppColors.text3)),
              for (final id in s.friends) _Linha(pessoaPorId(id)!, amigo: true),
              const SizedBox(height: 10),
              AppButton('CRIAR CORDADA COM AMIGOS', onTap: () => s.go('novaCordada'), primary: true),
              const SizedBox(height: 16),
              const AppLabel('ADICIONAR AMIGO', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderInput),
                  borderRadius: r4,
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _q = v),
                  style: AppTypography.body(size: 11, color: AppColors.text),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.dim),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
                    hintText: 'Buscar por nome ou região…',
                    hintStyle: AppTypography.body(size: 11, color: AppColors.dim),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (achados.isEmpty)
                Text('Ninguém encontrado.', style: AppTypography.body(size: 10.5, color: AppColors.text3)),
              for (final p in achados) _Linha(p, enviado: s.friendsOut.contains(p.id)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final Person p;
  const _Avatar(this.p);

  @override
  Widget build(BuildContext c) => Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: p.online ? AppColors.green : AppColors.border),
        ),
        child: AppLabel(p.rank, color: p.online ? AppColors.green : AppColors.dim, size: 9, tracking: 0.1),
      );
}

class _Linha extends StatelessWidget {
  final Person p;
  final bool amigo;
  final bool enviado;
  const _Linha(this.p, {this.amigo = false, this.enviado = false});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.readOf(c);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AppPanel(
        child: Row(
          children: [
            _Avatar(p),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLabel(p.nome.toUpperCase(), color: AppColors.text, size: 11),
                  const SizedBox(height: 3),
                  Text('${p.regiao} · rank ${p.rank}',
                      style: AppTypography.body(size: 9, color: AppColors.dim)),
                ],
              ),
            ),
            if (amigo)
              InkWell(
                onTap: () => s.removerAmigo(p.id),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: AppLabel('REMOVER', color: AppColors.dim, size: 8.5, tracking: 0.2),
                ),
              )
            else if (enviado)
              InkWell(
                onTap: () => s.cancelarPedido(p.id),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: AppLabel('PEDIDO ENVIADO · CANCELAR', color: AppColors.amber, size: 8.5, tracking: 0.12),
                ),
              )
            else
              InkWell(
                onTap: () => s.pedirAmizade(p.id),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: AppLabel('ADICIONAR', color: AppColors.green, size: 9, tracking: 0.2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PedidoRecebido extends StatelessWidget {
  final Person p;
  const _PedidoRecebido(this.p);

  @override
  Widget build(BuildContext c) {
    final s = Expedition.readOf(c);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AppPanel(
        bg: AppColors.bgWarn,
        borderColor: AppColors.borderWarn,
        child: Row(
          children: [
            _Avatar(p),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLabel(p.nome.toUpperCase(), color: AppColors.text, size: 11),
                  const SizedBox(height: 3),
                  Text('quer ser seu amigo · ${p.regiao}',
                      style: AppTypography.body(size: 9, color: AppColors.text2)),
                ],
              ),
            ),
            InkWell(
              onTap: () => s.aceitarPedido(p.id),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: AppLabel('ACEITAR', color: AppColors.green, size: 9, tracking: 0.2),
              ),
            ),
            InkWell(
              onTap: () => s.recusarPedido(p.id),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: AppLabel('RECUSAR', color: AppColors.dim, size: 9, tracking: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
