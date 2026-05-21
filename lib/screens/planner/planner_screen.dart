import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/api_models.dart';
import '../../providers/providers.dart';

const _dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  MealPlan? _plan;
  bool _loading = false;
  bool _importing = false;
  String? _error;

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try {
      _plan = await ref.read(plannerServiceProvider).generate();
    } on ApiError catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _importGaps() async {
    final plan = _plan;
    if (plan == null || plan.gapItems.isEmpty) return;
    setState(() => _importing = true);
    try {
      final r = await ref.read(plannerServiceProvider).importGaps(plan.gapItems);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${r.created} added to shopping list${r.skipped > 0 ? ' (${r.skipped} already there)' : ''}'),
        ));
      }
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final meals = plan == null ? <Meal>[] : ([...plan.meals]..sort((a, b) => _dayOrder.indexOf(a.day).compareTo(_dayOrder.indexOf(b.day))));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal planner'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _generate,
            icon: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
            tooltip: 'Generate plan',
          ),
        ],
      ),
      body: plan == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant_menu, size: 64),
                    const SizedBox(height: 12),
                    Text('No plan yet', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('Tap the wand to ask the AI chef for five weekday meals from your inventory.', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                    FilledButton.icon(onPressed: _loading ? null : _generate, icon: const Icon(Icons.auto_awesome), label: const Text('Generate plan')),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...meals.map((m) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.day.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: Theme.of(context).colorScheme.outline)),
                            const SizedBox(height: 4),
                            Text(m.name, style: Theme.of(context).textTheme.titleMedium),
                            if (m.note != null && m.note!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(m.note!, style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.outline)),
                            ],
                            const Divider(height: 24),
                            ...m.ingredients.map((i) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('• $i'))),
                          ],
                        ),
                      ),
                    )),
                if (plan.gapItems.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Missing ingredients', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...plan.gapItems.map((g) => ListTile(
                                dense: true,
                                title: Text(g.name),
                                subtitle: Text(((g.quantity != null ? '${g.quantity} ${g.unit ?? ''} · ' : ''))
                                    + Categories.label(g.category)),
                              )),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: _importing ? null : _importGaps,
                            icon: _importing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.shopping_basket_outlined),
                            label: const Text('Add to shopping list'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
