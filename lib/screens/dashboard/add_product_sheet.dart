import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/api_models.dart';
import '../../providers/providers.dart';
import 'barcode_scanner.dart';

class AddProductSheet extends ConsumerStatefulWidget {
  const AddProductSheet({super.key});

  @override
  ConsumerState<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<AddProductSheet> {
  final _name = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  String _unit = 'pcs';
  String _category = 'other';
  DateTime? _expiry;
  bool _saving = false;
  String? _error;

  static const _units = ['pcs', 'kg', 'g', 'l', 'ml'];

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final scanned = await Navigator.of(context).push<ScannedProduct>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (scanned == null) return;
    setState(() {
      _name.text = scanned.name;
      _quantity.text = scanned.quantity;
      _unit = ['pcs', 'kg', 'g', 'l', 'ml'].contains(scanned.unit) ? scanned.unit : 'pcs';
      _category = Categories.slugs.contains(scanned.category) ? scanned.category : 'other';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Filled from barcode ${scanned.barcode}')));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: _expiry ?? DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _save() async {
    final qty = double.tryParse(_quantity.text.replaceAll(',', '.')) ?? 0;
    if (_name.text.trim().length < 2) {
      setState(() => _error = 'Name is too short');
      return;
    }
    if (qty <= 0) {
      setState(() => _error = 'Quantity must be greater than 0');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final created = await ref.read(productsServiceProvider).create(
            name: _name.text.trim(),
            quantity: qty,
            unit: _unit,
            expiryDate: _expiry,
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
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Add product', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              OutlinedButton.icon(
                onPressed: _saving ? null : _scanBarcode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan barcode'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _quantity,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setState(() => _unit = v ?? 'pcs'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: Categories.slugs
                    .map((s) => DropdownMenuItem(value: s, child: Text(Categories.label(s))))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'other'),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Expiry date'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_expiry == null ? 'No date' : DateFormat('MMMM d, yyyy').format(_expiry!)),
                    Row(children: [
                      if (_expiry != null)
                        IconButton(onPressed: () => setState(() => _expiry = null), icon: const Icon(Icons.close)),
                      IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_today_outlined)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add to fridge'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
