import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Ajustes: identidade, meta e unidades — agora gravados de verdade no
/// caderno (Firestore), não só em memória.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _base;
  late final TextEditingController _goal;
  late String _units;

  late final TextEditingController _bio;
  late final TextEditingController _photoUrl;
  late final TextEditingController _coverUrl;
  late final TextEditingController _instagram;
  late final TextEditingController _strava;
  late final TextEditingController _youtube;
  late final TextEditingController _website;
  late final TextEditingController _practicingSince;
  late final TextEditingController _dreamTrail;
  late final TextEditingController _favoriteGear;

  @override
  void initState() {
    super.initState();
    final s = Expedition.readOf(context);
    _name = TextEditingController(text: s.name);
    _base = TextEditingController(text: s.baseName);
    _goal = TextEditingController(text: s.elevGoal.toString());
    _units = s.units;
    _bio = TextEditingController(text: s.bio);
    _photoUrl = TextEditingController(text: s.photoUrl);
    _coverUrl = TextEditingController(text: s.coverUrl);
    _instagram = TextEditingController(text: s.socialLinks['instagram'] ?? '');
    _strava = TextEditingController(text: s.socialLinks['strava'] ?? '');
    _youtube = TextEditingController(text: s.socialLinks['youtube'] ?? '');
    _website = TextEditingController(text: s.socialLinks['website'] ?? '');
    _practicingSince = TextEditingController(text: s.practicingSince);
    _dreamTrail = TextEditingController(text: s.dreamTrail);
    _favoriteGear = TextEditingController(text: s.favoriteGear);
  }

  @override
  void dispose() {
    _name.dispose();
    _base.dispose();
    _goal.dispose();
    _bio.dispose();
    _photoUrl.dispose();
    _coverUrl.dispose();
    _instagram.dispose();
    _strava.dispose();
    _youtube.dispose();
    _website.dispose();
    _practicingSince.dispose();
    _dreamTrail.dispose();
    _favoriteGear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('AJUSTES', onBack: () => s.go('profile')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('IDENTIFICAÇÃO', size: 9, tracking: 0.26),
                    const SizedBox(height: 11),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileAvatar(photoUrl: s.photoUrl, size: 64),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _EditField(label: 'nome de campo', controller: _name),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _EditField(label: 'BASE / REGIÃO', controller: _base),
              const SizedBox(height: 10),
              _EditField(
                label: 'META DE DESNÍVEL (m POR TEMPORADA)',
                controller: _goal,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              const AppLabel('PERFIL PÚBLICO', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EditField(label: 'BIOGRAFIA', controller: _bio, maxLines: 3),
                    const SizedBox(height: 10),
                    _EditField(
                      label: 'FOTO DE PERFIL (LINK)',
                      controller: _photoUrl,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 10),
                    _EditField(
                      label: 'PLANO DE FUNDO (LINK)',
                      controller: _coverUrl,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cole o link de uma imagem já hospedada em algum lugar — o app não '
                      'guarda a foto em si, só o endereço dela. Em branco usa o retrato padrão.',
                      style: AppTypography.body(size: 9, color: AppColors.dim),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppLabel('REDES SOCIAIS', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EditField(label: 'INSTAGRAM', controller: _instagram),
                    const SizedBox(height: 10),
                    _EditField(label: 'STRAVA', controller: _strava),
                    const SizedBox(height: 10),
                    _EditField(label: 'YOUTUBE', controller: _youtube),
                    const SizedBox(height: 10),
                    _EditField(
                      label: 'SITE PESSOAL',
                      controller: _website,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppLabel('SOBRE VOCÊ', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EditField(label: 'PRATICANDO DESDE', controller: _practicingSince),
                    const SizedBox(height: 10),
                    _EditField(label: 'TRILHA DOS SONHOS', controller: _dreamTrail),
                    const SizedBox(height: 10),
                    _EditField(label: 'EQUIPAMENTO FAVORITO', controller: _favoriteGear),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const AppLabel('UNIDADES', color: AppColors.dim, size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _UnitOption(
                      label: 'MÉTRICO · m / km',
                      selected: _units == 'métrico',
                      onTap: () => setState(() => _units = 'métrico'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _UnitOption(
                      label: 'IMPERIAL · ft / mi',
                      selected: _units == 'imperial',
                      onTap: () => setState(() => _units = 'imperial'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const AppLabel('PRIVACIDADE', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              AppPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Espectadores não veem sua posição exata em terreno de queda. A cordada vê sempre.',
                      style: AppTypography.body(size: 10),
                    ),
                    const SizedBox(height: 10),
                    const TwoColumnRow('POSIÇÃO PARA A CORDADA', 'sempre'),
                    const TwoColumnRow('POSIÇÃO PARA ESPECTADORES', 'aproximada'),
                    const TwoColumnRow('RECADOS ANCORADOS', 'com seu nome'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                'SALVAR',
                primary: true,
                onTap: () {
                  final goal = int.tryParse(_goal.text.trim()) ?? s.elevGoal;
                  s.saveSettings(
                    name: _name.text,
                    baseName: _base.text,
                    elevGoal: goal,
                    units: _units,
                    bio: _bio.text,
                    photoUrl: _photoUrl.text,
                    coverUrl: _coverUrl.text,
                    instagram: _instagram.text,
                    strava: _strava.text,
                    youtube: _youtube.text,
                    website: _website.text,
                    practicingSince: _practicingSince.text,
                    dreamTrail: _dreamTrail.text,
                    favoriteGear: _favoriteGear.text,
                  );
                },
              ),
              const SizedBox(height: 8),
              AppButton('SAIR DA CONTA', onTap: s.signOut, ink: AppColors.amber),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabel(label, color: AppColors.dim, size: 9),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderInput),
              borderRadius: r4,
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: AppTypography.body(size: 11, color: AppColors.text),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      );
}

class _UnitOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _UnitOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext c) => InkWell(
        onTap: onTap,
        borderRadius: r4,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.raised : AppColors.surfaceAlt,
            border: Border.all(color: selected ? AppColors.blue : AppColors.border),
            borderRadius: r4,
          ),
          child: Center(
            child: AppLabel(label,
                color: selected ? AppColors.text : AppColors.text2, size: 10, tracking: 0.14),
          ),
        ),
      );
}
