import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/personaje_pages/stats_page.dart';
import 'package:proyecto_diego_castillo/personaje_pages/habilidades_page.dart';
import 'package:proyecto_diego_castillo/personaje_pages/mochila.dart';
import 'package:proyecto_diego_castillo/personaje_pages/historia.dart';
import 'package:proyecto_diego_castillo/widgets/bottom_nav.dart';

class PersonajePager extends StatefulWidget {
  final Map<String, dynamic>? args;

  const PersonajePager({super.key, this.args});

  @override
  State<PersonajePager> createState() => _PersonajePagerState();
}

class _PersonajePagerState extends State<PersonajePager> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  String get _personName => widget.args?['personName'] as String? ?? 'Personaje';

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
          StatsPage(personName: _personName),
          HabilidadesPage(personName: _personName),
          MochilaPage(personName: _personName),
          HistoriaPage(personName: _personName),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
