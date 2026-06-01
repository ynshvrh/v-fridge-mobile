import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../models/cuisines.dart';
import '../../providers/locale_provider.dart';
import '../../providers/providers.dart';
import '../../providers/theme_provider.dart';
import '../../theme/vf_colors.dart';
import '../../widgets/staggered_entry.dart';
import 'fridges_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final localeOverride = ref.watch(localeControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StaggeredEntry(index: 0, child: _ProfileCard(auth: auth)),
          const SizedBox(height: 16),
          StaggeredEntry(
            index: 1,
            child: _ThemeCard(mode: themeMode, onChanged: (m) => ref.read(themeControllerProvider.notifier).set(m)),
          ),
          const SizedBox(height: 16),
          StaggeredEntry(
            index: 2,
            child: _LanguageCard(
              localeOverride: localeOverride,
              onChanged: (locale) async {
                await ref.read(localeControllerProvider.notifier).set(locale);
                if (auth.status == AuthStatus.authenticated) {
                  try {
                    await ref.read(authControllerProvider.notifier)
                        .updatePreferredLanguage(LocaleController.resolveLanguageCode(locale));
                  } on ApiError catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                    }
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          StaggeredEntry(
            index: 3,
            child: _CuisineCard(
              currentSlug: auth.user?.cuisinePreference ?? Cuisines.any,
              onChanged: (slug) async {
                if (auth.status != AuthStatus.authenticated) return;
                try {
                  await ref.read(authControllerProvider.notifier).updateCuisinePreference(slug);
                } on ApiError catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          const StaggeredEntry(index: 4, child: FridgesSection()),
          const SizedBox(height: 16),
          StaggeredEntry(index: 5, child: _DangerZone(ref: ref)),
          const SizedBox(height: 16),
          StaggeredEntry(
            index: 6,
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                leading: const Icon(Icons.logout),
                title: Text(l10n.settingsSignOut, style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.settingsSignOutConfirm),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.settingsSignOut)),
                      ],
                    ),
                  );
                  if (ok == true) await ref.read(authControllerProvider.notifier).logout();
                },
              ),
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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(
                (auth.user?.username ?? '?').characters.first.toUpperCase(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.user?.username ?? '—', style: Theme.of(context).textTheme.titleMedium),
                  Text(auth.user?.email ?? '—', style: TextStyle(color: context.vfColors.mutedForeground)),
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
                        Text(auth.user!.emailVerified ? context.l10n.settingsEmailVerified : context.l10n.settingsEmailNotVerified,
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

/// Card header row reused across every settings section so the icon + title
/// rhythm stays consistent.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.mode, required this.onChanged});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(icon: Icons.palette_outlined, title: l10n.settingsAppearance),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.settingsThemeLight), icon: const Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.settingsThemeDark), icon: const Icon(Icons.dark_mode_outlined)),
                ButtonSegment(value: ThemeMode.system, label: Text(l10n.settingsThemeSystem), icon: const Icon(Icons.brightness_auto_outlined)),
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

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.localeOverride, required this.onChanged});
  final Locale? localeOverride;
  final ValueChanged<Locale?> onChanged;

  // sentinel used in SegmentedButton.selected; SegmentedButton doesn't allow null values directly.
  static const Locale _systemSentinel = Locale('__system__');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = localeOverride ?? _systemSentinel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(icon: Icons.translate_outlined, title: l10n.settingsLanguage),
            const SizedBox(height: 16),
            SegmentedButton<Locale>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: _systemSentinel, label: Text(l10n.settingsLanguageAuto)),
                ButtonSegment(value: const Locale('en'), label: Text(l10n.settingsLanguageEnglish)),
                ButtonSegment(value: const Locale('uk'), label: Text(l10n.settingsLanguageUkrainian)),
              ],
              selected: {selected},
              onSelectionChanged: (set) {
                final picked = set.first;
                onChanged(picked == _systemSentinel ? null : picked);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CuisineCard extends StatelessWidget {
  const _CuisineCard({required this.currentSlug, required this.onChanged});
  final String currentSlug;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slug = Cuisines.slugs.contains(currentSlug) ? currentSlug : Cuisines.any;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(icon: Icons.local_dining_outlined, title: l10n.settingsCuisine),
            const SizedBox(height: 8),
            Text(
              l10n.settingsCuisineHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: slug,
              decoration: InputDecoration(labelText: l10n.settingsCuisine),
              items: Cuisines.slugs
                  .map((s) => DropdownMenuItem(value: s, child: Text(cuisineLabel(l10n, s))))
                  .toList(),
              onChanged: (v) {
                if (v != null && v != slug) onChanged(v);
              },
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
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(l10n.settingsCannotBeUndone),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
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
    final l10n = context.l10n;
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
                  Text(l10n.settingsDangerZone, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.error)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: Text(l10n.settingsClearProducts),
              subtitle: Text(l10n.settingsClearProductsSubtitle),
              onTap: () => _confirmAndRun(
                context,
                title: l10n.settingsClearProductsConfirm,
                action: () async { await ref.read(productsServiceProvider).deleteAll(); },
                successMessage: l10n.settingsFridgeCleared,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: Text(l10n.settingsDeleteChat),
              subtitle: Text(l10n.settingsDeleteChatSubtitle),
              onTap: () => _confirmAndRun(
                context,
                title: l10n.settingsDeleteChatConfirm,
                action: () => ref.read(chatServiceProvider).clear(),
                successMessage: l10n.settingsChatCleared,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
