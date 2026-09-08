import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

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
              const Lbl('UNIDADES', color: Ink_.dim, size: 9, tracking: 0.26),
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
              const Lbl('PRIVACIDADE', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Espectadores não veem sua posição exata em terreno de queda. A cordada vê sempre.',
                      style: T.body(size: 10),
                    ),
                    const SizedBox(height: 10),
                    const Row2('POSIÇÃO PARA A CORDADA', 'sempre'),
                    const Row2('POSIÇÃO PARA ESPECTADORES', 'aproximada'),
                    const Row2('RECADOS ANCORADOS', 'com seu nome'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Btn(
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
              Btn('SAIR DA CONTA', onTap: s.signOut, ink: Ink_.amber),
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
          Lbl(label, color: Ink_.dim, size: 9),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Ink_.surface,
              border: Border.all(color: Ink_.borderInput),
              borderRadius: r4,
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: T.body(size: 11, color: Ink_.text),
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
            color: selected ? Ink_.raised : Ink_.surfaceAlt,
            border: Border.all(color: selected ? Ink_.blue : Ink_.border),
            borderRadius: r4,
          ),
          child: Center(
            child: Lbl(label,
                color: selected ? Ink_.text : Ink_.text2, size: 10, tracking: 0.14),
          ),
        ),
      );
}
