import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';

class StatsPage extends StatefulWidget {
  final String? personName;
  final int? personId;

  const StatsPage({super.key, this.personName, this.personId});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _loading = true;
  int _level = 1;

  // Controllers para atributos
  final _strScoreCtrl = TextEditingController();
  final _strModCtrl = TextEditingController();
  final _dexScoreCtrl = TextEditingController();
  final _dexModCtrl = TextEditingController();
  final _conScoreCtrl = TextEditingController();
  final _conModCtrl = TextEditingController();
  final _intScoreCtrl = TextEditingController();
  final _intModCtrl = TextEditingController();
  final _wisScoreCtrl = TextEditingController();
  final _wisModCtrl = TextEditingController();
  final _chaScoreCtrl = TextEditingController();
  final _chaModCtrl = TextEditingController();

  // Otros
  final _inspCtrl = TextEditingController();
  final _profBonusCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _strScoreCtrl.dispose();
    _strModCtrl.dispose();
    _dexScoreCtrl.dispose();
    _dexModCtrl.dispose();
    _conScoreCtrl.dispose();
    _conModCtrl.dispose();
    _intScoreCtrl.dispose();
    _intModCtrl.dispose();
    _wisScoreCtrl.dispose();
    _wisModCtrl.dispose();
    _chaScoreCtrl.dispose();
    _chaModCtrl.dispose();
    _inspCtrl.dispose();
    _profBonusCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    await DatabaseHelper.instance.initDB();

    if (widget.personId == null) {
      setState(() => _loading = false);
      return;
    }

    // Cargar nivel del personaje
    final character = await DatabaseHelper.instance.getCharacterById(
      widget.personId!,
    );
    _level = (character?['level'] ?? 1) as int;

    // Cargar stats si existen
    final stats = await DatabaseHelper.instance.getCharacterStats(
      widget.personId!,
    );

    if (stats == null) {
      // Valores por defecto
      _strScoreCtrl.text = '13';
      _strModCtrl.text = '+1';
      _dexScoreCtrl.text = '13';
      _dexModCtrl.text = '+1';
      _conScoreCtrl.text = '14';
      _conModCtrl.text = '+2';
      _intScoreCtrl.text = '15';
      _intModCtrl.text = '+2';
      _wisScoreCtrl.text = '15';
      _wisModCtrl.text = '+2';
      _chaScoreCtrl.text = '12';
      _chaModCtrl.text = '+1';

      _inspCtrl.text = '0';
      _profBonusCtrl.text = '+2';
    } else {
      _strScoreCtrl.text = (stats['str_score'] ?? 13).toString();
      _strModCtrl.text = _formatMod(stats['str_mod'] ?? 1);
      _dexScoreCtrl.text = (stats['dex_score'] ?? 13).toString();
      _dexModCtrl.text = _formatMod(stats['dex_mod'] ?? 1);
      _conScoreCtrl.text = (stats['con_score'] ?? 14).toString();
      _conModCtrl.text = _formatMod(stats['con_mod'] ?? 2);
      _intScoreCtrl.text = (stats['int_score'] ?? 15).toString();
      _intModCtrl.text = _formatMod(stats['int_mod'] ?? 2);
      _wisScoreCtrl.text = (stats['wis_score'] ?? 15).toString();
      _wisModCtrl.text = _formatMod(stats['wis_mod'] ?? 2);
      _chaScoreCtrl.text = (stats['cha_score'] ?? 12).toString();
      _chaModCtrl.text = _formatMod(stats['cha_mod'] ?? 1);

      _inspCtrl.text = (stats['inspiration'] ?? 0).toString();
      _profBonusCtrl.text = _formatMod(stats['proficiency_bonus'] ?? 2);
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  String _formatMod(int value) {
    if (value >= 0) return '+$value';
    return value.toString();
  }

  int _parseMod(String text, {int defaultValue = 0}) {
    final t = text.trim();
    if (t.isEmpty) return defaultValue;
    final clean = t.replaceAll('+', '');
    final v = int.tryParse(clean);
    return v ?? defaultValue;
  }

  int _parseInt(String text, {int defaultValue = 0}) {
    final t = text.trim();
    if (t.isEmpty) return defaultValue;
    final v = int.tryParse(t);
    return v ?? defaultValue;
  }

  Future<void> _saveStats() async {
    if (widget.personId == null) {
      debugPrint('[_saveStats] personId es null, NO guardo');
      return;
    }

    debugPrint('[_saveStats] guardando stats para personId=${widget.personId}');

    final strScore = _parseInt(_strScoreCtrl.text, defaultValue: 13);
    final strMod = _parseMod(_strModCtrl.text, defaultValue: 1);
    final dexScore = _parseInt(_dexScoreCtrl.text, defaultValue: 13);
    final dexMod = _parseMod(_dexModCtrl.text, defaultValue: 1);
    final conScore = _parseInt(_conScoreCtrl.text, defaultValue: 14);
    final conMod = _parseMod(_conModCtrl.text, defaultValue: 2);
    final intScore = _parseInt(_intScoreCtrl.text, defaultValue: 15);
    final intMod = _parseMod(_intModCtrl.text, defaultValue: 2);
    final wisScore = _parseInt(_wisScoreCtrl.text, defaultValue: 15);
    final wisMod = _parseMod(_wisModCtrl.text, defaultValue: 2);
    final chaScore = _parseInt(_chaScoreCtrl.text, defaultValue: 12);
    final chaMod = _parseMod(_chaModCtrl.text, defaultValue: 1);

    final inspiration = _parseInt(_inspCtrl.text, defaultValue: 0);
    final profBonus = _parseMod(_profBonusCtrl.text, defaultValue: 2);

    await DatabaseHelper.instance.upsertCharacterStats(
      widget.personId!,
      strScore: strScore,
      strMod: strMod,
      dexScore: dexScore,
      dexMod: dexMod,
      conScore: conScore,
      conMod: conMod,
      intScore: intScore,
      intMod: intMod,
      wisScore: wisScore,
      wisMod: wisMod,
      chaScore: chaScore,
      chaMod: chaMod,
      inspiration: inspiration,
      proficiencyBonus: profBonus,
    );
  }

  Future<void> _levelUp() async {
    if (widget.personId == null) return;

    setState(() {
      _level += 1;
    });

    await DatabaseHelper.instance.updateCharacterLevel(
      widget.personId!,
      _level,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡$levelText ha subido a nivel $_level!')),
    );
  }

  String get levelText =>
      widget.personName != null ? widget.personName! : 'El personaje';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Esta página vive dentro de PersonajePager, que ya tiene Scaffold y fondo.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: const TextStyle(color: AppColors.textPrimary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nivel + botón subir nivel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nivel: $_level',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _levelUp,
                  child: const Text('LVL UP'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _titulo("Atributos"),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(
                  nombre: "STR",
                  modController: _strModCtrl,
                  valorController: _strScoreCtrl,
                  onChanged: _saveStats,
                ),
                _StatCard(
                  nombre: "DEX",
                  modController: _dexModCtrl,
                  valorController: _dexScoreCtrl,
                  onChanged: _saveStats,
                ),
                _StatCard(
                  nombre: "CON",
                  modController: _conModCtrl,
                  valorController: _conScoreCtrl,
                  onChanged: _saveStats,
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(
                  nombre: "INT",
                  modController: _intModCtrl,
                  valorController: _intScoreCtrl,
                  onChanged: _saveStats,
                ),
                _StatCard(
                  nombre: "WIS",
                  modController: _wisModCtrl,
                  valorController: _wisScoreCtrl,
                  onChanged: _saveStats,
                ),
                _StatCard(
                  nombre: "CHA",
                  modController: _chaModCtrl,
                  valorController: _chaScoreCtrl,
                  onChanged: _saveStats,
                ),
              ],
            ),

            const SizedBox(height: 25),
            _titulo("Otros"),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BoxGrandeEditable(
                  titulo: "Inspiración",
                  controller: _inspCtrl,
                  onChanged: _saveStats,
                ),
                _BoxGrandeEditable(
                  titulo: "Bonificador por competencia",
                  controller: _profBonusCtrl,
                  onChanged: _saveStats,
                ),
              ],
            ),

            const SizedBox(height: 25),

            _titulo("Tiradas de Salvación"),
            const SizedBox(height: 8),
            _listaCheckboxEditable([
              "+1 Fuerza",
              "+1 Destreza",
              "+4 Constitución",
              "+2 Inteligencia",
              "+2 Sabiduría",
              "+3 Carisma",
            ]),

            const SizedBox(height: 25),

            _titulo("Habilidades"),
            const SizedBox(height: 8),
            _listaCheckboxEditable([
              "+1 Acrobacias (Des)",
              "+1 Atletismo (Fue)",
              "+4 C. Arcano (Int)",
              "+3 Engaño (Car)",
              "+2 Historia (Int)",
              "+1 Interpretación (Car)",
              "+2 Intimidación (Car)",
              "+2 Investigación (Int)",
              "+1 Juego de Manos (Des)",
              "+2 Medicina (Sab)",
              "+2 Naturaleza (Int)",
              "+2 Percepción (Sab)",
              "+2 Persuasión (Car)",
              "+2 Religión (Int)",
              "+2 Sigilo (Des)",
              "+2 Supervivencia (Sab)",
              "+2 Trato con Animales (Sab)",
            ]),
          ],
        ),
      ),
    );
  }

  // Título estilo hoja
  Widget _titulo(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// -------------------------------
// Cajas de atributos (+1 y 13) EDITABLES con autosave
// -------------------------------
class _StatCard extends StatelessWidget {
  final String nombre;
  final TextEditingController modController;
  final TextEditingController valorController;
  final Future<void> Function() onChanged;

  const _StatCard({
    required this.nombre,
    required this.modController,
    required this.valorController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.textFieldBackground.withOpacity(0.9),
        border: Border.all(width: 2, color: AppColors.secondary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            nombre,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: modController,
            textAlign: TextAlign.center,
            onChanged: (_) => onChanged(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 3),
          TextField(
            controller: valorController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------
// Caja grande editable (Inspiración/Competencia) con autosave
// -------------------------------
class _BoxGrandeEditable extends StatelessWidget {
  final String titulo;
  final TextEditingController controller;
  final Future<void> Function() onChanged;

  const _BoxGrandeEditable({
    required this.titulo,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.textFieldBackground.withValues(),
        border: Border.all(width: 2, color: AppColors.secondary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            onChanged: (_) => onChanged(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------
// Lista con checkboxes (visual solamente)
// -------------------------------
Widget _listaCheckboxEditable(List<String> items) {
  return Column(children: items.map((e) => _CheckboxRow(label: e)).toList());
}

class _CheckboxRow extends StatefulWidget {
  final String label;

  const _CheckboxRow({required this.label});

  @override
  State<_CheckboxRow> createState() => _CheckboxRowState();
}

class _CheckboxRowState extends State<_CheckboxRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _checked,
          activeColor: AppColors.secondary,
          checkColor: AppColors.textPrimary,
          onChanged: (v) {
            setState(() => _checked = v ?? false);
            // Aquí podrías guardar en BD si luego lo necesitas.
          },
        ),
        Expanded(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
