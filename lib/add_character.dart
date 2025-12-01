import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';

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
      // devolvemos el ID del personaje creado
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
      // 🧾 AppBar con pergamino
      appBar: AppBar(
        title: const Text(
          'Nuevo personaje',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(AppImages.pergamNet),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),

      // 🏰 Fondo épico
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(AppImages.backgroundNet),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre del personaje
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre del personaje',
                        filled: true,
                        fillColor: AppColors.textFieldBackground,
                        labelStyle:
                            const TextStyle(color: AppColors.textPrimary),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.secondary),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),

                    // Clase
                    TextFormField(
                      controller: _classCtrl,
                      decoration: InputDecoration(
                        labelText: 'Clase',
                        filled: true,
                        fillColor: AppColors.textFieldBackground,
                        labelStyle:
                            const TextStyle(color: AppColors.textPrimary),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.secondary),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.button,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
