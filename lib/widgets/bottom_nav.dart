import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final Map<String, dynamic>? args;
  const BottomNav({super.key, this.args});

  void _go(BuildContext ctx, String route) {
    Navigator.pushReplacementNamed(ctx, route, arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilledButton(onPressed: () => _go(context, '/stats'), child: const Text('Stats')),
            FilledButton(onPressed: () => _go(context, '/habilidades'), child: const Text('Habilidades')),
            FilledButton(onPressed: () => _go(context, '/mochila'), child: const Text('Mochila')),
            FilledButton(onPressed: () => _go(context, '/historia'), child: const Text('Historia')),
          ],
        ),
      ),
    );
  }
}
