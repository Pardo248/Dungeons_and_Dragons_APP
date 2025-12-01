import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/widgets/bottom_nav.dart';

class HistoriaPage extends StatelessWidget {
  final String? personName;
  const HistoriaPage({super.key, this.personName});

  @override
  Widget build(BuildContext context) {
    //final title = personName != null ? 'Historia de $personName' : 'Mochila';
    return Container(
      color: Colors.amber,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Transfondo: ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "Alineamiento:",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Rasgos de Personalidad",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Personalidad",
                fillColor: const Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Text(
            "Ideales",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Personalidad",
                fillColor: const Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Text("Vínculos"),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Personalidad",
                fillColor: const Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Text("Defectos"),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Personalidad",
                fillColor: const Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Text(
            "Diario del Aventurero",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                hintText: "Personalidad",
                fillColor: const Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
    /*return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );*/
  }
}
