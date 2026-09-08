import 'dart:async';
import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Abertura: boot de 0 a 100 em passos de 4 a cada 70 ms, cai em auth.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? t;

  @override
  void initState() {
    super.initState();
    final s = Expedition.readOf(context);
    t = Timer.periodic(const Duration(milliseconds: 70), (_) {
      s.tickBoot();
      if (s.bootPct >= 100) {
        t?.cancel();
        // Sessão já existe (Firebase Auth)? Pula direto pro caderno.
        s.finishBoot();
      }
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const KeyArtBackground(
            opacity: .55,
            alignment: Alignment(0, -0.76),
            stops: [0, .34, .78, 1],
            veilOpacities: [.55, .2, .92, 1],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('assets/art/emblema-alpha.png',
                        width: 112, height: 112, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 20),
                  Text('ASCEND', style: AppTypography.num(size: 46, color: AppColors.text)),
                  const SizedBox(height: 6),
                  const AppLabel('REGISTRO DE ALTITUDE', color: AppColors.dim, size: 10),
                  const SizedBox(height: 40),
                  AppProgressBar(s.bootPct / 100, color: AppColors.amber),
                  const SizedBox(height: 10),
                  AppLabel('CARREGANDO RELEVO · ${s.bootPct}%', color: AppColors.dim, size: 9),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
