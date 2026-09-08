import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/ink.dart';
import 'atoms.dart';

class BottomNav extends StatelessWidget {
  final String active;
  const BottomNav({required this.active, super.key});

  static const _items = [
    ('home', 'MAPA', Icons.terrain),
    ('chat', 'CORDADA', Icons.forum_outlined),
    ('profile', 'CADERNO', Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Container(
      decoration: const BoxDecoration(
        color: Ink_.chrome,
        border: Border(top: BorderSide(color: Ink_.hair)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: _items.map((i) {
          final on = i.$1 == active;
          return Expanded(
            child: InkWell(
              onTap: () => s.go(i.$1),
              child: Column(
                children: [
                  Icon(i.$3, size: 18, color: on ? Ink_.amber : Ink_.dim),
                  const SizedBox(height: 5),
                  Lbl(i.$2, color: on ? Ink_.text : Ink_.dim, size: 8, tracking: 0.16),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
