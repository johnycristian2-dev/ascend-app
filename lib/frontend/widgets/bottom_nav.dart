import 'package:flutter/material.dart';
import '../app.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';

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
        color: AppColors.chrome,
        border: Border(top: BorderSide(color: AppColors.hair)),
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
                  Icon(i.$3, size: 18, color: on ? AppColors.amber : AppColors.dim),
                  const SizedBox(height: 5),
                  AppLabel(i.$2, color: on ? AppColors.text : AppColors.dim, size: 8, tracking: 0.16),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
