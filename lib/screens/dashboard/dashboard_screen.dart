import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/api_models.dart';
import '../../providers/providers.dart';
import 'add_product_sheet.dart';

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

  Future<void> _delete(Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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
    try {
      await ref.read(productsServiceProvider).patch(p.id, quantity: 0);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${p.name}" finished — logged')));
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

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ProductTile(
                product: products[i],
                onDelete: () => _delete(products[i]),
                onConsume: () => _consume(products[i]),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onDelete, required this.onConsume});
  final Product product;
  final VoidCallback onDelete;
  final VoidCallback onConsume;

  @override
  Widget build(BuildContext context) {
    final freshness = _freshness(product.expiryDate);
    return Card(
      child: ListTile(
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.quantity.toStringAsFixed(product.quantity % 1 == 0 ? 0 : 1)} ${product.unit} · ${Categories.label(product.category)}'),
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
            if (v == 'delete') onDelete();
            if (v == 'consume') onConsume();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'consume', child: ListTile(leading: Icon(Icons.check_circle_outline), title: Text('Mark finished'))),
            PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
          ],
        ),
      ),
    );
  }

  ({String label, Color color}) _freshness(DateTime? d) {
    if (d == null) return (label: 'No date', color: Colors.grey);
    final diff = d.difference(DateTime.now()).inDays;
    if (diff < 0) return (label: 'Expired ${DateFormat('MMM d').format(d)}', color: Colors.red);
    if (diff <= 3) return (label: '$diff ${diff == 1 ? 'day' : 'days'} left', color: Colors.orange);
    return (label: 'Fresh until ${DateFormat('MMM d').format(d)}', color: Colors.green);
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 64),
        const Icon(Icons.kitchen_outlined, size: 72),
        const SizedBox(height: 12),
        Text('Your fridge is empty', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Add the first product to get started.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add product')),
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
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
