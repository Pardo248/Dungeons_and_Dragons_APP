import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/widgets/bottom_nav.dart';

class MochilaPage extends StatelessWidget {
  const MochilaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final title = (args?['personName'] != null) ? 'Mochila – ${args!['personName']}' : 'Mochila';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('MOCHILA', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomNav(args: args),
    );
  }
}
