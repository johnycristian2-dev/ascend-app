import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/data/cordada_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Lista de cordadas: onde o usuário entra e sai de um grupo.
///
/// Tudo aqui é DEMONSTRAÇÃO — cordadas e integrantes são fictícios (ver
/// cordada_catalog.dart). O que é real é o fluxo: entrar, sair, trocar e
/// lembrar a escolha no perfil.
class CordadasScreen extends StatelessWidget {
  const CordadasScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('CORDADAS', sub: 'demonstração · integrantes fictícios', onBack: () => s.go('chat')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              for (final cd in s.todasCordadas) ...[
                _CordadaCard(cd, atual: s.cordadaId == cd.id),
                const SizedBox(height: 10),
              ],
              AppButton('CRIAR CORDADA COM AMIGOS', onTap: () => s.go('novaCordada'), primary: true),
              const SizedBox(height: 8),
              AppButton('AMIGOS', onTap: () => s.go('friends')),
              const SizedBox(height: 8),
              if (s.cordadaId.isNotEmpty)
                AppButton('SAIR DA CORDADA ATUAL', onTap: () {
                  s.sairCordada();
                  s.go('chat');
                }),
            ],
          ),
        ),
      ],
    );
  }
}

class _CordadaCard extends StatelessWidget {
  final Cordada cd;
  final bool atual;
  const _CordadaCard(this.cd, {required this.atual});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.readOf(c);
    final total = cd.membros.length + (atual ? 1 : 0);
    return AppPanel(
      borderColor: atual ? AppColors.green : AppColors.border,
      bg: atual ? AppColors.bgOk : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppLabel(cd.nome, color: AppColors.text, size: 12),
              if (atual) const AppLabel('VOCÊ ESTÁ AQUI', color: AppColors.green, size: 8, tracking: 0.2),
            ],
          ),
          const SizedBox(height: 5),
          Text(cd.trilha, style: AppTypography.body(size: 10.5, color: AppColors.text2)),
          const SizedBox(height: 3),
          Text(cd.descricao, style: AppTypography.body(size: 9.5, color: AppColors.dim)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final m in cd.membros)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _Avatar(m.nome, m.rank, m.online),
                ),
              const Spacer(),
              Text('$total integrantes', style: AppTypography.body(size: 9.5, color: AppColors.text3)),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(atual ? 'VER CORDADA' : 'ENTRAR NESTA CORDADA',
              onTap: () => atual ? s.go('chat') : s.entrarCordada(cd.id),
              primary: !atual),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String nome;
  final String rank;
  final bool online;
  const _Avatar(this.nome, this.rank, this.online);

  @override
  Widget build(BuildContext c) => Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: online ? AppColors.green : AppColors.border),
        ),
        child: AppLabel(nome.substring(0, 1),
            color: online ? AppColors.text : AppColors.dim, size: 10, tracking: 0.05),
      );
}
