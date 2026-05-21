import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/api_models.dart';
import '../../providers/providers.dart';

class FridgesSection extends ConsumerStatefulWidget {
  const FridgesSection({super.key});

  @override
  ConsumerState<FridgesSection> createState() => _FridgesSectionState();
}

class _FridgesSectionState extends ConsumerState<FridgesSection> {
  List<Fridge> _fridges = [];
  bool _loading = true;
  int? _activeId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ref.read(apiClientProvider);
    final activeId = await api.getActiveFridgeId();
    try {
      final list = await ref.read(fridgesServiceProvider).list();
      if (mounted) setState(() { _fridges = list; _activeId = activeId; _loading = false; });
    } on ApiError catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _setActive(int? id) async {
    await ref.read(apiClientProvider).setActiveFridgeId(id);
    setState(() => _activeId = id);
  }

  Future<void> _create() async {
    final name = await _promptText(context, 'New fridge name', 'My second fridge');
    if (name == null || name.isEmpty) return;
    try {
      final created = await ref.read(fridgesServiceProvider).create(name);
      setState(() => _fridges = [..._fridges, created]);
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _invite(Fridge f) async {
    final email = await _promptText(context, 'Invite by email', 'invitee@example.com');
    if (email == null || email.isEmpty) return;
    try {
      await ref.read(fridgesServiceProvider).invite(f.id, email);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invite sent to $email')));
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(Fridge f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${f.name}"?'),
        content: const Text('Products and members will be gone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(fridgesServiceProvider).delete(f.id);
      setState(() => _fridges = _fridges.where((x) => x.id != f.id).toList());
      if (_activeId == f.id) await _setActive(null);
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _leave(Fridge f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Leave "${f.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(fridgesServiceProvider).leave(f.id);
      setState(() => _fridges = _fridges.where((x) => x.id != f.id).toList());
      if (_activeId == f.id) await _setActive(null);
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())));
    }
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
                Text('Fridges', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(onPressed: _create, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 8),
            ..._fridges.map((f) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Expanded(child: Text(f.name)),
                      if (f.isOwner) const Padding(padding: EdgeInsets.only(left: 6), child: Chip(label: Text('owner'), visualDensity: VisualDensity.compact)),
                    ],
                  ),
                  subtitle: Text('${f.memberCount} ${f.memberCount == 1 ? 'member' : 'members'}'),
                  leading: Radio<int?>(
                    value: f.id,
                    groupValue: _activeId,
                    onChanged: (v) => _setActive(v),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'invite') _invite(f);
                      if (v == 'delete') _delete(f);
                      if (v == 'leave') _leave(f);
                    },
                    itemBuilder: (_) => [
                      if (f.isOwner) const PopupMenuItem(value: 'invite', child: ListTile(leading: Icon(Icons.person_add_outlined), title: Text('Invite'))),
                      if (f.isOwner) const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Delete'))),
                      if (!f.isOwner) const PopupMenuItem(value: 'leave', child: ListTile(leading: Icon(Icons.logout), title: Text('Leave'))),
                    ],
                  ),
                )),
            const SizedBox(height: 4),
            Text(
              'The selected fridge is sent as X-Fridge-Id on every read. Leave none selected to use your first owned fridge.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _promptText(BuildContext context, String title, String hint) async {
  final ctl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: ctl, autofocus: true, decoration: InputDecoration(hintText: hint)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctl.text.trim()), child: const Text('OK')),
      ],
    ),
  );
}
