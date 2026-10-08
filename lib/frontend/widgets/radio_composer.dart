import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../backend/state/expedition_state.dart';
import 'widgets.dart';

/// Abre o rádio de cordada — "RÁDIO" no mapa ou no modo campo, do
/// protótipo (`openRadio`). Chamado de duas telas (home e campo), por
/// isso é uma função solta em vez de um método privado de uma delas.
void openRadioComposer(BuildContext c) {
  final s = Expedition.of(c);
  showModalBottomSheet(
    context: c,
    backgroundColor: const Color(0xFF1F2429),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    builder: (_) => _RadioComposer(s: s),
  ).whenComplete(s.cancelRadioRecording);
}

/// Rádio de cordada — gravação de voz de verdade (ver
/// `radio_service.dart`), ao contrário do resto dos dados de
/// demonstração do app. Segurar o botão grava até 10 s; soltar fixa o
/// recado no topo da lista deste trecho.
class _RadioComposer extends StatelessWidget {
  final ExpeditionState s;
  const _RadioComposer({required this.s});

  @override
  Widget build(BuildContext c) => AnimatedBuilder(
        animation: s,
        builder: (context, _) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLabel('RÁDIO DE CORDADA', color: AppColors.text3, size: 9, tracking: 0.26),
                  Expanded(
                    child: Text(
                      'recado fica preso ao ponto do mapa',
                      textAlign: TextAlign.right,
                      style: AppTypography.body(size: 9.5, color: AppColors.dim),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _RecordPanel(s: s),
              if (s.radioError != null) ...[
                const SizedBox(height: 8),
                Text(s.radioError!, style: AppTypography.body(size: 10, color: AppColors.amber)),
              ],
              const SizedBox(height: 15),
              const AppLabel('RECADOS NESTE TRECHO', color: AppColors.text3, size: 9, tracking: 0.26),
              if (s.radios.isEmpty) ...[
                const SizedBox(height: 8),
                Text('Nenhum recado ainda — segure o botão acima pra deixar o primeiro.',
                    style: AppTypography.body(size: 10.5, color: AppColors.dim)),
              ] else
                ...s.radios.map((r) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _RadioTile(s: s, m: r),
                    )),
              const SizedBox(height: 12),
              AppButton('FECHAR', onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      );
}

class _RecordPanel extends StatelessWidget {
  final ExpeditionState s;
  const _RecordPanel({required this.s});

  @override
  Widget build(BuildContext c) {
    final rec = s.radioRecording;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.border),
        borderRadius: r4,
      ),
      child: Column(
        children: [
          const AppLabel('SELA DOS DOIS IRMÃOS · 2 180 M', color: AppColors.dim, size: 9, tracking: 0.16),
          const SizedBox(height: 11),
          GestureDetector(
            onTapDown: (_) => s.startRadioRecording(),
            onTapUp: (_) => s.stopRadioRecording(),
            onTapCancel: s.cancelRadioRecording,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rec ? AppColors.amber.withValues(alpha: .14) : AppColors.surface,
                border: Border.all(color: rec ? AppColors.amber : AppColors.borderRaised, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_none, size: 26, color: rec ? AppColors.amber : AppColors.borderRaised),
                  const SizedBox(height: 2),
                  Text('0:0${s.radioRecSec.clamp(0, 9)}',
                      style: AppTypography.num(size: 13, color: rec ? AppColors.amber : AppColors.borderRaised)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: s.radioRecSec / 10,
              minHeight: 5,
              backgroundColor: AppColors.chrome,
              color: AppColors.amber,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            rec
                ? 'Solte para fixar o recado neste ponto · máx. 10 s'
                : 'Mantenha pressionado para gravar até 10 s',
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 10.5, color: AppColors.text2),
          ),
        ],
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  final ExpeditionState s;
  final RadioMessage m;
  const _RadioTile({required this.s, required this.m});

  @override
  Widget build(BuildContext c) {
    final playing = s.radioPlayingId == m.id;
    final bars = List.generate(24, (i) => 6 + ((i * 37 + m.id.hashCode).abs() % 18));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.border),
        borderRadius: r4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppLabel(m.who, color: AppColors.text, size: 13, tracking: 0.1),
              AppLabel(m.pending ? 'AGUARDA SINAL' : 'ENTREGUE',
                  color: m.pending ? AppColors.amber : AppColors.green, size: 9, tracking: 0.16),
            ],
          ),
          const SizedBox(height: 2),
          Text('${m.at} · ${m.time}', style: AppTypography.body(size: 9.5, color: AppColors.dim)),
          const SizedBox(height: 9),
          Row(
            children: [
              InkWell(
                onTap: () => s.playRadio(m),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderRaised),
                  ),
                  child: Icon(playing ? Icons.pause : Icons.play_arrow,
                      size: 14, color: AppColors.blue),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: SizedBox(
                  height: 24,
                  child: Row(
                    children: bars
                        .map((h) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: Container(
                                  height: h.toDouble(),
                                  color: playing ? AppColors.blue : AppColors.borderRaised,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('0:${m.durationSec.toString().padLeft(2, '0')}',
                  style: AppTypography.num(size: 10, color: AppColors.text2)),
            ],
          ),
        ],
      ),
    );
  }
}
