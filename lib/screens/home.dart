import 'package:flutter/material.dart';
import '../main.dart';
import '../state/calc.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

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
                  const Lbl('EXPEDIÇÃO ATIVA', color: Ink_.dim, size: 9, tracking: 0.26),
                  const SizedBox(height: 5),
                  Text('TRAVESSIA RUY BRAGA',
                      style: T.num(size: 22, color: Ink_.text)),
                  const SizedBox(height: 3),
                  Text('28,4 km · +1 640 m · 2 dias',
                      style: T.body(size: 10, color: Ink_.text3)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Tag('RANK ${s.rank}', Ink_.amber),
                const SizedBox(height: 6),
                Text('NV ${s.level}', style: T.num(size: 15, color: Ink_.text2)),
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
                  color: Ink_.surface,
                  border: Border.all(color: Ink_.border),
                  borderRadius: r4,
                ),
                child: const Icon(Icons.terrain, size: 17, color: Ink_.text2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Relevo da rota — placeholder do mapa real.
        Container(
          height: 128,
          decoration: BoxDecoration(
            color: Ink_.surfaceAlt,
            border: Border.all(color: Ink_.border),
            borderRadius: r4,
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _RidgePainter())),
              Positioned(
                left: 11,
                top: 10,
                child: Lbl('PERFIL DO RELEVO · DIA 1',
                    color: Ink_.dim, size: 8, tracking: 0.26),
              ),
              Positioned(
                right: 11,
                bottom: 10,
                child: Lbl(cond.label, color: Ink_.tagInks[0], size: 8, tracking: 0.16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Janela de partida: a pressão que move todo o resto.
        Panel(
          onTap: () => s.go('window'),
          bg: Ink_.bgWarn,
          borderColor: Ink_.borderWarn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Lbl('JANELA FECHA EM', color: Ink_.amber, size: 9, tracking: 0.26),
                  Lbl(s.wx.label, color: Ink_.text2, size: 9),
                ],
              ),
              const SizedBox(height: 8),
              Text(fmtClock(s.wxSec),
                  style: T.num(size: 32, color: Ink_.textStrong)),
              const SizedBox(height: 8),
              Text(s.wx.note, style: T.body(size: 10)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Tudo aqui é derivado de day1Min — nunca guardado.
        Panel(
          onTap: () => s.go('route'),
          borderColor: s.core.conflicts.isEmpty ? Ink_.border : Ink_.borderWarn,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Lbl('DIA 1 · ATÉ O ABRIGO'),
                  Lbl('${s.slot.depDay} · ${s.slot.dep}', color: Ink_.dim, size: 9),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Stat('DISTÂNCIA', '${fmtDec(s.core.km)} km')),
                  Expanded(child: Stat('SUBIDA', '+${fmtMil(s.core.m)} m')),
                  Expanded(
                    child: Stat('CHEGADA', s.arrive,
                        color: s.dark ? Ink_.amber : Ink_.textStrong),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Ink_.border, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Lbl('MARGEM DE LUZ', color: Ink_.dim, size: 9),
                  Text(
                    s.lightMargin >= 0
                        ? fmtDelta(s.lightMargin)
                        : '-${fmtDelta(-s.lightMargin)}',
                    style: T.num(
                        size: 14,
                        color: s.lightMargin >= 0 ? Ink_.green : Ink_.amber),
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
              child: Panel(
                onTap: () => s.go('pack'),
                bg: s.overweight ? Ink_.bgWarn : Ink_.surface,
                borderColor: s.overweight ? Ink_.borderWarn : Ink_.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('MOCHILA'),
                    const SizedBox(height: 10),
                    Text('${fmtDec(s.kg)} kg',
                        style: T.num(
                            size: 21,
                            color: s.overweight
                                ? Ink_.amber
                                : s.kg > 10.8
                                    ? Ink_.blue
                                    : Ink_.green)),
                    const SizedBox(height: 9),
                    Bar((s.kg / 15).clamp(0, 1),
                        color: s.overweight
                            ? Ink_.amber
                            : s.kg > 10.8
                                ? Ink_.blue
                                : Ink_.green),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Panel(
                onTap: () => s.go('relay'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Lbl('BASTÃO'),
                    const SizedBox(height: 10),
                    Text('${s.relayCount}', style: T.num(size: 21)),
                    const SizedBox(height: 9),
                    const Lbl('RECADOS NA ROTA', color: Ink_.dim, size: 8),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (s.core.conflicts.isNotEmpty) ...[
          const SizedBox(height: 10),
          Panel(
            bg: Ink_.bgWarn,
            borderColor: Ink_.borderWarn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Lbl(
                    s.core.conflicts.length == 1
                        ? 'A PARTIDA EXIGE 1 ITEM QUE FICOU EM CASA'
                        : 'A PARTIDA EXIGE ${s.core.conflicts.length} ITENS QUE FICARAM EM CASA',
                    color: Ink_.amber,
                    size: 9),
                const SizedBox(height: 8),
                Text(s.core.conflicts.join(' · '),
                    style: T.body(size: 10, color: Ink_.text2)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Btn('DESCOBRIR TRILHAS', onTap: () => s.go('discover'))),
            const SizedBox(width: 10),
            Expanded(child: Btn('CONCLUIR TRAVESSIA', onTap: s.finish, primary: true)),
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
          const Lbl('NENHUMA EXPEDIÇÃO', color: Ink_.dim, size: 9, tracking: 0.26),
          const SizedBox(height: 8),
          Text('O mapa começa vazio.', style: T.num(size: 26, color: Ink_.text)),
          const SizedBox(height: 10),
          Text(
            'Escolha uma trilha do seu rank ou entre na cordada de alguém. O registro começa na primeira saída.',
            style: T.body(size: 11),
          ),
          const SizedBox(height: 20),
          Btn('VER TRILHAS DO MEU RANK',
              onTap: () => s.go('discover'), primary: true),
          const SizedBox(height: 8),
          Btn('PLANEJAR EXPEDIÇÃO', onTap: () => s.go('plan')),
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
