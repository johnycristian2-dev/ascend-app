import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Mapa da trilha: o painel de comando da expedição ativa.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    if (s.empty) return const _EmptyHome();

    final cond = condData[s.trail]!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 26),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLabel('EXPEDIÇÃO ATIVA', color: AppColors.dim, size: 9, tracking: 0.26),
                  const SizedBox(height: 5),
                  Text('TRAVESSIA RUY BRAGA',
                      style: AppTypography.num(size: 22, color: AppColors.text)),
                  const SizedBox(height: 3),
                  Text('28,4 km · +1 640 m · 2 dias',
                      style: AppTypography.body(size: 10, color: AppColors.text3)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppTag('RANK ${s.rank}', AppColors.amber),
                const SizedBox(height: 6),
                Text('NV ${s.level}', style: AppTypography.num(size: 15, color: AppColors.text2)),
              ],
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: s.enterField,
              borderRadius: r4,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: r4,
                ),
                child: const Icon(Icons.terrain, size: 17, color: AppColors.text2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Relevo da rota — placeholder do mapa real.
        Container(
          height: 128,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            border: Border.all(color: AppColors.border),
            borderRadius: r4,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _RidgePainter())),
              const Positioned(
                left: 11,
                top: 10,
                child: AppLabel('PERFIL DO RELEVO · DIA 1',
                    color: AppColors.dim, size: 8, tracking: 0.26),
              ),
              Positioned(
                right: 11,
                bottom: 10,
                child: AppLabel(cond.label, color: AppColors.tagInks[0], size: 8, tracking: 0.16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Janela de partida: a pressão que move todo o resto.
        AppPanel(
          onTap: () => s.go('window'),
          bg: AppColors.bgWarn,
          borderColor: AppColors.borderWarn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLabel('JANELA FECHA EM', color: AppColors.amber, size: 9, tracking: 0.26),
                  AppLabel(s.wx.label, color: AppColors.text2, size: 9),
                ],
              ),
              const SizedBox(height: 8),
              Text(fmtClock(s.wxSec),
                  style: AppTypography.num(size: 32, color: AppColors.textStrong)),
              const SizedBox(height: 8),
              Text(s.wx.note, style: AppTypography.body(size: 10)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Tudo aqui é derivado de day1Min — nunca guardado.
        AppPanel(
          onTap: () => s.go('route'),
          borderColor: s.core.conflicts.isEmpty ? AppColors.border : AppColors.borderWarn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLabel('DIA 1 · ATÉ O ABRIGO'),
                  AppLabel('${s.slot.depDay} · ${s.slot.dep}', color: AppColors.dim, size: 9),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: AppStat('DISTÂNCIA', '${fmtDec(s.core.km)} km')),
                  Expanded(child: AppStat('SUBIDA', '+${fmtMil(s.core.m)} m')),
                  Expanded(
                    child: AppStat('CHEGADA', s.arrive,
                        color: s.dark ? AppColors.amber : AppColors.textStrong),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLabel('MARGEM DE LUZ', color: AppColors.dim, size: 9),
                  Text(
                    s.lightMargin >= 0
                        ? fmtDelta(s.lightMargin)
                        : '-${fmtDelta(-s.lightMargin)}',
                    style: AppTypography.num(
                        size: 14,
                        color: s.lightMargin >= 0 ? AppColors.green : AppColors.amber),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppPanel(
                onTap: () => s.go('pack'),
                bg: s.overweight ? AppColors.bgWarn : AppColors.surface,
                borderColor: s.overweight ? AppColors.borderWarn : AppColors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('MOCHILA'),
                    const SizedBox(height: 10),
                    Text('${fmtDec(s.kg)} kg',
                        style: AppTypography.num(
                            size: 21,
                            color: s.overweight
                                ? AppColors.amber
                                : s.kg > 10.8
                                    ? AppColors.blue
                                    : AppColors.green)),
                    const SizedBox(height: 9),
                    AppProgressBar((s.kg / 15).clamp(0, 1),
                        color: s.overweight
                            ? AppColors.amber
                            : s.kg > 10.8
                                ? AppColors.blue
                                : AppColors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppPanel(
                onTap: () => s.go('relay'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLabel('BASTÃO'),
                    const SizedBox(height: 10),
                    Text('${s.relayCount}', style: AppTypography.num(size: 21)),
                    const SizedBox(height: 9),
                    const AppLabel('RECADOS NA ROTA', color: AppColors.dim, size: 8),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (s.core.conflicts.isNotEmpty) ...[
          const SizedBox(height: 10),
          AppPanel(
            bg: AppColors.bgWarn,
            borderColor: AppColors.borderWarn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppLabel(
                    s.core.conflicts.length == 1
                        ? 'A PARTIDA EXIGE 1 ITEM QUE FICOU EM CASA'
                        : 'A PARTIDA EXIGE ${s.core.conflicts.length} ITENS QUE FICARAM EM CASA',
                    color: AppColors.amber,
                    size: 9),
                const SizedBox(height: 8),
                Text(s.core.conflicts.join(' · '),
                    style: AppTypography.body(size: 10, color: AppColors.text2)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: AppButton('DESCOBRIR TRILHAS', onTap: () => s.go('discover'))),
            const SizedBox(width: 10),
            Expanded(child: AppButton('CONCLUIR TRAVESSIA', onTap: s.finish, primary: true)),
          ],
        ),
      ],
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLabel('NENHUMA EXPEDIÇÃO', color: AppColors.dim, size: 9, tracking: 0.26),
          const SizedBox(height: 8),
          Text('O mapa começa vazio.', style: AppTypography.num(size: 26, color: AppColors.text)),
          const SizedBox(height: 10),
          Text(
            'Escolha uma trilha do seu rank ou entre na cordada de alguém. O registro começa na primeira saída.',
            style: AppTypography.body(size: 11),
          ),
          const SizedBox(height: 20),
          AppButton('VER TRILHAS DO MEU RANK',
              onTap: () => s.go('discover'), primary: true),
          const SizedBox(height: 8),
          AppButton('PLANEJAR EXPEDIÇÃO', onTap: () => s.go('plan')),
        ],
      ),
    );
  }
}

/// Silhueta de crista — marcador de onde entra o mapa de relevo real.
class _RidgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()..moveTo(0, size.height * .82);
    final pts = [.62, .74, .48, .66, .34, .52, .22, .40, .28];
    for (var i = 0; i < pts.length; i++) {
      p.lineTo(size.width * (i + 1) / pts.length, size.height * pts[i]);
    }
    p
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        p, Paint()..color = const Color(0xFF20252B));
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF4E5A48),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
