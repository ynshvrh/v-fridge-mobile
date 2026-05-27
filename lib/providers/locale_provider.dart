import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../l10n/l10n.dart';
import 'providers.dart';

/// Tracks whether the user has overridden the UI language. State `null` means
/// "follow the system locale"; a concrete [Locale] pins one of [supportedAppLocales].
///
/// On every state change we push the resolved code into [ApiClient.acceptLanguage]
/// so outbound requests carry the same locale the user sees on screen — the chef
/// uses this to pick its cultural prompt.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController(this._api) : super(null) {
    _load();
  }

  final ApiClient _api;

  static const _key = 'vf_locale';

  /// Best-effort resolver: returns the override when set, otherwise the first
  /// supported language code in the device's preferred list, defaulting to en.
  static String resolveLanguageCode(Locale? override) {
    if (override != null) return override.languageCode;
    final platformLocales = PlatformDispatcher.instance.locales;
    for (final loc in platformLocales) {
      final code = loc.languageCode;
      if (supportedAppLocales.any((s) => s.languageCode == code)) return code;
    }
    return 'en';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    state = (raw != null && supportedAppLocales.any((l) => l.languageCode == raw))
        ? Locale(raw)
        : null;
    _api.acceptLanguage = resolveLanguageCode(state);
  }

  /// Persists the choice locally and updates the outgoing Accept-Language header.
  /// Passing null restores "follow system".
  Future<void> set(Locale? locale) async {
    state = locale;
    _api.acceptLanguage = resolveLanguageCode(state);

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }

  /// Forces the local override to match a server-side preference (used after
  /// login / refreshUser). Does not bounce back to the server.
  Future<void> reconcileFromServer(String languageCode) async {
    if (!supportedAppLocales.any((l) => l.languageCode == languageCode)) return;
    if (state?.languageCode == languageCode) return;
    await set(Locale(languageCode));
  }
}

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(ref.watch(apiClientProvider)),
);
