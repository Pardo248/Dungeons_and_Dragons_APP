import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';
import 'package:proyecto_diego_castillo/add_character.dart';
import 'package:proyecto_diego_castillo/personaje_pages/stats_page.dart';

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
      final data = await DatabaseHelper.instance.getCharacters();
      setState(() => _items = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAdd() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddCharacterPage()),
    );
    // Si la pantalla de agregar regresó true, recarga la lista
    if (created == true) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personaje creado')),
      );
    }
  }

  void _openStats(Map<String, dynamic> p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StatsPage(),
        settings: RouteSettings(arguments: {
          'personId': p['id'],
          'personName': p['name'],
          'personClass': p['class'],
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text('Error: $_error'));
    } else if (_items.isEmpty) {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: const [
            SizedBox(height: 160),
            Center(child: Text('No hay personajes. Pulsa + para añadir')),
          ],
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          itemCount: _items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final p = _items[i];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(p['name'] ?? ''),
              subtitle: Text(p['class'] ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openStats(p), // 👈 cada personaje es un botón
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Personajes')),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd, // 👈 añade y refresca
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
      ),
    );
  }
}