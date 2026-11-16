import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_state.dart' show ranks;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Publica uma trilha no catálogo da comunidade, em nome do usuário.
class PublishTrailScreen extends StatefulWidget {
  const PublishTrailScreen({super.key});

  @override
  State<PublishTrailScreen> createState() => _PublishTrailScreenState();
}

class _PublishTrailScreenState extends State<PublishTrailScreen> {
  final _nome = TextEditingController();
  final _km = TextEditingController();
  final _ganho = TextEditingController();
  final _duracao = TextEditingController();
  final _regiao = TextEditingController();
  final _nota = TextEditingController();
  int _rank = 0;
  bool _sending = false;

  @override
  void dispose() {
    for (final c in [_nome, _km, _ganho, _duracao, _regiao, _nota]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _publish(BuildContext c) async {
    final s = Expedition.readOf(c);
    setState(() => _sending = true);
    final ok = await s.publishTrail(
      nome: _nome.text,
      rankIdx: _rank,
      km: double.tryParse(_km.text.replaceAll(',', '.')) ?? 0,
      ganhoM: int.tryParse(_ganho.text) ?? 0,
      duracao: _duracao.text,
      regiao: _regiao.text,
      nota: _nota.text,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) s.go('discover');
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('PUBLICAR TRILHA', sub: 'aparece para toda a comunidade', onBack: () => s.go('discover')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              _Field(label: 'NOME DA TRILHA', controller: _nome),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Field(label: 'DISTÂNCIA (km)', controller: _km, number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'DESNÍVEL (m)', controller: _ganho, number: true)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Field(label: 'DURAÇÃO (ex.: 1 dia)', controller: _duracao)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'REGIÃO', controller: _regiao)),
                ],
              ),
              const SizedBox(height: 10),
              const AppLabel('RANK SUGERIDO', color: AppColors.dim, size: 9),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (var i = 0; i < ranks.length; i++) ...[
                    Expanded(
                      child: AppButton(ranks[i],
                          onTap: () => setState(() => _rank = i),
                          primary: _rank == i),
                    ),
                    if (i < ranks.length - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              _Field(label: 'O QUE QUEM VAI PRECISA SABER', controller: _nota, lines: 3),
              const SizedBox(height: 12),
              if (s.publishError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(s.publishError!,
                      style: AppTypography.body(size: 10, color: AppColors.amber)),
                ),
              AppButton(_sending ? 'PUBLICANDO…' : 'PUBLICAR NO CATÁLOGO',
                  onTap: _sending ? null : () => _publish(c), primary: !_sending),
            ],
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool number;
  final int lines;
  const _Field({required this.label, required this.controller, this.number = false, this.lines = 1});

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
              maxLines: lines,
              keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
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
