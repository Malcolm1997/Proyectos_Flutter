import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.desktop_windows, 'label': 'Equipos'},
      {'icon': Icons.calendar_today, 'label': 'Agenda'},
      {'icon': Icons.history, 'label': 'Historial'},
      {'icon': Icons.settings, 'label': 'Ajustes'},
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Material(
          color: Colors.transparent,
          elevation: 12,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 6))],
            ),
            child: Row(
              children: List.generate(items.length, (i) {
                final it = items[i];
                final selected = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: selected ? const EdgeInsets.symmetric(vertical: 8, horizontal: 14) : const EdgeInsets.all(6),
                      decoration: selected
                          ? BoxDecoration(color: AppColors.primary.withOpacity(0.16), borderRadius: BorderRadius.circular(20))
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(it['icon'] as IconData, size: selected ? 22 : 20, color: selected ? Colors.white : Colors.white70),
                          if (selected) const SizedBox(width: 8),
                          if (selected) Text(it['label'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
