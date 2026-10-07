import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Modo campo: tipografia gigante, três controles, usável com luva e vento.
/// É daqui — não da tela de leitura em casa — que um recado de bastão nasce:
/// ancorado no ponto exato onde você está agora. É daqui também que se abre
/// o SOS (ver sos_screen.dart) — mesma lógica do protótipo original.
class FieldScreen extends StatelessWidget {
  const FieldScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Material(
      color: const Color(0xFF0B0C0E),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppLabel('MODO CAMPO', color: AppColors.text3, size: 13, tracking: 0.26),
                AppLabel('GPS · OFFLINE', color: AppColors.amber, size: 13, tracking: 0.16),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLabel('ALTITUDE', color: AppColors.text3, size: 12, tracking: 0.3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('2 421', style: AppTypography.num(size: 76, color: AppColors.textStrong)),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10, left: 6),
                        child: AppLabel('m', color: AppColors.text3, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppLabel('RESTAM', color: AppColors.text3, size: 11, tracking: 0.28),
                            Text('15,8', style: AppTypography.num(size: 46, color: AppColors.textStrong)),
                            const AppLabel('km', color: AppColors.text3, size: 16),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppLabel('RUMO', color: AppColors.text3, size: 11, tracking: 0.28),
                            Text('NE 42°', style: AppTypography.num(size: 46, color: AppColors.textStrong)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 24, color: AppColors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Crista exposta em 1,2 km',
                            style: AppTypography.num(size: 18, color: const Color(0xFFD9A183))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _FieldBtn(
                  label: 'ANCORAR\nRECADO',
                  color: AppColors.blue,
                  onTap: () => _openComposer(c, s),
                ),
              ),
              Container(width: 1, height: 68, color: AppColors.border),
              Expanded(
                child: _FieldBtn(
                  label: 'MARCAR',
                  color: AppColors.green,
                  onTap: () => _openLog(c, s),
                ),
              ),
              Container(width: 1, height: 68, color: AppColors.border),
              Expanded(
                child: _FieldBtn(
                  label: 'SOS',
                  color: AppColors.amber,
                  onTap: s.openSos,
                ),
              ),
              Container(width: 1, height: 68, color: AppColors.border),
              Expanded(
                child: _FieldBtn(
                  label: 'SAIR',
                  color: AppColors.text2,
                  onTap: s.exitField,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openComposer(BuildContext c, ExpeditionState s) {
    showModalBottomSheet(
      context: c,
      backgroundColor: const Color(0xFF1F2429),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (sheetCtx) => _FieldRelayComposer(s: s),
    );
  }

  void _openLog(BuildContext c, ExpeditionState s) {
    showModalBottomSheet(
      context: c,
      backgroundColor: const Color(0xFF1F2429),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (sheetCtx) => _FieldLogComposer(s: s),
    );
  }
}

class _FieldBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FieldBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext c) => InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          color: const Color(0xFF15181B),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.label(size: 15, color: color, tracking: 0.16),
          ),
        ),
      );
}

/// Composer aberto a partir do modo campo — ancorado no ponto onde você
/// está agora, não numa revisão de mesa depois da trilha.
class _FieldRelayComposer extends StatelessWidget {
  final ExpeditionState s;
  const _FieldRelayComposer({required this.s});

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
                  const AppLabel('ANCORAR RECADO AQUI', color: AppColors.text3, size: 9, tracking: 0.26),
                  Text('${s.relayDraft.length} / 180',
                      style: AppTypography.body(size: 9.5, color: AppColors.dim)),
                ],
              ),
              const SizedBox(height: 5),
              Text('CRISTA EXPOSTA · 2 421 m — onde você está agora',
                  style: AppTypography.body(size: 10, color: AppColors.dim)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderInput),
                  borderRadius: r4,
                ),
                child: TextField(
                  autofocus: true,
                  maxLines: 3,
                  maxLength: 180,
                  onChanged: s.setRelayDraft,
                  style: AppTypography.body(size: 11, color: AppColors.text),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(11),
                    hintText: 'O que você viu que o mapa não conta.',
                    hintStyle: AppTypography.body(size: 11, color: AppColors.dim),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                s.relaySent
                    ? 'RECADO ANCORADO · AGUARDA CONFIRMAÇÃO'
                    : s.relayDraft.trim().isNotEmpty
                        ? 'ANCORAR NESTE PONTO'
                        : 'ESCREVA ALGO ÚTIL',
                onTap: s.sendRelay,
                primary: s.relayDraft.trim().isNotEmpty,
                bg: s.relaySent ? AppColors.bgOk : null,
                border: s.relaySent ? AppColors.green : null,
                ink: s.relaySent ? AppColors.green : null,
              ),
              const SizedBox(height: 9),
              Text(
                'Recados escritos em campo são ancorados no ponto exato — quem vem depois lê o que você viu, não uma lembrança de casa.',
                style: AppTypography.body(size: 9.5, color: AppColors.dim),
              ),
            ],
          ),
        ),
      );
}

/// Diário de bordo — "MARCAR" no modo campo: uma linha por trecho, só
/// para você (ao contrário do recado de bastão, não é compartilhado).
///
/// `TextEditingController` próprio (ao contrário do composer de recado,
/// que vive bem com um `TextField` sem controller porque só é usado uma
/// vez por visita ao modo campo): aqui dá pra registrar várias notas
/// seguidas na mesma folha, então o campo precisa limpar sozinho depois
/// de cada "REGISTRAR" — sem controller, o texto enviado continuaria
/// visível na caixa mesmo com `logDraft` já zerado no estado.
class _FieldLogComposer extends StatefulWidget {
  final ExpeditionState s;
  const _FieldLogComposer({required this.s});

  @override
  State<_FieldLogComposer> createState() => _FieldLogComposerState();
}

class _FieldLogComposerState extends State<_FieldLogComposer> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    widget.s.sendLogEntry();
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext c) {
    final s = widget.s;
    return AnimatedBuilder(
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
              const AppLabel('DIÁRIO DE BORDO', color: AppColors.text3, size: 9, tracking: 0.26),
              const SizedBox(height: 5),
              Text('VALE DAS PEDRAS · 12,6 km',
                  style: AppTypography.body(size: 10, color: AppColors.dim)),
              if (s.logEntries.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...s.logEntries.reversed.map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppPanel(
                        bg: AppColors.surfaceAlt,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppLabel(n.seg, color: AppColors.green, size: 9, tracking: 0.16),
                                Text(n.time, style: AppTypography.body(size: 9.5, color: AppColors.dim)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(n.text, style: AppTypography.body(size: 12, color: AppColors.text)),
                          ],
                        ),
                      ),
                    )),
              ],
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderInput),
                  borderRadius: r4,
                ),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  maxLines: 2,
                  maxLength: 180,
                  onChanged: s.setLogDraft,
                  style: AppTypography.body(size: 11, color: AppColors.text),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(11),
                    hintText: 'Uma linha sobre este trecho…',
                    hintStyle: AppTypography.body(size: 11, color: AppColors.dim),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                'REGISTRAR',
                onTap: _send,
                primary: s.logDraft.trim().isNotEmpty,
              ),
              const SizedBox(height: 9),
              Text(
                'Só você lê o diário de bordo — ao contrário do recado de bastão, não fica pra quem vem depois.',
                style: AppTypography.body(size: 9.5, color: AppColors.dim),
              ),
            ],
          ),
        ),
      );
  }
}
