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

  @override
  void initState() {
    super.initState();
    final s = Expedition.readOf(context);
    _name = TextEditingController(text: s.name);
    _base = TextEditingController(text: s.baseName);
    _goal = TextEditingController(text: s.elevGoal.toString());
    _units = s.units;
  }

  @override
  void dispose() {
    _name.dispose();
    _base.dispose();
    _goal.dispose();
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
              _EditField(label: 'NOME DE CAMPO', controller: _name),
              const SizedBox(height: 10),
              _EditField(label: 'BASE / REGIÃO', controller: _base),
              const SizedBox(height: 10),
              _EditField(
                label: 'META DE DESNÍVEL (m POR TEMPORADA)',
                controller: _goal,
                keyboardType: TextInputType.number,
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
  const _EditField({required this.label, required this.controller, this.keyboardType});

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
