import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';

class AddCharacterPage extends StatefulWidget {
  const AddCharacterPage({super.key});

  @override
  State<AddCharacterPage> createState() => _AddCharacterPageState();
}

class _AddCharacterPageState extends State<AddCharacterPage> {
  final _nameCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _saving = true);
  try {
    final newId = await DatabaseHelper.instance.insertCharacter(
      _nameCtrl.text.trim(),
      _classCtrl.text.trim(),
    );

    if (!mounted) return;

    // ⬅⬅ devolvemos el ID del personaje creado
    Navigator.pop(context, newId);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}


  @override
  void dispose() {
    _nameCtrl.dispose();
    _classCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo personaje')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del personaje',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _classCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Clase',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
