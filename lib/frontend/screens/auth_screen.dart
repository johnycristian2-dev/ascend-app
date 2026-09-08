import 'package:flutter/material.dart';
import '../app.dart';
import '../../backend/state/expedition_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Acesso: entrar ou criar conta de verdade (Firebase Auth), não mais um
/// atalho decorativo. `CRIAR CONTA` manda pra avaliação inicial, que é
/// quem grava o primeiro documento do caderno no Firestore.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _signUp = false;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fieldName = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fieldName.dispose();
    super.dispose();
  }

  Future<void> _submit(ExpeditionState s) async {
    setState(() => _error = null);
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Preencha e-mail e senha.');
      return;
    }
    final err = _signUp
        ? await s.signUp(email: email, password: password, fieldName: _fieldName.text)
        : await s.signIn(email: email, password: password);
    if (err != null && mounted) setState(() => _error = err);
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text('ASCEND', style: AppTypography.num(size: 34, color: AppColors.text)),
              const SizedBox(height: 8),
              Text(
                'Registro de quem sobe. Rank, desnível e histórico ficam com você.',
                style: AppTypography.body(size: 11),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _ModeTab(
                      label: 'ENTRAR',
                      active: !_signUp,
                      onTap: () => setState(() => _signUp = false),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: _ModeTab(
                      label: 'CRIAR CONTA',
                      active: _signUp,
                      onTap: () => setState(() => _signUp = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_signUp) ...[
                _AuthField(label: 'nome de campo', controller: _fieldName),
                const SizedBox(height: 10),
              ],
              _AuthField(label: 'e-mail', controller: _email, type: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _AuthField(label: 'senha', controller: _password, obscure: true),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: AppTypography.body(size: 10.5, color: AppColors.amber)),
              ],
              const SizedBox(height: 14),
              AppButton(
                s.authLoading
                    ? 'UM MOMENTO…'
                    : _signUp
                        ? 'CRIAR E AVALIAR MEU NÍVEL'
                        : 'ENTRAR NO CADERNO',
                onTap: s.authLoading ? null : () => _submit(s),
                primary: true,
              ),
              const Spacer(),
              Text(
                'Ao entrar você concorda em manter suas informações de altitude e posição precisas — outras cordadas dependem disso.',
                style: AppTypography.body(size: 10, color: AppColors.dim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext c) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          color: active ? AppColors.raised : AppColors.surfaceAlt,
          child: Center(
            child: AppLabel(label,
                color: active ? AppColors.text : AppColors.dim, size: 11, tracking: 0.16),
          ),
        ),
      );
}

class _AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? type;
  const _AuthField({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.type,
  });

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.body(size: 10, color: AppColors.dim)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border.all(color: AppColors.borderInput),
              borderRadius: r4,
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: type,
              style: AppTypography.body(size: 13, color: AppColors.text),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      );
}
