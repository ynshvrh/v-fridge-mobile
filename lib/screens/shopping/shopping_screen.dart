import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/fridge_provider.dart';
import '../../providers/providers.dart';
import '../../theme/category_visuals.dart';
import '../../theme/vf_colors.dart';
import '../../theme/vf_radius.dart';
import '../../widgets/animated_press.dart';
import '../../widgets/fridge_switcher.dart';
import '../../widgets/staggered_entry.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.shoppingAddedToFridge(product.name))));
      }
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen<int?>(activeFridgeIdProvider, (prev, next) {
      if (prev != next) _load();
    });
    final unchecked = _items.where((i) => !i.checked).toList();
    final checked = _items.where((i) => i.checked).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.shoppingTitle),
        actions: const [FridgeSwitcher()],
      ),
      body: Column(
        children: [
          ActiveFridgeBanner(icon: Icons.shopping_basket_outlined, label: l10n.shoppingActiveFor),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? _ShoppingEmptyState(message: l10n.shoppingEmpty)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: Builder(builder: (_) {
                          // Flatten the two sections into a single list of
                          // (index, widget) entries so the stagger cascade
                          // crosses the header → unchecked → header → checked
                          // boundary instead of resetting at each section.
                          final entries = <Widget>[];
                          var idx = 0;
                          Widget wrap(Widget w) =>
                              StaggeredEntry(index: idx++, child: w);
                          if (unchecked.isNotEmpty) {
                            entries.add(wrap(_SectionHeader(label: l10n.shoppingToBuy, count: unchecked.length, accent: true)));
                            for (final i in unchecked) {
                              entries.add(wrap(AnimatedPress(
                                onTap: () => _toggle(i),
                                child: _Tile(
                                  item: i,
                                  onToggle: () => _toggle(i),
                                  onDelete: () => _delete(i),
                                  onPurchase: () => _purchase(i),
                                ),
                              )));
                            }
                          }
                          if (checked.isNotEmpty) {
                            entries.add(wrap(_SectionHeader(label: l10n.shoppingGotThem, count: checked.length, accent: false)));
                            for (final i in checked) {
                              entries.add(wrap(AnimatedPress(
                                onTap: () => _toggle(i),
                                child: _Tile(
                                  item: i,
                                  onToggle: () => _toggle(i),
                                  onDelete: () => _delete(i),
                                  onPurchase: () => _purchase(i),
                                ),
                              )));
                            }
                          }
                          return ListView(
                            padding: const EdgeInsets.all(8),
                            children: entries,
                          );
                        }),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
    );
  }
}

class _ShoppingEmptyState extends StatelessWidget {
  const _ShoppingEmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: VfRadius.brXxxl,
            border: Border.all(color: scheme.outline),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: vf.mistral.withValues(alpha: 0.22),
                  borderRadius: VfRadius.brXl,
                ),
                child: Icon(Icons.shopping_basket_outlined, size: 36, color: vf.accentForeground),
              ),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: vf.mutedForeground)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pill-style section header. The active section ("To buy") gets a soft
/// Mistral wash; "Got them" stays muted so the eye lands on what's left.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count, required this.accent});
  final String label;
  final int count;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    final bg = accent ? vf.mistral.withValues(alpha: 0.22) : scheme.surface;
    final fg = accent ? vf.accentForeground : vf.mutedForeground;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: VfRadius.brXl,
              border: Border.all(color: accent ? Colors.transparent : scheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.4),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent ? scheme.surface : Colors.transparent,
                    borderRadius: VfRadius.brXl,
                    border: accent ? null : Border.all(color: scheme.outline),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shopping row tile. Visual hierarchy:
///   leading category-tinted circle with icon  →  name (bold)  →  qty pill
///                                              ↓ subtitle (muted, category)
/// Trailing keeps quick-action icons (purchase + delete) but at low visual
/// weight so the focus stays on the item itself. When checked, the whole row
/// fades and the name gets a strike — the surface tone stays the same so the
/// list rhythm doesn't break.
class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.onToggle, required this.onDelete, required this.onPurchase});
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    final visual = categoryVisual(context, item.category);

    final qtyText = item.quantity != null
        ? '${item.quantity!.toStringAsFixed(item.quantity! % 1 == 0 ? 0 : 1)}${(item.unit ?? '').isNotEmpty ? ' ${item.unit}' : ''}'
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: item.checked ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: VfRadius.brXl,
            border: Border.all(color: scheme.outline),
          ),
          child: Row(
            children: [
              _CategoryAvatar(visual: visual, checked: item.checked, onTap: onToggle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: scheme.onSurface,
                              decoration: item.checked ? TextDecoration.lineThrough : null,
                              decorationColor: vf.mutedForeground,
                              decorationThickness: 1.6,
                            ),
                          ),
                        ),
                        if (qtyText != null) ...[
                          const SizedBox(width: 8),
                          _QtyPill(text: qtyText),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      categoryLabel(l10n, item.category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: vf.mutedForeground, fontSize: 12),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: item.checked
                    ? IconButton(
                        key: const ValueKey('del'),
                        onPressed: onDelete,
                        icon: Icon(Icons.delete_outline, size: 20, color: vf.mutedForeground),
                        tooltip: l10n.actionDelete,
                        visualDensity: VisualDensity.compact,
                      )
                    : Row(
                        key: const ValueKey('actions'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: onPurchase,
                            icon: Icon(Icons.check_circle_outline, size: 22, color: vf.success),
                            tooltip: l10n.shoppingMoveToFridge,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: Icon(Icons.delete_outline, size: 20, color: vf.mutedForeground),
                            tooltip: l10n.actionDelete,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 44px circle with category icon; doubles as the checkbox — tapping it
/// toggles the item. When checked, swaps to a filled check on the brand
/// success colour so the state is unambiguous without a separate Checkbox.
class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.visual, required this.checked, required this.onTap});
  final CategoryVisual visual;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vf = context.vfColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: checked
              ? vf.success.withValues(alpha: 0.18)
              : visual.color.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(
            color: checked
                ? vf.success.withValues(alpha: 0.55)
                : visual.color.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: checked
              ? Icon(Icons.check_rounded, key: const ValueKey('on'), size: 22, color: vf.success)
              : Icon(visual.icon, key: ValueKey(visual.icon.codePoint), size: 20, color: visual.color),
        ),
      ),
    );
  }
}

/// Small rounded pill that holds the quantity + unit. Sits to the right of
/// the item name so qty stays glanceable even on narrow rows.
class _QtyPill extends StatelessWidget {
  const _QtyPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final vf = context.vfColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: vf.zephir,
        borderRadius: VfRadius.brXl,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: vf.accentForeground,
          fontWeight: FontWeight.w700,
          fontSize: 11,
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
    if (_name.text.trim().isEmpty) { setState(() => _error = context.l10n.shoppingNameRequired); return; }
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
    final l10n = context.l10n;
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
              Text(l10n.shoppingAddSheetTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
              TextField(controller: _name, decoration: InputDecoration(labelText: l10n.shoppingFieldItem)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 2, child: TextField(controller: _quantity, decoration: InputDecoration(labelText: l10n.shoppingFieldQty), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: InputDecoration(labelText: l10n.addProductUnit),
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _unit = v ?? 'pcs'),
                  )),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(labelText: l10n.addProductCategory),
                items: Categories.slugs.map((s) => DropdownMenuItem(value: s, child: Text(categoryLabel(l10n, s)))).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'other'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.actionAdd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
