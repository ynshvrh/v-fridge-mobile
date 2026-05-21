import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/api_models.dart';
import '../../providers/providers.dart';

class AnalyticsTile extends ConsumerStatefulWidget {
  const AnalyticsTile({super.key});

  @override
  ConsumerState<AnalyticsTile> createState() => _AnalyticsTileState();
}

class _AnalyticsTileState extends ConsumerState<AnalyticsTile> {
  AnalyticsSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _summary = await ref.read(analyticsServiceProvider).summary();
    } catch (_) {/* best-effort */}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    final s = _summary;
    if (s == null || s.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s.mostWasted.isNotEmpty)
          _Section(
            title: 'Most wasted',
            subtitle: 'Last 30 days',
            icon: Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
            children: s.mostWasted.take(3).map((row) => _Row(
                  primary: row.productName,
                  secondary: '${row.totalQuantity.toStringAsFixed(row.totalQuantity % 1 == 0 ? 0 : 1)} · ${row.occurrences}×',
                )),
          ),
        if (s.fastestConsumed.isNotEmpty)
          _Section(
            title: 'Fastest consumed',
            subtitle: 'Days from add to finished',
            icon: Icons.bolt_outlined,
            color: Theme.of(context).colorScheme.primary,
            children: s.fastestConsumed.take(3).map((row) => _Row(
                  primary: row.productName,
                  secondary: '${row.ageDays}d · ${Categories.label(row.category)}',
                )),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.subtitle, required this.icon, required this.color, required this.children});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Iterable<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.primary, required this.secondary});
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(primary, overflow: TextOverflow.ellipsis)),
          Text(secondary, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }
}
