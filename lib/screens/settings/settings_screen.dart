import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'fridges_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
          ),
          const SizedBox(height: 16),
          const FridgesSection(),
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
