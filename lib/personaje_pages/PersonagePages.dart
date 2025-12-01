import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/personaje_pages/stats_page.dart';
import 'package:proyecto_diego_castillo/personaje_pages/habilidades_page.dart';
import 'package:proyecto_diego_castillo/personaje_pages/mochila.dart';
import 'package:proyecto_diego_castillo/personaje_pages/historia.dart';
import 'package:proyecto_diego_castillo/widgets/bottom_nav.dart';

class PersonajePager extends StatefulWidget {
  const PersonajePager({super.key});

  @override
  State<PersonajePager> createState() => _PersonajePagerState();
}

class _PersonajePagerState extends State<PersonajePager> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  late final int _personId;
  late final String _personName;
  String? _personClass;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      // fallback de seguridad para no crashear
      _personId = -1;
      _personName = 'Personaje';
      _personClass = null;
      debugPrint('[PersonajePager] args ES NULL, usando valores por defecto');
    } else {
      _personId = args['personId'] as int;
      _personName = args['personName'] as String? ?? 'Personaje';
      _personClass = args['personClass'] as String?;
      debugPrint(
        '[PersonajePager] args OK → id=$_personId, name=$_personName, class=$_personClass',
      );
    }
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Stats – $_personName';
      case 1:
        return 'Habilidades – $_personName';
      case 2:
        return 'Mochila – $_personName';
      case 3:
        return 'My HISTORIA / $_personName';
      default:
        return _personName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_currentIndex)),
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
        },
        children: [
          StatsPage(
            personName: _personName,
            personId: _personId,
          ),
          HabilidadesPage(
            personName: _personName,
            personId: _personId,
          ),
          MochilaPage(
            personName: _personName,
            personId: _personId,
          ),
          HistoriaPage(
            personName: _personName,
            personId: _personId,
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
