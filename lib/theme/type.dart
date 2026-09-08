import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ink.dart';

/// Barlow Condensed para rótulos e números; Inter para texto corrido.
class T {
  static const _tab = [FontFeature.tabularFigures()];

  /// Rótulo caixa-alta espaçado — a voz visual do app.
  static TextStyle label(
          {double size = 10,
          Color color = Ink_.text3,
          FontWeight weight = FontWeight.w600,
          double tracking = 0.18}) =>
      GoogleFonts.barlowCondensed(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: size * tracking,
        height: 1.1,
      );

  /// Número grande, sempre com dígitos de largura fixa.
  static TextStyle num(
          {double size = 28,
          Color color = Ink_.textStrong,
          FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.barlowCondensed(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1,
        fontFeatures: _tab,
      );

  /// Texto corrido.
  static TextStyle body(
          {double size = 10, Color color = Ink_.text2, double height = 1.5}) =>
      GoogleFonts.inter(fontSize: size, color: color, height: height);
}
