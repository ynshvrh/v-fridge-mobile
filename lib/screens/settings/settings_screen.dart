import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/api_models.dart';
import '../../providers/providers.dart';
import '../../providers/theme_provider.dart';
import 'fridges_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileCard(auth: auth),
          const SizedBox(height: 16),
          _ThemeCard(mode: themeMode, onChanged: (m) => ref.read(themeControllerProvider.notifier).set(m)),
          const SizedBox(height: 16),
          const FridgesSection(),
          const SizedBox(height: 16),
          _DangerZone(ref: ref),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign out')),
                    ],
                  ),
                );
                if (ok == true) await ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.auth});
  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text((auth.user?.username ?? '?').characters.first.toUpperCase()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.user?.username ?? '—', style: Theme.of(context).textTheme.titleMedium),
                  Text(auth.user?.email ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                  if (auth.user != null) Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          auth.user!.emailVerified ? Icons.verified_outlined : Icons.warning_amber_outlined,
                          size: 14,
                          color: auth.user!.emailVerified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(auth.user!.emailVerified ? 'Email verified' : 'Email not verified',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.mode, required this.onChanged});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined),
                const SizedBox(width: 8),
                Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto_outlined)),
              ],
              selected: {mode},
              onSelectionChanged: (set) => onChanged(set.first),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.ref});
  final WidgetRef ref;

  Future<void> _confirmAndRun(BuildContext context, {required String title, required Future<void> Function() action, required String successMessage}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await action();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    } on ApiError catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: scheme.error),
                  const SizedBox(width: 8),
                  Text('Danger zone', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.error)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Clear all products'),
              subtitle: const Text('Empties the active fridge'),
              onTap: () => _confirmAndRun(
                context,
                title: 'Clear all products?',
                action: () async { await ref.read(productsServiceProvider).deleteAll(); },
                successMessage: 'Fridge cleared',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Delete chat history'),
              subtitle: const Text('Wipes the AI chef conversation'),
              onTap: () => _confirmAndRun(
                context,
                title: 'Delete chat history?',
                action: () => ref.read(chatServiceProvider).clear(),
                successMessage: 'Chat history cleared',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
