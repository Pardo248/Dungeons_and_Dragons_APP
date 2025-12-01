import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/personaje_pages/stats_page.dart';
import 'package:proyecto_diego_castillo/personaje_pages/habilidades_page.dart';
import 'package:proyecto_diego_castillo/personaje_pages/mochila.dart';
import 'package:proyecto_diego_castillo/personaje_pages/historia.dart';
import 'package:proyecto_diego_castillo/widgets/bottom_nav.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';

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
        return 'Historia – $_personName';
      default:
        return _personName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🧾 AppBar con pergamino
      appBar: AppBar(
        title: Text(
          _titleForIndex(_currentIndex),
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

      // 🏰 Fondo + PageView
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(AppImages.backgroundNet),
            fit: BoxFit.cover,
          ),
        ),
        child: PageView(
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
      ),

      //  bottom nav que controla el PageView
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
