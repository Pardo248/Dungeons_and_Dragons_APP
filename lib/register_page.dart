import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';
import 'package:sqflite/sqflite.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text != _pass2Ctrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await DatabaseHelper.instance.insertUser(
        _userCtrl.text.trim(),
        _passCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado')),
      );

      Navigator.pop(context);

    } on DatabaseException catch (e) {
      final msg = e.isUniqueConstraintError()
          ? 'El usuario ya existe'
          : 'Error de BD: ${e.toString()}';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // 🌟 APP BAR estilo pergamino
      appBar: AppBar(
        title: const Text(
          'REGISTRO',
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

      // 🌟 FONDO TOTAL
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

              // 🌟 FORMULARIO
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // --- USUARIO ---
                    TextFormField(
                      controller: _userCtrl,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
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

                    // --- CONTRASEÑA ---
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
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
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 12),

                    // --- CONFIRMAR CONTRASEÑA ---
                    TextFormField(
                      controller: _pass2Ctrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
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
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 20),

                    // 🌟 BOTÓN REGISTRARSE
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _register,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.button,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Registrarse'),
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
