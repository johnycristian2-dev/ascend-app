import 'dart:async';
import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../backend/data/sos_contacts.dart';

/// Paleta exclusiva desta tela — vermelho-ferrugem, deliberadamente fora
/// do sistema visual do resto do app (ver ESPEC-Flutter.md / chat de
/// design: "tela de emergência em vermelho-ferrugem"). Não entra em
/// AppColors porque não é uma cor de uso geral.
class _SosInk {
  static const bg = Color(0xFF140D0A);
  static const surface = Color(0xFF1A100C);
  static const border = Color(0xFF4A3226);
  static const textDim = Color(0xFF8A6B58);
  static const textMuted = Color(0xFFA87256);
  static const textLight = Color(0xFFC9A188);
}

/// SOS: sobreposição de emergência acessível do modo campo — como
/// [FieldScreen], não é uma tela do fluxo normal.
///
/// IMPORTANTE — isto é uma simulação de interface, igual ao resto dos
/// dados de demonstração do app (clima, cordada, recados): manter
/// pressionado NÃO envia nada de verdade a ninguém. Uma versão real
/// precisaria de localização de verdade, permissão nativa, e uma forma
/// real de despachar SMS/satélite/rádio — nenhuma dessas dá pra
/// implementar às cegas sem SDK do Flutter aqui. Ver README.
class SosScreen extends StatefulWidget {
  const SosScreen({super.key});
  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  Timer? _holdTimer;
  double _holdProgress = 0;

  static const _holdDuration = Duration(seconds: 3);
  static const _tick = Duration(milliseconds: 40);

  void _startHold(ExpeditionState s) {
    if (s.sosSent) return;
    _holdTimer?.cancel();
    setState(() => _holdProgress = 0);
    _holdTimer = Timer.periodic(_tick, (timer) {
      setState(() => _holdProgress += _tick.inMilliseconds / _holdDuration.inMilliseconds);
      if (_holdProgress >= 1) {
        timer.cancel();
        s.confirmSos();
      }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    setState(() => _holdProgress = 0);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Material(
      color: _SosInk.bg,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _SosInk.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('EMERGÊNCIA',
                      style: AppTypography.label(size: 14, color: AppColors.amber, tracking: 0.26)),
                  InkWell(
                    onTap: () {
                      _cancelHold();
                      s.closeSos();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: _SosInk.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('CANCELAR',
                          style: AppTypography.label(size: 10, color: _SosInk.textMuted, tracking: 0.16)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _SosInk.surface,
                      border: Border.all(color: _SosInk.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SUA POSIÇÃO',
                            style: AppTypography.label(size: 10, color: _SosInk.textMuted, tracking: 0.24)),
                        const SizedBox(height: 6),
                        Text("22°23'S 44°40'W",
                            style: AppTypography.num(size: 34, color: AppColors.textStrong)),
                        const SizedBox(height: 6),
                        Text('2 421 m · Vale das Pedras, km 12,6',
                            style: AppTypography.body(size: 12, color: _SosInk.textLight)),
                        const SizedBox(height: 3),
                        Text('precisão ±18 m · fixado há 4 min',
                            style: AppTypography.body(size: 11, color: _SosInk.textDim)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('ENVIAR PARA',
                      style: AppTypography.label(size: 10, color: _SosInk.textMuted, tracking: 0.24)),
                  const SizedBox(height: 9),
                  ...sosContacts.map((ct) => Container(
                        margin: const EdgeInsets.only(bottom: 7),
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: _SosInk.surface,
                          border: Border.all(color: const Color(0xFF3A241B)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                                width: 8, height: 8, color: AppColors.tagInks[ct.dotInk]),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ct.name,
                                      style: AppTypography.num(size: 15, color: AppColors.textStrong)),
                                  const SizedBox(height: 1),
                                  Text(ct.role,
                                      style: AppTypography.body(size: 10, color: _SosInk.textMuted)),
                                ],
                              ),
                            ),
                            Text(ct.via,
                                style:
                                    AppTypography.label(size: 9, color: _SosInk.textLight, tracking: 0.16)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),
                  Text(
                    s.sosSent
                        ? 'Posição sendo enviada a cada 2 min. Toque em CANCELAR ALERTA quando estiver seguro.'
                        : 'Mantenha pressionado por 3 s para transmitir. A posição continua sendo '
                            'enviada a cada 2 min até o cancelamento, mesmo sem sinal de dados.',
                    style: AppTypography.body(size: 11, height: 1.6, color: _SosInk.textDim),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Protótipo: nenhum alerta é enviado de verdade — ver README.',
                    style: AppTypography.body(size: 9, color: _SosInk.border),
                  ),
                ],
              ),
            ),
            if (s.sosSent)
              InkWell(
                onTap: s.closeSos,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  color: AppColors.bgOk,
                  child: Center(
                    child: Text('CANCELAR ALERTA',
                        style: AppTypography.label(size: 18, color: AppColors.green, tracking: 0.3)),
                  ),
                ),
              )
            else
              GestureDetector(
                onTapDown: (_) => _startHold(s),
                onTapUp: (_) => _cancelHold(),
                onTapCancel: _cancelHold,
                child: Container(
                  width: double.infinity,
                  color: AppColors.amber,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _holdProgress.clamp(0, 1),
                        child: Container(
                          height: 84,
                          color: Colors.black.withValues(alpha: .2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Text('MANTER PRESSIONADO',
                            style: AppTypography.label(size: 18, color: _SosInk.bg, tracking: 0.3)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
