import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';

class HistoriaPage extends StatefulWidget {
  final String? personName;
  final int? personId;

  const HistoriaPage({super.key, this.personName, this.personId});

  @override
  State<HistoriaPage> createState() => _HistoriaPageState();
}

class _HistoriaPageState extends State<HistoriaPage> {
  final _rasgosCtrl = TextEditingController();
  final _idealesCtrl = TextEditingController();
  final _vinculosCtrl = TextEditingController();
  final _defectosCtrl = TextEditingController();
  final _diarioCtrl = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoria();
  }

  @override
  void dispose() {
    _rasgosCtrl.dispose();
    _idealesCtrl.dispose();
    _vinculosCtrl.dispose();
    _defectosCtrl.dispose();
    _diarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistoria() async {
    if (widget.personId == null) {
      setState(() => _loading = false);
      return;
    }

    await DatabaseHelper.instance.initDB();

    final data =
        await DatabaseHelper.instance.getHistoriaByPersonId(widget.personId!);

    _rasgosCtrl.text = (data?['personality_traits'] ?? '') as String;
    _idealesCtrl.text = (data?['ideals'] ?? '') as String;
    _vinculosCtrl.text = (data?['bonds'] ?? '') as String;
    _defectosCtrl.text = (data?['flaws'] ?? '') as String;
    _diarioCtrl.text = (data?['journal'] ?? '') as String;

    setState(() => _loading = false);
  }

  Future<void> _saveHistoria() async {
    if (widget.personId == null) return;

    final data = {
      'personality_traits': _rasgosCtrl.text.trim(),
      'ideals': _idealesCtrl.text.trim(),
      'bonds': _vinculosCtrl.text.trim(),
      'flaws': _defectosCtrl.text.trim(),
      'journal': _diarioCtrl.text.trim(),
    };

    await DatabaseHelper.instance.upsertHistoria(widget.personId!, data);
  }

  void _onFieldChanged() {
    _saveHistoria();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.amber,
      child: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Transfondo:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "Alineamiento:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // RASGOS
          const Text(
            "Rasgos de Personalidad",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _rasgosCtrl,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 2,
              onChanged: (_) => _onFieldChanged(),
              decoration: const InputDecoration(
                hintText: "Personalidad",
                filled: true,
                fillColor: Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // IDEALES
          const Text(
            "Ideales",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _idealesCtrl,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 2,
              onChanged: (_) => _onFieldChanged(),
              decoration: const InputDecoration(
                hintText: "Ideales",
                filled: true,
                fillColor: Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // VÍNCULOS
          const Text(
            "Vínculos",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _vinculosCtrl,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 2,
              onChanged: (_) => _onFieldChanged(),
              decoration: const InputDecoration(
                hintText: "Vínculos",
                filled: true,
                fillColor: Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // DEFECTOS
          const Text(
            "Defectos",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _defectosCtrl,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 2,
              onChanged: (_) => _onFieldChanged(),
              decoration: const InputDecoration(
                hintText: "Defectos",
                filled: true,
                fillColor: Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // DIARIO
          const Text(
            "Diario del Aventurero",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _diarioCtrl,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
              onChanged: (_) => _onFieldChanged(),
              decoration: const InputDecoration(
                hintText: "Escribe aquí tus aventuras...",
                filled: true,
                fillColor: Color.fromARGB(255, 149, 149, 149),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
