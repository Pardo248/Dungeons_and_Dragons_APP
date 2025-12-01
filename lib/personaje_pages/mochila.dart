import 'package:flutter/material.dart';

class MochilaPage extends StatelessWidget {
  final String? personName;

  const MochilaPage({super.key, this.personName});

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
