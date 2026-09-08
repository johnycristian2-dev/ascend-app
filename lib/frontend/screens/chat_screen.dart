import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Cordada: mensagens e posições, com recado preso ao ponto do mapa.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        const ScreenBar('CORDADA SUL', sub: '4 integrantes · 3 online'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            children: [
              ...s.msgs.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: AppPanel(
                          bg: m.me ? AppColors.raised : AppColors.surface,
                          borderColor: m.me ? AppColors.borderRaised : AppColors.border,
                          padding: const EdgeInsets.all(11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppLabel(m.who, color: AppColors.text3, size: 8, tracking: 0.16),
                                  const SizedBox(width: 7),
                                  Text(m.time, style: AppTypography.body(size: 8.5, color: AppColors.dim)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(m.text, style: AppTypography.body(size: 11, color: AppColors.text)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 4),
              AppPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(11),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, size: 15, color: AppColors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Posições da cordada · atualizado há 1 min. Kai fora de alcance desde 08:26.',
                              style: AppTypography.body(size: 10.5, color: AppColors.text3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.hair, height: 1),
                    InkWell(
                      onTap: () => s.go('relay'),
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: Row(
                          children: [
                            const Icon(Icons.push_pin_outlined, size: 15, color: AppColors.blue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('Recado fica preso ao ponto do mapa.',
                                  style: AppTypography.body(size: 10.5, color: AppColors.text3)),
                            ),
                            const Icon(Icons.chevron_right, size: 15, color: AppColors.dim),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: AppColors.chrome,
            border: Border(top: BorderSide(color: AppColors.hair)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.borderInput),
                    borderRadius: r4,
                  ),
                  child: TextField(
                    onChanged: s.setDraft,
                    onSubmitted: (_) => s.send(),
                    style: AppTypography.body(size: 11, color: AppColors.text),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
                      hintText: 'Mensagem para a cordada…',
                      hintStyle: AppTypography.body(size: 11, color: AppColors.dim),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 74,
                child: AppButton('ENVIAR', onTap: s.send, primary: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
