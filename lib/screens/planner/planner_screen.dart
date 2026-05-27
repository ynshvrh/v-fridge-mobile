import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/fridge_provider.dart';
import '../../providers/providers.dart';
import '../../theme/vf_colors.dart';
import '../../theme/vf_radius.dart';
import '../../widgets/fridge_switcher.dart';

const _dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

class _PlannerEmptyState extends StatelessWidget {
  const _PlannerEmptyState({required this.loading, required this.error, required this.onGenerate});
  final bool loading;
  final String? error;
  final VoidCallback onGenerate;

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
                child: Icon(Icons.auto_awesome, size: 36, color: scheme.onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.plannerEmptyTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.plannerEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(color: vf.mutedForeground),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: loading ? null : onGenerate,
                icon: const Icon(Icons.auto_awesome),
                label: Text(l10n.plannerGenerate),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
    final l10n = context.l10n;
    setState(() => _importing = true);
    try {
      final r = await ref.read(plannerServiceProvider).importGaps(plan.gapItems);
      if (mounted) {
        final base = l10n.plannerImportResult(r.created);
        final suffix = r.skipped > 0 ? l10n.plannerImportSkipped(r.skipped) : '';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$base$suffix')));
      }
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Clear the current plan when the user switches fridges — the meals only make
    // sense for the inventory that produced them.
    ref.listen<int?>(activeFridgeIdProvider, (prev, next) {
      if (prev != next && mounted) setState(() => _plan = null);
    });
    final plan = _plan;
    final meals = plan == null ? <Meal>[] : ([...plan.meals]..sort((a, b) => _dayOrder.indexOf(a.day).compareTo(_dayOrder.indexOf(b.day))));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.plannerTitle),
        actions: [
          IconButton(
            onPressed: _loading ? null : _generate,
            icon: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
            tooltip: l10n.plannerGenerate,
          ),
          const FridgeSwitcher(),
        ],
      ),
      body: Column(
        children: [
          ActiveFridgeBanner(icon: Icons.calendar_today_outlined, label: l10n.plannerActiveFor),
          Expanded(
            child: plan == null
                ? _PlannerEmptyState(
              loading: _loading,
              error: _error,
              onGenerate: _generate,
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
                            Text(plannerDayLabel(l10n, m.day).toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: Theme.of(context).colorScheme.outline)),
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
                  Text(l10n.plannerMissingIngredients, style: Theme.of(context).textTheme.titleMedium),
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
                                    + categoryLabel(l10n, g.category)),
                              )),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: _importing ? null : _importGaps,
                            icon: _importing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.shopping_basket_outlined),
                            label: Text(l10n.plannerAddToShopping),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
