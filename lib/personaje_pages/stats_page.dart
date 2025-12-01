import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/widgets/bottom_nav.dart';

class StatsPage extends StatelessWidget {
  final String? personName;
  final String? personClass;
  const StatsPage({super.key, this.personName , this.personClass});

  @override
  Widget build(BuildContext context) {
    //final title = personName != null ? 'Mochila – $personName' : 'Mochila';

    return Container(
      width: double.infinity,
      color: Colors.amber,
      child: Center(
        child: Text("Stats de $personName, Clase: $personClass"),
      )
      /*child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$personName',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),*/
      /* child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),*/
    );
  }
}
