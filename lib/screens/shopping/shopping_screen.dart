import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/api_models.dart';
import '../../providers/providers.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  List<ShoppingItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await ref.read(shoppingServiceProvider).list();
      if (mounted) setState(() { _items = items; _loading = false; });
    } on ApiError catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _add() async {
    final created = await showModalBottomSheet<ShoppingItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddShoppingItemSheet(),
    );
    if (created != null) setState(() => _items = [..._items, created]);
  }

  Future<void> _toggle(ShoppingItem item) async {
    setState(() => _items = _items.map((i) => i.id == item.id
        ? ShoppingItem(id: i.id, name: i.name, quantity: i.quantity, unit: i.unit, category: i.category, checked: !i.checked, createdAt: i.createdAt)
        : i).toList());
    try {
      await ref.read(shoppingServiceProvider).patch(item.id, checked: !item.checked);
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        _load();
      }
    }
  }

  Future<void> _delete(ShoppingItem item) async {
    final prev = _items;
    setState(() => _items = _items.where((i) => i.id != item.id).toList());
    try {
      await ref.read(shoppingServiceProvider).delete(item.id);
    } on ApiError catch (e) {
      setState(() => _items = prev);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _purchase(ShoppingItem item) async {
    try {
      final product = await ref.read(shoppingServiceProvider).purchase(item.id);
      setState(() => _items = _items.where((i) => i.id != item.id).toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${product.name}" added to the fridge')));
      }
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final unchecked = _items.where((i) => !i.checked).toList();
    final checked = _items.where((i) => i.checked).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping list')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Your list is empty.', textAlign: TextAlign.center)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      if (unchecked.isNotEmpty) ...[
                        const _SectionHeader(label: 'To buy'),
                        ...unchecked.map((i) => _Tile(item: i, onToggle: () => _toggle(i), onDelete: () => _delete(i), onPurchase: () => _purchase(i))),
                      ],
                      if (checked.isNotEmpty) ...[
                        const _SectionHeader(label: 'Got them'),
                        ...checked.map((i) => _Tile(item: i, onToggle: () => _toggle(i), onDelete: () => _delete(i), onPurchase: () => _purchase(i))),
                      ],
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: Theme.of(context).colorScheme.outline)),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.onToggle, required this.onDelete, required this.onPurchase});
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Checkbox(value: item.checked, onChanged: (_) => onToggle()),
        title: Text(
          item.name,
          style: TextStyle(decoration: item.checked ? TextDecoration.lineThrough : null),
        ),
        subtitle: Text(
          (item.quantity != null ? '${item.quantity!.toStringAsFixed(item.quantity! % 1 == 0 ? 0 : 1)} ${item.unit ?? ''} · ' : '')
              + Categories.label(item.category),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!item.checked)
              IconButton(onPressed: onPurchase, icon: const Icon(Icons.check_circle_outline), tooltip: 'Move to fridge'),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}

class _AddShoppingItemSheet extends ConsumerStatefulWidget {
  const _AddShoppingItemSheet();

  @override
  ConsumerState<_AddShoppingItemSheet> createState() => _AddShoppingItemSheetState();
}

class _AddShoppingItemSheetState extends ConsumerState<_AddShoppingItemSheet> {
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  String _unit = 'pcs';
  String _category = 'other';
  bool _saving = false;
  String? _error;

  static const _units = ['pcs', 'kg', 'g', 'l', 'ml'];

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) { setState(() => _error = 'Name is required'); return; }
    setState(() { _saving = true; _error = null; });
    try {
      final qty = double.tryParse(_quantity.text.replaceAll(',', '.'));
      final created = await ref.read(shoppingServiceProvider).create(
            name: _name.text.trim(),
            quantity: qty,
            unit: _unit,
            category: _category,
          );
      if (mounted) Navigator.pop(context, created);
    } on ApiError catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add to shopping list', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Item')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 2, child: TextField(controller: _quantity, decoration: const InputDecoration(labelText: 'Qty'), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _unit = v ?? 'pcs'),
                  )),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: Categories.slugs.map((s) => DropdownMenuItem(value: s, child: Text(Categories.label(s)))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'other'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
