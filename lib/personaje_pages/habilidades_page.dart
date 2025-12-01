import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';

class HabilidadesPage extends StatefulWidget {
  final String? personName;
  final int? personId;

  const HabilidadesPage({super.key, this.personName, this.personId});

  @override
  State<HabilidadesPage> createState() => _HabilidadesPageState();
}

class _HabilidadesPageState extends State<HabilidadesPage> {
  final _aptitudCtrl = TextEditingController();
  final _cdCtrl = TextEditingController();
  final _ataqueCtrl = TextEditingController();

  bool _loading = true;
  int _characterLevel = 1;

  // slots por nivel (solo 1+)
  final Map<int, SpellSlot> _slots = {};
  // hechizos por nivel (incluye 0)
  final Map<int, List<CharacterSpell>> _spellsByLevel = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _aptitudCtrl.dispose();
    _cdCtrl.dispose();
    _ataqueCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.personId == null) {
      setState(() => _loading = false);
      return;
    }

    await DatabaseHelper.instance.initDB();

    // 1) Cargar personaje (nivel)
    final character = await DatabaseHelper.instance.getCharacterById(
      widget.personId!,
    );
    _characterLevel = (character?['level'] ?? 1) as int;

    // 2) Cargar stats mágicos
    final magic = await DatabaseHelper.instance.getCharacterMagic(
      widget.personId!,
    );

    _aptitudCtrl.text = (magic?['magic_ability'] ?? '').toString();
    _cdCtrl.text = (magic?['save_dc'] ?? '').toString();
    _ataqueCtrl.text = (magic?['attack_bonus'] ?? '').toString();

    // 3) Cargar slots por nivel (solo 1+)
    final slotsRows = await DatabaseHelper.instance.getSpellSlotsForCharacter(
      widget.personId!,
    );
    for (var row in slotsRows) {
      final lvl = row['level'] as int;
      _slots[lvl] = SpellSlot(
        level: lvl,
        maxSlots: (row['max_slots'] ?? 0) as int,
        usedSlots: (row['used_slots'] ?? 0) as int,
      );
    }

    // 4) Cargar hechizos por nivel (incluyendo nivel 0)
    for (int lvl = 0; lvl <= _characterLevel; lvl++) {
      final rows = await DatabaseHelper.instance.getSpellsByCharacterAndLevel(
        widget.personId!,
        lvl,
      );
      _spellsByLevel[lvl] = rows
          .map(
            (r) => CharacterSpell(
              id: r['id'] as int,
              level: r['level'] as int,
              name: r['name'] as String,
              description: (r['description'] ?? '') as String,
              known: ((r['known'] ?? 0) as int) == 1,
            ),
          )
          .toList();
    }

    setState(() => _loading = false);
  }

  Future<void> _saveMagicStats() async {
    if (widget.personId == null) return;

    final saveDc = int.tryParse(
      _cdCtrl.text.trim().isEmpty ? '0' : _cdCtrl.text.trim(),
    );
    final atkBonus = int.tryParse(
      _ataqueCtrl.text.trim().isEmpty ? '0' : _ataqueCtrl.text.trim(),
    );

    await DatabaseHelper.instance.upsertCharacterMagic(
      widget.personId!,
      magicAbility: _aptitudCtrl.text.trim(),
      saveDc: saveDc,
      attackBonus: atkBonus,
    );
  }

  Future<void> _saveSlot(int level) async {
    if (widget.personId == null) return;
    // No guardamos slots para nivel 0
    if (level == 0) return;

    final slot =
        _slots[level] ?? SpellSlot(level: level, maxSlots: 0, usedSlots: 0);
    await DatabaseHelper.instance.upsertSpellSlot(
      widget.personId!,
      level,
      maxSlots: slot.maxSlots,
      usedSlots: slot.usedSlots,
    );
  }

  Future<void> _addSpellDialog(int level) async {
    if (widget.personId == null) return;

    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar habilidad (nivel $level)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final newId = await DatabaseHelper.instance.insertSpell(
      characterId: widget.personId!,
      level: level,
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
    );

    setState(() {
      final list = _spellsByLevel[level] ?? [];
      list.add(
        CharacterSpell(
          id: newId,
          level: level,
          name: nameCtrl.text.trim(),
          description: descCtrl.text.trim(),
          known: true,
        ),
      );
      _spellsByLevel[level] = list;
    });
  }

  Future<void> _toggleKnown(CharacterSpell spell, bool value) async {
    await DatabaseHelper.instance.updateSpellKnown(spell.id, value);
    setState(() {
      final list = _spellsByLevel[spell.level] ?? [];
      final idx = list.indexWhere((s) => s.id == spell.id);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(known: value);
        _spellsByLevel[spell.level] = list;
      }
    });
  }

  Future<void> _useSpell(CharacterSpell spell) async {
    // Nivel 0 → trucos / cantrips ilimitados
    if (spell.level == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los trucos (nivel 0) tienen usos infinitos'),
        ),
      );
      return;
    }

    final slot =
        _slots[spell.level] ??
        SpellSlot(level: spell.level, maxSlots: 0, usedSlots: 0);

    final remaining = slot.maxSlots - slot.usedSlots;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No quedan usos para nivel ${spell.level}')),
      );
      return;
    }

    final updated = slot.copyWith(usedSlots: slot.usedSlots + 1);
    _slots[spell.level] = updated;
    await _saveSlot(spell.level);

    setState(() {});
  }

  void _showSpellInfo(CharacterSpell spell) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${spell.name} (ID: ${spell.id})'),
        content: Text(
          spell.description.isEmpty ? 'Sin descripción.' : spell.description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Vive dentro de PersonajePager (que ya tiene fondo), así que aquí solo layout y colores.
    return DefaultTextStyle(
      style: const TextStyle(color: AppColors.textPrimary),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ===== CABECERA DE STATS MÁGICOS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _conjureHelpers(
                "Aptitud Mágica",
                _aptitudCtrl,
                isNumber: false,
                onChanged: (_) => _saveMagicStats(),
              ),
              _conjureHelpers(
                "Clase de Dificultad",
                _cdCtrl,
                isNumber: true,
                onChanged: (_) => _saveMagicStats(),
              ),
              _conjureHelpers(
                "Bonificador de Ataque",
                _ataqueCtrl,
                isNumber: true,
                onChanged: (_) => _saveMagicStats(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ===== BLOQUES POR NIVEL (0 hasta nivel del personaje) =====
          Column(
            children: [
              for (int lvl = 0; lvl <= _characterLevel; lvl++)
                _conjuntoHabilidades(
                  lvl,
                  lvl == 0
                      ? null // Nivel 0 = sin slots
                      : _slots[lvl] ??
                          SpellSlot(level: lvl, maxSlots: 0, usedSlots: 0),
                  _spellsByLevel[lvl] ?? [],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conjuntoHabilidades(
    int level,
    SpellSlot? slot,
    List<CharacterSpell> spells,
  ) {
    return Card(
      color: AppColors.textFieldBackground.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          children: [
            // Título nivel + slots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  level == 0 ? "Nivel: 0 (Trucos)" : "Nivel: $level",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (level == 0) ...[
                  const Text(
                    "MAX: ∞",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    "Usos: ∞",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ] else ...[
                  Text(
                    "MAX: ${slot!.maxSlots}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "Usos: ${slot.maxSlots - slot.usedSlots}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            // Lista de habilidades
            Column(
              children: [
                for (final spell in spells) _habilidades(spell),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _addSpellDialog(level),
                    icon: const Icon(Icons.add, color: AppColors.secondary),
                    label: const Text(
                      'Agregar habilidad',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _habilidades(CharacterSpell spell) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: spell.known,
          activeColor: AppColors.secondary,
          checkColor: AppColors.textPrimary,
          onChanged: (bool? value) {
            if (value == null) return;
            _toggleKnown(spell, value);
          },
        ),
        TextButton(
          onPressed: () => _useSpell(spell),
          onLongPress: () => _showSpellInfo(spell),
          child: Text(
            spell.level == 0 ? "${spell.name} (∞)" : spell.name,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _conjureHelpers(
    String title,
    TextEditingController controller, {
    required bool isNumber,
    required void Function(String) onChanged,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 40,
          child: TextField(
            controller: controller,
            maxLength: isNumber ? 3 : 10,
            textAlign: TextAlign.center,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              counterText: "",
              hintText: "-",
              filled: true,
              fillColor: AppColors.textFieldBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  width: 1,
                  color: AppColors.secondary,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

// ===== MODELITOS LOCALES =====

class SpellSlot {
  final int level;
  final int maxSlots;
  final int usedSlots;

  SpellSlot({
    required this.level,
    required this.maxSlots,
    required this.usedSlots,
  });

  SpellSlot copyWith({int? level, int? maxSlots, int? usedSlots}) {
    return SpellSlot(
      level: level ?? this.level,
      maxSlots: maxSlots ?? this.maxSlots,
      usedSlots: usedSlots ?? this.usedSlots,
    );
  }
}

class CharacterSpell {
  final int id;
  final int level;
  final String name;
  final String description;
  final bool known;

  CharacterSpell({
    required this.id,
    required this.level,
    required this.name,
    required this.description,
    required this.known,
  });

  CharacterSpell copyWith({
    int? id,
    int? level,
    String? name,
    String? description,
    bool? known,
  }) {
    return CharacterSpell(
      id: id ?? this.id,
      level: level ?? this.level,
      name: name ?? this.name,
      description: description ?? this.description,
      known: known ?? this.known,
    );
  }
}
