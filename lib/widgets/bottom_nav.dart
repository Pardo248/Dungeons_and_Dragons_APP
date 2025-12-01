import 'package:flutter/material.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: currentIndex == 0 ? Colors.purple : Colors.grey,
              ),
              onPressed: () => onTap(0),
            ),
            IconButton(
              icon: Icon(
                Icons.flash_on,
                color: currentIndex == 1 ? Colors.purple : Colors.grey,
              ),
              onPressed: () => onTap(1),
            ),
            IconButton(
              icon: Icon(
                Icons.backpack,
                color: currentIndex == 2 ? Colors.purple : Colors.grey,
              ),
              onPressed: () => onTap(2),
            ),
            IconButton(
              icon: Icon(
                Icons.book,
                color: currentIndex == 3 ? Colors.purple : Colors.grey,
              ),
              onPressed: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
