import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';
import 'package:proyecto_diego_castillo/add_character.dart';
import 'package:proyecto_diego_castillo/personaje_pages/PersonagePages.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Si por alguna razón no hay usuario logueado
      if (DatabaseHelper.instance.currentUserId == null) {
        setState(() {
          _items = [];
          _error =
              'No hay usuario autenticado. Vuelve a iniciar sesión para ver tus personajes.';
        });
        return;
      }

      final data = await DatabaseHelper.instance.getCharacters();
      setState(() => _items = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAdd() async {
    final int? newId = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const AddCharacterPage()),
    );

    if (newId != null) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Personaje creado (ID: $newId)')),
      );
    }
  }

  void _openStats(Map<String, dynamic> p) {
    Navigator.pushNamed(
      context,
      '/PersonagePages',
      arguments: {
        'personId': p['id'],
        'personName': p['name'],
        'personClass': p['class'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Text(
          _error!,
          style: const TextStyle(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_items.isEmpty) {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: const [
            SizedBox(height: 160),
            Center(
              child: Text(
                'No hay personajes. Pulsa + para añadir',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: Colors.black26,
          ),
          itemBuilder: (context, i) {
            final p = _items[i];
            return Card(
              color: AppColors.textFieldBackground.withOpacity(0.9),
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.person, color: AppColors.secondary),
                title: Text(
                  p['name'] ?? '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  p['class'] ?? '',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                trailing:
                    const Icon(Icons.chevron_right, color: AppColors.secondary),
                onTap: () => _openStats(p),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personajes',
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(AppImages.backgroundNet),
            fit: BoxFit.cover,
          ),
        ),
        child: body,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: AppColors.button,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Añadir',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
