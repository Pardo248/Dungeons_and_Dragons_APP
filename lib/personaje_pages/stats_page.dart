import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/widgets/bottom_nav.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final title = (args?['personName'] != null) ? 'STATS – ${args!['personName']}' : 'STATS';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('STATS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomNav(args: args),
    );
  }
}
