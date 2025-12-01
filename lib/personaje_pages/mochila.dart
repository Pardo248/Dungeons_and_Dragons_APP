import 'package:flutter/material.dart';
import 'package:proyecto_diego_castillo/database_hepler.dart';
import 'package:proyecto_diego_castillo/widgets/app_ui.dart';

class MochilaPage extends StatefulWidget {
  final String? personName;
  final int? personId;

  const MochilaPage({super.key, this.personName, this.personId});

  @override
  State<MochilaPage> createState() => _MochilaPageState();
}

class _MochilaPageState extends State<MochilaPage> {
  final _pcCtrl = TextEditingController();
  final _ppCtrl = TextEditingController();
  final _peCtrl = TextEditingController();
  final _poCtrl = TextEditingController();
  final _pptCtrl = TextEditingController();

  bool _loading = true;

  // Lista de ítems de mochila
  List<MochilaItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pcCtrl.dispose();
    _ppCtrl.dispose();
    _peCtrl.dispose();
    _poCtrl.dispose();
    _pptCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.personId == null) {
      setState(() => _loading = false);
      return;
    }

    await DatabaseHelper.instance.initDB();

    // === Cargar monedas (mochila) ===
    final mochila =
        await DatabaseHelper.instance.getMochilaByPersonId(widget.personId!);

    _pcCtrl.text = (mochila?['pc'] ?? 0).toString();
    _ppCtrl.text = (mochila?['pp'] ?? 0).toString();
    _peCtrl.text = (mochila?['pe'] ?? 0).toString();
    _poCtrl.text = (mochila?['po'] ?? 0).toString();
    _pptCtrl.text = (mochila?['ppt'] ?? 0).toString();

    // === Cargar ítems de mochila ===
    final itemsRes =
        await DatabaseHelper.instance.getMochilaItemsByPersonId(widget.personId!);

    _items = itemsRes
        .map((row) => MochilaItem(
              id: row['id'] as int,
              name: row['name'] as String,
              description: (row['description'] ?? '') as String,
              quantity: (row['quantity'] ?? 0) as int,
            ))
        .toList();

    setState(() => _loading = false);
  }

  int _parseOrZero(String text) =>
      int.tryParse(text.trim().isEmpty ? '0' : text.trim()) ?? 0;

  Future<void> _saveMochila() async {
    if (widget.personId == null) return;

    final data = {
      'pc': _parseOrZero(_pcCtrl.text),
      'pp': _parseOrZero(_ppCtrl.text),
      'pe': _parseOrZero(_peCtrl.text),
      'po': _parseOrZero(_poCtrl.text),
      'ppt': _parseOrZero(_pptCtrl.text),
    };

    await DatabaseHelper.instance.upsertMochila(widget.personId!, data);
  }

  void _onFieldChanged() {
    _saveMochila();
  }

  Future<void> _showAddItemDialog() async {
    if (widget.personId == null) return;

    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar ítem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del ítem',
                ),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                ),
              ),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                ),
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
        );
      },
    );

    if (result != true) return;

    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;

    // Guardar en BD
    final id = await DatabaseHelper.instance.insertMochilaItem(
      widget.personId!,
      nameCtrl.text.trim(),
      descCtrl.text.trim(),
      qty,
    );

    // Actualizar estado
    setState(() {
      _items.add(MochilaItem(
        id: id,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        quantity: qty,
      ));
    });
  }

  Future<void> _updateItemQuantity(MochilaItem item, int newQty) async {
    if (newQty < 0) newQty = 0;
    await DatabaseHelper.instance.updateMochilaItemQuantity(item.id!, newQty);

    setState(() {
      final index = _items.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: newQty);
      }
    });
  }

  Future<void> _deleteItem(MochilaItem item) async {
    await DatabaseHelper.instance.deleteMochilaItem(item.id!);
    setState(() {
      _items.removeWhere((e) => e.id == item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Vive dentro de PersonajePager → ahí ya está el fondo, aquí solo layout/colores
    return DefaultTextStyle(
      style: const TextStyle(color: AppColors.textPrimary),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ===== MONEDAS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _miniInput("PC", _pcCtrl),
              const Spacer(),
              _miniInput("PP", _ppCtrl),
              const Spacer(),
              _miniInput("PE", _peCtrl),
              const Spacer(),
              _miniInput("PO", _poCtrl),
              const Spacer(),
              _miniInput("PPT", _pptCtrl),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),

          // ===== BOTÓN AGREGAR ITEM =====
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                foregroundColor: Colors.white,
              ),
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text('Agregar ítem'),
            ),
          ),
          const SizedBox(height: 8),

          // ===== LISTA DE ITEMS =====
          if (_items.isEmpty)
            const Text(
              'No hay ítems en la mochila.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            )
          else
            ..._items.map((item) => _itemTile(item)).toList(),
        ],
      ),
    );
  }

  Widget _itemTile(MochilaItem item) {
    return Card(
      color: AppColors.textFieldBackground.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.secondary, width: 1.2),
      ),
      child: ListTile(
        title: Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          item.description.isNotEmpty ? item.description : 'Sin descripción',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _updateItemQuantity(item, item.quantity - 1),
              icon: const Icon(Icons.remove),
              color: AppColors.secondary,
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            IconButton(
              onPressed: () => _updateItemQuantity(item, item.quantity + 1),
              icon: const Icon(Icons.add),
              color: AppColors.secondary,
            ),
            IconButton(
              onPressed: () => _deleteItem(item),
              icon: const Icon(Icons.delete),
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniInput(String title, TextEditingController controller) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: TextField(
            controller: controller,
            maxLength: 3,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (_) => _onFieldChanged(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              counterText: "",
              hintText: "0",
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

// Modelo simple para manejar ítems en memoria
class MochilaItem {
  final int? id;
  final String name;
  final String description;
  final int quantity;

  MochilaItem({
    this.id,
    required this.name,
    required this.description,
    required this.quantity,
  });

  MochilaItem copyWith({
    int? id,
    String? name,
    String? description,
    int? quantity,
  }) {
    return MochilaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
    );
  }
}
