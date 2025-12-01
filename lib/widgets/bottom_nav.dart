import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.textFieldBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navButton(0, AppLogos.stats),
          _navButton(1, AppLogos.habilidades),
          _navButton(2, AppLogos.cofre),
          _navButton(3, AppLogos.historia),
        ],
      ),
    );
  }

  Widget _navButton(int index, String imageUrl) {
    return IconButton(
      onPressed: () => onTap(index),
      iconSize: 32,
      icon: ImageIcon(
        NetworkImage(imageUrl),
        color: currentIndex == index
            ? AppColors.secondary      
            : AppColors.textPrimary,   
      ),
    );
  }
}
