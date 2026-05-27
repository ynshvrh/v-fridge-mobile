import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/providers.dart';
import '../../theme/vf_colors.dart';
import '../../theme/vf_radius.dart';
import 'add_product_sheet.dart';
import 'analytics_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<List<Product>>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _future = ref.read(productsServiceProvider).list());
  }

  Future<void> _add() async {
    final created = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddProductSheet(),
    );
    if (created != null) _reload();
  }

  Future<void> _edit(Product p) async {
    final updated = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddProductSheet(existing: p),
    );
    if (updated != null) _reload();
  }

  Future<void> _delete(Product p) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dashboardConfirmDeleteTitle(p.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.actionDelete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(productsServiceProvider).delete(p.id);
      _reload();
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _consume(Product p) async {
    final l10n = context.l10n;
    try {
      await ref.read(productsServiceProvider).patch(p.id, quantity: 0);
      if (mounted) _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.dashboardConsumeLogged(p.name))));
      }
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _ErrorView(message: snap.error.toString(), onRetry: _reload);
            }
            final products = snap.data ?? [];
            if (products.isEmpty) return _EmptyView(onAdd: _add);

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: products.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return const AnalyticsTile();
                final p = products[i - 1];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: _ProductTile(
                    product: p,
                    onTap: () => _edit(p),
                    onEdit: () => _edit(p),
                    onDelete: () => _delete(p),
                    onConsume: () => _consume(p),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.dashboardAddProduct),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onConsume,
  });
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onConsume;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final freshness = _freshness(l10n, product.expiryDate);
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.quantity.toStringAsFixed(product.quantity % 1 == 0 ? 0 : 1)} ${product.unit} · ${categoryLabel(l10n, product.category)}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 14, color: freshness.color),
                const SizedBox(width: 4),
                Text(freshness.label, style: TextStyle(color: freshness.color, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
            if (v == 'consume') onConsume();
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(l10n.actionEdit))),
            PopupMenuItem(value: 'consume', child: ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(l10n.productActionMarkFinished))),
            PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(l10n.actionDelete))),
          ],
        ),
      ),
    );
  }

  ({String label, Color color}) _freshness(AppLocalizations l10n, DateTime? d) {
    if (d == null) return (label: l10n.productNoDate, color: Colors.grey);
    final diff = d.difference(DateTime.now()).inDays;
    final dateStr = DateFormat('MMM d').format(d);
    if (diff < 0) return (label: l10n.productExpired(dateStr), color: Colors.red);
    if (diff <= 3) return (label: l10n.productDaysLeft(diff), color: Colors.orange);
    return (label: l10n.productFreshUntil(dateStr), color: Colors.green);
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                decoration: BoxDecoration(color: vf.celadon, borderRadius: VfRadius.brXl),
                child: Icon(Icons.kitchen_outlined, size: 36, color: scheme.onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.dashboardEmptyTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.dashboardEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(color: vf.mutedForeground),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(l10n.dashboardAddProduct)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.actionRetry)),
          ],
        ),
      ),
    );
  }
}
