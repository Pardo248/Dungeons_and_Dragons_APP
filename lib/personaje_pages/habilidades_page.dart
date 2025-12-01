import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/widgets/bottom_nav.dart';

class HabilidadesPage extends StatelessWidget {
  final String? personName;
  const HabilidadesPage({super.key, this.personName});

  @override
  Widget build(BuildContext context) {
    final title = personName != null ? 'Mochila – $personName' : 'Mochila';

    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}
