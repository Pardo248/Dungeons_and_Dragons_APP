import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.initDB(); // inicializa de inmediato
  }

  Future<void> _login() async {
    //await DatabaseHelper.instance.initDB();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final ok = await DatabaseHelper.instance.validateUser(
        _userCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacementNamed(context, '/screen3');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña inválidos')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  APP BAR con imagen del pergamino
      appBar: AppBar(
        title: Text(
          'Diego Castillo Pardo',
          style: const TextStyle(
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

      //  FONDO COMPLETO
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(AppImages.backgroundNet),
            fit: BoxFit.cover,
          ),
        ),

        // ⭐ FORMULARIO EN EL CENTRO
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
                    // ⭐ Usuario
                    TextFormField(
                      controller: _userCtrl,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        fillColor: AppColors.textFieldBackground,
                        filled: true,
                        labelStyle: const TextStyle(
                          color: AppColors.textPrimary,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 12),

                    // ⭐ Contraseña
                    TextFormField(
                      controller: _passCtrl,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        fillColor: AppColors.textFieldBackground,
                        filled: true,
                        labelStyle: const TextStyle(
                          color: AppColors.textPrimary,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                      ),
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 16),

                    // ⭐ Botón principal
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.button,
                        ),
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Iniciar'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
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
