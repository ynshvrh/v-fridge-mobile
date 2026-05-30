import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/fridge_provider.dart';
import '../../providers/providers.dart';
import '../../theme/vf_colors.dart';
import '../../theme/vf_radius.dart';
import '../../widgets/fridge_switcher.dart';
import '../../widgets/staggered_entry.dart';

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
                decoration: BoxDecoration(color: vf.mistral, borderRadius: VfRadius.brXl),
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
  // Day currently being regenerated (canonical English name), or null when idle.
  String? _regeneratingDay;
  // Day whose recipe is currently being lazily fetched, or null when idle. Guards
  // against duplicate in-flight fetches for the same day.
  String? _loadingRecipeDay;

  @override
  void initState() {
    super.initState();
    // Pull the persisted plan for the active fridge so the screen restores
    // instantly on revisit — no LLM round-trip unless the user asks for it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCached());
  }

  Future<void> _loadCached() async {
    try {
      final cached = await ref.read(plannerServiceProvider).fetchCached();
      if (mounted) setState(() => _plan = cached);
    } on ApiError catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

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

  Future<void> _regenerateDay(String day) async {
    if (_regeneratingDay != null) return; // serialize: one day at a time
    setState(() => _regeneratingDay = day);
    try {
      final updated = await ref.read(plannerServiceProvider).regenerateDay(day);
      if (mounted) setState(() => _plan = updated);
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _regeneratingDay = null);
    }
  }

  /// Lazily pulls a single day's recipe (description + steps) the first time its
  /// card is expanded. Light plans ship meals with empty steps and a null
  /// description; this fills them in one meal at a time to stay within the token
  /// budget. The server caches the result, so a second expand never hits the
  /// network. No-ops when that day is already being fetched.
  Future<void> _fetchRecipe(String day) async {
    if (_loadingRecipeDay == day) return; // de-dupe concurrent expands
    final l10n = context.l10n;
    setState(() => _loadingRecipeDay = day);
    try {
      final updated = await ref.read(plannerServiceProvider).fetchRecipe(day);
      if (mounted) setState(() => _plan = updated);
    } on ApiError catch (e) {
      if (mounted) {
        final message = e.status == 429 ? l10n.chatRateLimit : l10n.plannerRecipeError;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _loadingRecipeDay = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Each fridge has its own cached plan; reload when the active one flips so
    // the user lands on the right meals (or the empty state if nothing was
    // generated for the new fridge yet).
    ref.listen<int?>(activeFridgeIdProvider, (prev, next) {
      if (prev != next && mounted) {
        setState(() { _plan = null; _error = null; });
        _loadCached();
      }
    });
    final plan = _plan;
    final meals = plan == null ? <Meal>[] : ([...plan.meals]..sort((a, b) => _dayOrder.indexOf(a.day).compareTo(_dayOrder.indexOf(b.day))));
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                for (var idx = 0; idx < meals.length; idx++)
                  StaggeredEntry(
                    index: idx,
                    child: _MealCard(
                      meal: meals[idx],
                      regenerating: _regeneratingDay == meals[idx].day,
                      loadingRecipe: _loadingRecipeDay == meals[idx].day,
                      onRegenerate: () => _regenerateDay(meals[idx].day),
                      onNeedRecipe: () => _fetchRecipe(meals[idx].day),
                    ),
                  ),
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

/// Expandable meal card. Collapsed it shows just the day label + meal name;
/// expanded it reveals the description, the cooking steps as a numbered recipe,
/// and the ingredient list. A per-card action lets the user regenerate just
/// this day's meal without touching the rest of the plan.
class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.meal,
    required this.regenerating,
    required this.loadingRecipe,
    required this.onRegenerate,
    required this.onNeedRecipe,
  });

  final Meal meal;
  final bool regenerating;
  // True while this day's recipe is being lazily fetched.
  final bool loadingRecipe;
  final VoidCallback onRegenerate;
  // Invoked on first expand when the meal has no recipe yet (light plan).
  final VoidCallback onNeedRecipe;

  // A light meal carries only a name + ingredients; its recipe (description +
  // steps) is fetched lazily on first expand. Regenerated or already-fetched
  // meals already have a recipe and skip the network call.
  bool get _hasRecipe =>
      meal.steps.isNotEmpty ||
      (meal.description != null && meal.description!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final vf = context.vfColors;
    final hasDetails = (meal.description != null && meal.description!.isNotEmpty) ||
        meal.steps.isNotEmpty ||
        meal.ingredients.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // ExpansionTile draws its own dividers; drop them so the card edge stays clean.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          onExpansionChanged: (expanded) {
            // Lazily fetch the recipe the first time a light meal is opened.
            // Meals that already have a recipe render instantly, no network call.
            if (expanded && !_hasRecipe && !loadingRecipe) onNeedRecipe();
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plannerDayLabel(l10n, meal.day).toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: scheme.outline),
              ),
              const SizedBox(height: 4),
              Text(meal.name, style: Theme.of(context).textTheme.titleMedium),
              if (meal.note != null && meal.note!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(meal.note!, style: TextStyle(fontStyle: FontStyle.italic, color: scheme.outline)),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: regenerating ? null : onRegenerate,
                tooltip: l10n.plannerRegenerateDay,
                icon: regenerating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.refresh, color: scheme.primary),
              ),
              Icon(Icons.expand_more, color: scheme.outline),
            ],
          ),
          children: [
            // While the recipe is being lazily fetched, show a spinner in the
            // card body instead of the "no details" placeholder.
            if (loadingRecipe && !_hasRecipe)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.plannerLoadingRecipe, style: TextStyle(color: vf.mutedForeground)),
                  ],
                ),
              )
            else if (!hasDetails)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l10n.plannerNoRecipeDetails, style: TextStyle(color: vf.mutedForeground)),
              ),
            if (meal.description != null && meal.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(meal.description!, style: TextStyle(color: vf.mutedForeground)),
            ],
            if (meal.steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.plannerRecipeSteps,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < meal.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: vf.mistral.withValues(alpha: 0.22),
                          borderRadius: VfRadius.brXl,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: vf.accentForeground),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(meal.steps[i])),
                    ],
                  ),
                ),
            ],
            if (meal.ingredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.plannerIngredients,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...meal.ingredients.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• $i'),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
