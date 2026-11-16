import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_state.dart' show ranks;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Catálogo de trilhas: curadoria do app + o que a comunidade publicou.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    final s = Expedition.readOf(context);
    // Depois do primeiro frame: loadCatalog() notifica, e isso não pode
    // acontecer no meio do build.
    WidgetsBinding.instance.addPostFrameCallback((_) => s.loadCatalog());
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final items = s.catalog;
    return Column(
      children: [
        ScreenBar('CATÁLOGO DE TRILHAS',
            sub: 'seu rank: ${s.rank} · nível ${s.level}', onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              AppButton('PUBLICAR UMA TRILHA', onTap: () => s.go('publish'), primary: true),
              const SizedBox(height: 10),
              if (s.catalogLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: AppLabel('ATUALIZANDO A COMUNIDADE…', color: AppColors.dim, size: 8),
                ),
              if (s.catalogOffline)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppPanel(
                    bg: AppColors.bgWarn,
                    borderColor: AppColors.borderWarn,
                    child: Text(
                      'Não deu para ler as trilhas da comunidade agora — mostrando só a curadoria do app.',
                      style: AppTypography.body(size: 10, color: AppColors.text2),
                    ),
                  ),
                ),
              ...items.map((t) {
                final locked = t.rankIdx > s.rankIdx;
                final km = t.km.toStringAsFixed(1).replaceAll('.', ',');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Opacity(
                    opacity: locked ? .55 : 1,
                    child: AppPanel(
                      onTap: locked ? null : () => s.selectTrail(t),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: AppLabel(t.nome,
                                      color: AppColors.text, size: 13, tracking: 0.12)),
                              const SizedBox(width: 8),
                              AppTag('RANK ${ranks[t.rankIdx]}',
                                  locked ? AppColors.dim : AppColors.amber),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Text(
                              '$km km · +${t.ganhoM} m'
                              '${t.duracao.isEmpty ? '' : ' · ${t.duracao}'}'
                              '${t.regiao.isEmpty ? '' : ' · ${t.regiao}'}',
                              style: AppTypography.body(size: 10, color: AppColors.text2)),
                          if (t.nota.isNotEmpty || locked) ...[
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Icon(locked ? Icons.lock_outline : Icons.warning_amber_rounded,
                                    size: 12, color: locked ? AppColors.dim : AppColors.blue),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    locked ? 'Bloqueada até o rank ${ranks[t.rankIdx]}.' : t.nota,
                                    style: AppTypography.body(size: 9, color: AppColors.text3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          AppLabel(
                              t.daComunidade
                                  ? 'COMUNIDADE · ${t.autorNome.isEmpty ? 'ANÔNIMO' : t.autorNome.toUpperCase()}'
                                  : 'CURADORIA ASCEND',
                              color: t.daComunidade ? AppColors.green : AppColors.dim,
                              size: 8,
                              tracking: 0.14),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
