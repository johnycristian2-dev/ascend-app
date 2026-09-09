import 'package:flutter/material.dart';

/// Avatar circular do caderno: a foto vinculada em Ajustes (um link, o
/// app não hospeda upload nenhum), ou o retrato padrão da key art se
/// nenhuma foi definida — ou se o link não carregar.
class ProfileAvatar extends StatelessWidget {
  final String photoUrl;
  final double size;
  const ProfileAvatar({required this.photoUrl, this.size = 84, super.key});

  Widget _fallback() => Transform.scale(
        scale: 2.3,
        alignment: const Alignment(-0.1, -0.92),
        child: Image.asset('assets/art/keyart-limpa.png', fit: BoxFit.cover),
      );

  @override
  Widget build(BuildContext c) => ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: photoUrl.isEmpty
              ? _fallback()
              : Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback()),
        ),
      );
}
