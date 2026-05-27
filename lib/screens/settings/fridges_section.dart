import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/fridge_provider.dart';
import '../../providers/providers.dart';

class FridgesSection extends ConsumerWidget {
  const FridgesSection({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = await _promptText(context, l10n.fridgesNewName, l10n.fridgesNewNameHint);
    if (name == null || name.isEmpty) return;
    try {
      await ref.read(fridgesServiceProvider).create(name);
      await ref.read(fridgeControllerProvider.notifier).refresh();
    } on ApiError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _invite(BuildContext context, WidgetRef ref, Fridge f) async {
    final l10n = context.l10n;
    final email = await _promptText(context, l10n.fridgesInviteEmail, l10n.fridgesInviteHint);
    if (email == null || email.isEmpty) return;
    try {
      await ref.read(fridgesServiceProvider).invite(f.id, email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fridgesInviteSent(email))));
      }
    } on ApiError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Fridge f) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.fridgesDeleteTitle(f.name)),
        content: Text(l10n.fridgesDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.actionDelete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(fridgesServiceProvider).delete(f.id);
      final controller = ref.read(fridgeControllerProvider.notifier);
      // If the deleted fridge was active, clear the local pin so the controller
      // falls back to the first remaining fridge.
      final active = ref.read(fridgeControllerProvider).value?.activeId;
      if (active == f.id) await controller.setActive(null);
      await controller.refresh();
    } on ApiError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, Fridge f) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.fridgesLeaveTitle(f.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.actionLeave)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(fridgesServiceProvider).leave(f.id);
      final controller = ref.read(fridgeControllerProvider.notifier);
      final active = ref.read(fridgeControllerProvider).value?.activeId;
      if (active == f.id) await controller.setActive(null);
      await controller.refresh();
    } on ApiError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(fridgeControllerProvider);
    return state.when(
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(e.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      ),
      data: (data) {
        final activeId = data.active?.id;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.kitchen_outlined),
                    const SizedBox(width: 8),
                    Text(l10n.fridgesTitle, style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(onPressed: () => _create(context, ref), icon: const Icon(Icons.add)),
                  ],
                ),
                const SizedBox(height: 8),
                ...data.all.map((f) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          Expanded(child: Text(f.name)),
                          if (f.isOwner) Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Chip(label: Text(l10n.fridgesOwner), visualDensity: VisualDensity.compact),
                          ),
                        ],
                      ),
                      subtitle: Text(l10n.fridgesMembers(f.memberCount)),
                      leading: Icon(
                        f.id == activeId ? Icons.kitchen : Icons.kitchen_outlined,
                        color: f.id == activeId ? Theme.of(context).colorScheme.primary : null,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'invite') _invite(context, ref, f);
                          if (v == 'delete') _delete(context, ref, f);
                          if (v == 'leave') _leave(context, ref, f);
                        },
                        itemBuilder: (_) => [
                          if (f.isOwner) PopupMenuItem(value: 'invite', child: ListTile(leading: const Icon(Icons.person_add_outlined), title: Text(l10n.fridgesMenuInvite))),
                          if (f.isOwner) PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(l10n.fridgesMenuDelete))),
                          if (!f.isOwner) PopupMenuItem(value: 'leave', child: ListTile(leading: const Icon(Icons.logout), title: Text(l10n.fridgesMenuLeave))),
                        ],
                      ),
                    )),
                const SizedBox(height: 4),
                Text(
                  l10n.fridgesActiveHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<String?> _promptText(BuildContext context, String title, String hint) async {
  final l10n = context.l10n;
  final ctl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: ctl, autofocus: true, decoration: InputDecoration(hintText: hint)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctl.text.trim()), child: Text(l10n.actionOk)),
      ],
    ),
  );
}
