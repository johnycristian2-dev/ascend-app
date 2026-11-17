import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Cadastro de equipamento: a peça entra na mesma lista (e no mesmo
/// odômetro) das peças do catálogo e é salva no perfil.
class NewGearScreen extends StatefulWidget {
  const NewGearScreen({super.key});

  @override
  State<NewGearScreen> createState() => _NewGearScreenState();
}

class _NewGearScreenState extends State<NewGearScreen> {
  final _nome = TextEditingController();
  final _detalhe = TextEditingController();
  final _peso = TextEditingController();
  final _limite = TextEditingController();
  String _cat = 'BASE';
  bool _km = false;
  String? _erro;

  static const _cats = ['TÉCNICO', 'SEGURANÇA', 'BASE', 'ABRIGO'];

  @override
  void dispose() {
    _nome.dispose();
    _detalhe.dispose();
    _peso.dispose();
    _limite.dispose();
    super.dispose();
  }

  Widget _campo(String rotulo, TextEditingController ctl, String dica,
      {TextInputType? tipo, int max = 40}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabel(rotulo, color: AppColors.dim, size: 9),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderInput),
              borderRadius: r4,
            ),
            child: TextField(
              controller: ctl,
              keyboardType: tipo,
              maxLength: max,
              style: AppTypography.body(size: 11, color: AppColors.text),
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(11),
                hintText: dica,
                hintStyle: AppTypography.body(size: 11, color: AppColors.dim),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('CADASTRAR EQUIPAMENTO', sub: 'entra no seu inventário', onBack: () => s.go('inv')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              _campo('NOME DA PEÇA', _nome, 'Ex.: Jaqueta corta-vento'),
              _campo('DETALHE (OPCIONAL)', _detalhe, 'Ex.: tamanho M · Gore-Tex', max: 40),
              _campo('PESO (KG)', _peso, 'Ex.: 0,45', tipo: TextInputType.number, max: 6),
              const AppLabel('CATEGORIA', color: AppColors.dim, size: 9),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in _cats)
                    InkWell(
                      onTap: () => setState(() => _cat = k),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: _cat == k ? AppColors.green : AppColors.border),
                          borderRadius: r4,
                        ),
                        child: AppLabel(k, color: _cat == k ? AppColors.green : AppColors.text3, size: 9),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const AppLabel('VIDA ÚTIL SE MEDE EM', color: AppColors.dim, size: 9),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: AppButton('SAÍDAS', onTap: () => setState(() => _km = false), primary: !_km),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton('QUILÔMETROS', onTap: () => setState(() => _km = true), primary: _km),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _campo('LIMITE DE USO (${_km ? 'KM' : 'SAÍDAS'})', _limite, 'Ex.: ${_km ? '1500' : '50'}',
                  tipo: TextInputType.number, max: 6),
              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_erro!, style: AppTypography.body(size: 10.5, color: AppColors.amber)),
                ),
              AppButton('SALVAR EQUIPAMENTO', primary: true, onTap: () {
                final e = s.cadastrarEquip(
                  nome: _nome.text,
                  categoria: _cat,
                  pesoKg: _peso.text,
                  detalhe: _detalhe.text,
                  limite: _limite.text,
                  emKm: _km,
                );
                if (e != null) {
                  setState(() => _erro = e);
                } else {
                  s.go('inv');
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
}
