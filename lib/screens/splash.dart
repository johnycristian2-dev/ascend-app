import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import '../theme/type.dart';
import '../widgets/atoms.dart';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ASCEND', style: T.num(size: 46, color: Ink_.text)),
              const SizedBox(height: 6),
              const Lbl('REGISTRO DE ALTITUDE', color: Ink_.dim, size: 10),
              const SizedBox(height: 40),
              Bar(s.bootPct / 100, color: Ink_.amber),
              const SizedBox(height: 10),
              Lbl('CARREGANDO RELEVO · ${s.bootPct}%', color: Ink_.dim, size: 9),
            ],
          ),
        ),
      ),
    );
  }
}
