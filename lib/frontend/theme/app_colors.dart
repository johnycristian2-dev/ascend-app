import 'package:flutter/material.dart';

/// Paleta do protótipo. Não invente cores fora daqui.
class AppColors {
  static const bg = Color(0xFF14161A);
  static const surface = Color(0xFF1A1D21);
  static const surfaceAlt = Color(0xFF191C20);
  static const raised = Color(0xFF242A31);
  static const border = Color(0xFF2E333A);
  static const borderRaised = Color(0xFF3A424C);
  static const borderInput = Color(0xFF2A3038);
  static const borderWarn = Color(0xFF4A3427);
  static const borderStale = Color(0xFF33302C);
  static const bgWarn = Color(0xFF1D1A18);
  static const bgOk = Color(0xFF1E2420);
  static const chrome = Color(0xFF171A1E);
  static const hair = Color(0xFF262B31);

  static const text = Color(0xFFE6E8E5);
  static const textStrong = Color(0xFFF2F4F0);
  static const text2 = Color(0xFF9DA29E);
  static const text3 = Color(0xFF8A8F8B);
  static const dim = Color(0xFF6E736F);

  static const amber = Color(0xFFC2703F);
  static const green = Color(0xFF7C8A6E);
  static const blue = Color(0xFF8FA9C0);

  /// Qualidade do bloco de previsão: 0 bom, 1 marginal, 2 ruim.
  static const q = [green, blue, amber];

  /// Índices usados pelos dados: 0 azul, 1 verde, 2 âmbar, 3 cinza.
  static const tagInks = [blue, green, amber, text3];
}

const r4 = BorderRadius.all(Radius.circular(4));
