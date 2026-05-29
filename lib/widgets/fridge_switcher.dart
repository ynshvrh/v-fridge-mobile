import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/fridge_provider.dart';
import '../theme/vf_colors.dart';
import '../theme/vf_radius.dart';

/// Compact PopupMenuButton that shows the active fridge name and lets the user
/// switch. Designed to live in an [AppBar.actions]. Tapping a different fridge
/// rewrites the persisted X-Fridge-Id on the API client and updates
/// [FridgeController] so every screen watching the active id rebuilds.
class FridgeSwitcher extends ConsumerWidget {
  const FridgeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fridgeControllerProvider);
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (data) {
        final active = data.active;
        if (active == null || data.all.length <= 1) {
          // No fridges to switch between — fall back to a static badge if one exists.
          return active == null
              ? const SizedBox.shrink()
              : _Chip(name: active.name, onTap: null);
        }
        return PopupMenuButton<int>(
          tooltip: '',
          position: PopupMenuPosition.under,
          offset: const Offset(0, 4),
          onSelected: (id) => ref.read(fridgeControllerProvider.notifier).setActive(id),
          itemBuilder: (_) => data.all.map((f) {
            final selected = f.id == active.id;
            return PopupMenuItem<int>(
              value: f.id,
              child: Row(
                children: [
                  Icon(
                    selected ? Icons.kitchen : Icons.kitchen_outlined,
                    size: 18,
                    color: selected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f.name,
                      style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          child: _Chip(name: active.name, onTap: () {}),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.name, required this.onTap});
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final vf = context.vfColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: vf.zephir,
          borderRadius: VfRadius.brXl,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.kitchen_outlined, size: 16),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

/// Slim subtitle row used at the top of Shopping / Planner to remind the user
/// which fridge the list belongs to. Hidden when no fridge is active.
class ActiveFridgeBanner extends ConsumerWidget {
  const ActiveFridgeBanner({super.key, required this.icon, required this.label});
  final IconData icon;

  /// Localized label like "Shopping list for". The fridge name follows after.
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridge = ref.watch(fridgeControllerProvider).value?.active;
    if (fridge == null) return const SizedBox.shrink();
    final vf = context.vfColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: vf.zephir,
          borderRadius: VfRadius.brLg,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: vf.accentForeground),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$label '),
                  TextSpan(text: fridge.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
                style: TextStyle(color: vf.accentForeground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
