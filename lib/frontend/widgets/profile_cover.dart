import 'package:flutter/material.dart';

/// Plano de fundo do caderno: a imagem vinculada em Ajustes, ou a key art
/// do app como padrão — nunca em branco.
class ProfileCover extends StatelessWidget {
  final String coverUrl;
  final double height;
  const ProfileCover({required this.coverUrl, this.height = 100, super.key});

  Widget _fallback() => Image.asset(
        'assets/art/keyart-limpa.png',
        fit: BoxFit.cover,
        alignment: const Alignment(0, -0.6),
      );

  @override
  Widget build(BuildContext c) => SizedBox(
        width: double.infinity,
        height: height,
        child: coverUrl.isEmpty
            ? _fallback()
            : Image.network(coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()),
      );
}
