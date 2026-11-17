import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/data/friends_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Monta uma cordada escolhendo entre os amigos (fictícios, na demonstração).
class NewCordadaScreen extends StatefulWidget {
  const NewCordadaScreen({super.key});

  @override
  State<NewCordadaScreen> createState() => _NewCordadaScreenState();
}

class _NewCordadaScreenState extends State<NewCordadaScreen> {
  final _nome = TextEditingController();
  final _sel = <String>{};

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final amigos = [for (final id in s.friends) pessoaPorId(id)!];
    return Column(
      children: [
        ScreenBar('NOVA CORDADA', sub: s.activeTrail.nome, onBack: () => s.go('friends')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              const AppLabel('NOME DA CORDADA', color: AppColors.dim, size: 9),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderInput),
                  borderRadius: r4,
                ),
                child: TextField(
                  controller: _nome,
                  maxLength: 30,
                  style: AppTypography.body(size: 11, color: AppColors.text),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(11),
                    hintText: 'Ex.: Sexta no Paraná',
                    hintStyle: AppTypography.body(size: 11, color: AppColors.dim),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const AppLabel('QUEM VAI · SÓ AMIGOS', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              if (amigos.isEmpty) ...[
                Text('Você ainda não tem amigos. Adicione alguém para montar uma cordada.',
                    style: AppTypography.body(size: 10.5, color: AppColors.amber)),
                const SizedBox(height: 10),
                AppButton('IR PARA AMIGOS', onTap: () => s.go('friends')),
              ],
              for (final p in amigos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AppPanel(
                    onTap: () => setState(() => _sel.contains(p.id) ? _sel.remove(p.id) : _sel.add(p.id)),
                    child: Row(
                      children: [
                        Icon(_sel.contains(p.id) ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                            size: 16, color: _sel.contains(p.id) ? AppColors.green : AppColors.dim),
                        const SizedBox(width: 10),
                        Expanded(child: AppLabel(p.nome.toUpperCase(), color: AppColors.text, size: 11)),
                        Text('rank ${p.rank}', style: AppTypography.body(size: 9.5, color: AppColors.dim)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              AppButton(
                  _sel.isEmpty ? 'ESCOLHA PELO MENOS 1 AMIGO' : 'CRIAR E ENTRAR (${_sel.length + 1} INTEGRANTES)',
                  onTap: _sel.isEmpty ? null : () => s.criarCordada(_nome.text, _sel.toList()),
                  primary: _sel.isNotEmpty),
            ],
          ),
        ),
      ],
    );
  }
}
