import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app.dart';
import '../../backend/state/expedition_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Monta o link de uma rede a partir do que a pessoa digitou em Ajustes.
/// Se já parece uma URL (começa com http:// ou https://), usa direto —
/// senão, tira um '@' inicial (comum em handle) e monta a URL padrão da
/// rede. Puro Dart, sem Flutter: dá pra testar sem widget nenhum.
Uri? socialLinkUri(String platform, String raw) {
  final v = raw.trim();
  if (v.isEmpty) return null;
  if (v.startsWith('http://') || v.startsWith('https://')) return Uri.tryParse(v);
  final handle = v.startsWith('@') ? v.substring(1) : v;
  return switch (platform) {
    'instagram' => Uri.tryParse('https://instagram.com/$handle'),
    'strava' => Uri.tryParse('https://strava.com/$handle'),
    'youtube' => Uri.tryParse('https://youtube.com/$handle'),
    'website' => Uri.tryParse('https://$v'),
    _ => null,
  };
}

/// Caderno: identidade pública, rank, atributos e a meta de desnível
/// da temporada.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _socialIcons = {
    'instagram': Icons.camera_alt_outlined,
    'strava': Icons.directions_run,
    'youtube': Icons.smart_display_outlined,
    'website': Icons.language,
  };

  Future<void> _openSocial(BuildContext c, String platform, String raw) async {
    final uri = socialLinkUri(platform, raw);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && c.mounted) {
      ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('Não deu para abrir $raw')));
    }
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final socials = _socialIcons.entries.where((e) => (s.socialLinks[e.key] ?? '').isNotEmpty);
    final about = <(String, String)>[
      if (s.practicingSince.isNotEmpty) ('PRATICANDO DESDE', s.practicingSince),
      if (s.dreamTrail.isNotEmpty) ('TRILHA DOS SONHOS', s.dreamTrail),
      if (s.favoriteGear.isNotEmpty) ('EQUIPAMENTO FAVORITO', s.favoriteGear),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 26),
      children: [
        ClipRRect(
          borderRadius: r4,
          child: ProfileCover(coverUrl: s.coverUrl),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(photoUrl: s.photoUrl),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLabel('CADERNO DE CAMPO', color: AppColors.dim, size: 9, tracking: 0.26),
                  const SizedBox(height: 5),
                  Text(s.name.toUpperCase(), style: AppTypography.num(size: 26, color: AppColors.text)),
                  const SizedBox(height: 3),
                  Text(s.baseName, style: AppTypography.body(size: 10, color: AppColors.text3)),
                ],
              ),
            ),
            InkWell(
              onTap: () => s.go('settings'),
              borderRadius: r4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: r4,
                ),
                child: const Icon(Icons.tune, size: 15, color: AppColors.text2),
              ),
            ),
          ],
        ),
        if (s.bio.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(s.bio, style: AppTypography.body(size: 11, height: 1.5)),
        ],
        if (socials.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: socials
                .map((e) => InkWell(
                      onTap: () => _openSocial(c, e.key, s.socialLinks[e.key]!),
                      borderRadius: r4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          border: Border.all(color: AppColors.border),
                          borderRadius: r4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(e.value, size: 12, color: AppColors.text2),
                            const SizedBox(width: 6),
                            Text(s.socialLinks[e.key]!,
                                style: AppTypography.body(size: 10, color: AppColors.text2)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 14),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('RANK ${s.rank}', style: AppTypography.num(size: 40, color: AppColors.amber)),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: AppLabel('NÍVEL ${s.level}', color: AppColors.text2, size: 11),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLabel('DESNÍVEL DA TEMPORADA', color: AppColors.dim, size: 9),
                  Text('${fmtMil(s.elev)} / ${fmtMil(s.elevGoal)} m',
                      style: AppTypography.num(size: 13, color: AppColors.text2)),
                ],
              ),
              const SizedBox(height: 8),
              AppProgressBar(s.elev / s.elevGoal, color: AppColors.amber, height: 4),
              const SizedBox(height: 8),
              Text(
                s.elev >= s.elevGoal
                    ? 'Meta batida. A reavaliação de rank abre no próximo registro.'
                    : 'Faltam ${fmtMil(s.elevGoal - s.elev)} m para a reavaliação de rank.',
                style: AppTypography.body(size: 10, color: AppColors.text3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLabel('ATRIBUTOS'),
              const SizedBox(height: 14),
              ...s.attrs.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppLabel(a.nome, color: AppColors.text2, size: 9),
                            Text('${a.val}', style: AppTypography.num(size: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppProgressBar(a.val / 100, color: AppColors.green),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        if (about.isNotEmpty) ...[
          const SizedBox(height: 10),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLabel('SOBRE'),
                const SizedBox(height: 6),
                for (final a in about) TwoColumnRow(a.$1, a.$2),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: AppButton('EQUIPAMENTO', onTap: () => s.go('inv'))),
            const SizedBox(width: 10),
            Expanded(child: AppButton('CARIMBOS', onTap: () => s.go('ach'))),
          ],
        ),
        const SizedBox(height: 8),
        AppButton('HISTÓRICO MENSAL', onTap: () => s.go('history')),
        const SizedBox(height: 8),
        AppButton('SOLICITAR REAVALIAÇÃO DE RANK', onTap: s.demoRankUp, ink: AppColors.blue),
      ],
    );
  }
}
