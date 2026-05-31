import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/providers.dart';
import 'barcode_scanner.dart';

/// Reused for both 'Add new product' and 'Edit product X' — pass `existing` to enter edit mode.
class AddProductSheet extends ConsumerStatefulWidget {
  const AddProductSheet({super.key, this.existing});

  final Product? existing;

  bool get isEdit => existing != null;

  @override
  ConsumerState<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<AddProductSheet> {
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late String _unit;
  late String _category;
  DateTime? _expiry;
  bool _expiryChanged = false;
  bool _saving = false;
  // Brief celebratory check on the submit button before the sheet closes.
  bool _saved = false;
  String? _error;

  static const _units = ['pcs', 'kg', 'g', 'l', 'ml'];

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    final initialQty = p == null
        ? '1'
        : p.quantity % 1 == 0
            ? p.quantity.toStringAsFixed(0)
            : p.quantity.toString();
    _quantity = TextEditingController(text: initialQty);
    // Rebuild so the incomplete-data warning reflects the live quantity value.
    _quantity.addListener(_onFormChanged);
    _unit = _units.contains(p?.unit) ? p!.unit : 'pcs';
    _category = Categories.slugs.contains(p?.category) ? p!.category : 'other';
    _expiry = p?.expiryDate;
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _quantity.removeListener(_onFormChanged);
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
      _unit = _units.contains(scanned.unit) ? scanned.unit : 'pcs';
      _category = Categories.slugs.contains(scanned.category) ? scanned.category : 'other';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.addProductFilledFromBarcode(scanned.barcode))));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: _expiry ?? DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) setState(() { _expiry = picked; _expiryChanged = true; });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final qty = double.tryParse(_quantity.text.replaceAll(',', '.')) ?? 0;
    if (_name.text.trim().length < 2) {
      setState(() => _error = l10n.addProductNameTooShort);
      return;
    }
    if (qty <= 0) {
      setState(() => _error = l10n.addProductQuantityTooLow);
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final svc = ref.read(productsServiceProvider);
      final Product saved;
      if (widget.isEdit) {
        // Only send fields that actually changed compared to the loaded product.
        final old = widget.existing!;
        saved = await svc.patch(
          old.id,
          name: _name.text.trim() != old.name ? _name.text.trim() : null,
          quantity: qty != old.quantity ? qty : null,
          unit: _unit != old.unit ? _unit : null,
          category: _category != old.category ? _category : null,
          expiryDate: _expiryChanged ? _expiry : null,
          clearExpiry: _expiryChanged && _expiry == null,
        );
      } else {
        saved = await svc.create(
          name: _name.text.trim(),
          quantity: qty,
          unit: _unit,
          expiryDate: _expiry,
          category: _category,
        );
      }
      if (!mounted) return;
      // Celebrate the save: medium haptic + a brief check on the button, then close.
      HapticFeedback.mediumImpact();
      setState(() { _saving = false; _saved = true; });
      await Future.delayed(const Duration(milliseconds: 450));
      if (mounted) Navigator.pop(context, saved);
    } on ApiError catch (e) {
      setState(() { _error = e.message; _saving = false; });
    }
  }

  /// Lists the localized names of fields that are blank/defaulted, so we can
  /// warn that incomplete data degrades the AI chef's suggestions. Advisory
  /// only — it never blocks submission.
  List<String> _incompleteFields(AppLocalizations l10n) {
    final fields = <String>[];
    if (_category == 'other') fields.add(l10n.addProductIncompleteCategory);
    final qty = double.tryParse(_quantity.text.replaceAll(',', '.')) ?? 0;
    if (qty <= 0) fields.add(l10n.addProductIncompleteQuantity);
    if (_expiry == null) fields.add(l10n.addProductIncompleteExpiry);
    return fields;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final title = widget.isEdit ? l10n.addProductEditTitle : l10n.addProductTitle;
    final actionLabel = widget.isEdit ? l10n.actionSave : l10n.addProductActionAdd;
    final incomplete = _incompleteFields(l10n);
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
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              if (!widget.isEdit) ...[
                OutlinedButton.icon(
                  onPressed: _saving ? null : _scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.addProductScanBarcode),
                ),
                const SizedBox(height: 12),
              ],
              TextField(controller: _name, decoration: InputDecoration(labelText: l10n.addProductName)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _quantity,
                      decoration: InputDecoration(labelText: l10n.addProductQuantity),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: InputDecoration(labelText: l10n.addProductUnit),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setState(() => _unit = v ?? 'pcs'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(labelText: l10n.addProductCategory),
                items: Categories.slugs
                    .map((s) => DropdownMenuItem(value: s, child: Text(categoryLabel(l10n, s))))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'other'),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(labelText: l10n.addProductExpiry),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_expiry == null ? l10n.productNoDate : DateFormat('MMMM d, yyyy').format(_expiry!)),
                    Row(children: [
                      if (_expiry != null)
                        IconButton(onPressed: () => setState(() { _expiry = null; _expiryChanged = true; }), icon: const Icon(Icons.close)),
                      IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_today_outlined)),
                    ]),
                  ],
                ),
              ),
              if (incomplete.isNotEmpty) ...[
                const SizedBox(height: 16),
                _IncompleteDataWarning(message: l10n.addProductIncompleteWarning(incomplete.join(', '))),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: (_saving || _saved) ? null : _save,
                child: _saved
                    ? const Icon(Icons.check_rounded, size: 24)
                        .animate()
                        .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1), duration: 280.ms, curve: Curves.easeOutBack)
                    : _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Non-blocking advisory panel shown above the submit button when the product
/// is missing fields that the AI chef relies on (category, quantity, expiry).
/// Styled as a soft warning, not an error — submission is still allowed.
class _IncompleteDataWarning extends StatelessWidget {
  const _IncompleteDataWarning({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tone = scheme.tertiary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
