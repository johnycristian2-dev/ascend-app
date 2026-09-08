import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Peso da mochila: cada item fora muda ritmo, energia, rota e hora de chegada.
class PackScreen extends StatelessWidget {
  const PackScreen({super.key});

  static const _dayName = {
    'QUI': 'quinta', 'SEX': 'sexta', 'SÁB': 'sábado', 'TER': 'terça'
  };

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final kg = s.kg;
    final over = s.overweight;
    final ink = over ? AppColors.amber : (kg > 10.8 ? AppColors.blue : AppColors.green);
    final drop = packData.where((d) => !d.fixo && s.packOut.contains(d.nome)).length;
    final dia = _dayName[s.slot.depDay.split(' ')[0]] ?? '';

    final veredito = over
        ? 'Acima do que seu rank sustenta em 2 dias. Cada quilo extra custa 8 min por trecho longo — e a partida de $dia não tem essa folga.'
        : drop == 0
            ? 'Você está levando tudo. Cabe no limite, mas não sobra margem para água extra no vale.'
            : '$drop ${drop == 1 ? 'item ficou' : 'itens ficaram'} em casa. Peso compatível com o desnível de $dia.';

    return Column(
      children: [
        ScreenBar('PESO DA MOCHILA',
            sub: 'partida ${s.slot.depDay} · ${s.slot.dep}',
            onBack: () => s.go('home')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              AppPanel(
                bg: over ? AppColors.bgWarn : AppColors.surface,
                borderColor: over ? AppColors.borderWarn : AppColors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(fmtDec(kg), style: AppTypography.num(size: 44, color: ink)),
                        const SizedBox(width: 5),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 7),
                          child: AppLabel('KG', color: AppColors.text2, size: 13),
                        ),
                        const Spacer(),
                        const AppLabel('LIMITE 12 KG', color: AppColors.dim, size: 8),
                      ],
                    ),
                    const SizedBox(height: 11),
                    AppProgressBar((kg / 15).clamp(0, 1), color: ink, height: 4),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                            child: AppStat('RITMO',
                                '${fmtDec(paceKmh(s.gramas))} km/h', size: 16)),
                        Expanded(
                            child: AppStat('ENERGIA', '${fmtMil(kcal(s.gramas))} kcal',
                                size: 16)),
                        Expanded(
                          child: AppStat('CHEGADA', s.arrive,
                              size: 16,
                              color: over || s.dark ? AppColors.amber : AppColors.textStrong),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(veredito,
                        style: AppTypography.body(size: 10, color: over ? AppColors.amber : AppColors.text2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AppPanel(
                bg: AppColors.surfaceAlt,
                child: Row(
                  children: [
                    Icon(Icons.route_outlined,
                        size: 14,
                        color: s.core.variants.isEmpty ? AppColors.green : AppColors.amber),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        s.core.variants.isEmpty
                            ? 'rota limpa · ${fmtDec(s.core.km)} km e ${fmtHm(s.walk)}'
                            : '${s.core.variants.map((v) => v.name.toLowerCase()).join(' + ')} · rota agora ${fmtDec(s.core.km)} km e ${fmtHm(s.walk)}',
                        style: AppTypography.body(
                            size: 10,
                            color: s.core.variants.isEmpty ? AppColors.green : AppColors.amber),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const AppLabel('FIXOS · NÃO SAEM DA MOCHILA', size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              ...packData.where((d) => d.fixo).map((d) => _ItemRow(item: d, fixo: true)),
              const SizedBox(height: 14),
              const AppLabel('ESCOLHA · TOQUE PARA DEIXAR EM CASA',
                  size: 9, tracking: 0.26),
              const SizedBox(height: 8),
              ...packData.where((d) => !d.fixo).map((d) => _ItemRow(item: d, fixo: false)),
              const SizedBox(height: 6),
              AppButton(over ? 'SEGUIR ASSIM MESMO' : 'CONFIRMAR CARGA',
                  onTap: () => s.go('route'),
                  primary: !over,
                  bg: over ? AppColors.bgWarn : null,
                  border: over ? AppColors.borderWarn : null,
                  ink: over ? AppColors.amber : null),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final PackItem item;
  final bool fixo;
  const _ItemRow({required this.item, required this.fixo});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final fora = s.packOut.contains(item.nome);
    final exigido = s.slot.needs.contains(item.nome);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AppPanel(
        onTap: fixo ? null : () => s.toggleCarry(item.nome),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        bg: fora ? AppColors.surfaceAlt : AppColors.surface,
        borderColor: fora && exigido ? AppColors.borderWarn : AppColors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  fixo
                      ? Icons.lock_outline
                      : fora
                          ? Icons.remove_circle_outline
                          : Icons.check_circle_outline,
                  size: 14,
                  color: fixo ? AppColors.dim : (fora ? AppColors.dim : AppColors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nome,
                        style: AppTypography.label(
                            size: 11,
                            color: fora ? AppColors.dim : AppColors.text,
                            tracking: 0.12).copyWith(
                          decoration: fora ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.dim,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(item.note, style: AppTypography.body(size: 9, color: AppColors.dim)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${fmtMil(item.gramas)} g',
                    style: AppTypography.num(
                        size: 13,
                        color: fora ? AppColors.dim : AppColors.text2,
                        weight: FontWeight.w500)),
              ],
            ),
            if (fora && item.consequencia.isNotEmpty) ...[
              const SizedBox(height: 9),
              Text(item.consequencia,
                  style: AppTypography.body(size: 9, color: exigido ? AppColors.amber : AppColors.text3)),
            ],
            if (fora && exigido) ...[
              const SizedBox(height: 7),
              const AppLabel('A PARTIDA ESCOLHIDA EXIGE ESTE ITEM',
                  color: AppColors.amber, size: 8, tracking: 0.14),
            ],
          ],
        ),
      ),
    );
  }
}
