import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart' show AppLocalizations;

/// Locales the app supports as user-visible UI languages.
/// Keep the codes in sync with `lib/l10n/app_*.arb` and the backend's
/// `SupportedLanguages` (`en`, `uk`).
const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('uk'),
];

extension AppLocalizationsX on BuildContext {
  /// `context.l10n.someKey` — shorter than `AppLocalizations.of(context).someKey`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Resolves a localized category label for a slug. Falls back to the English
/// label from the API when the slug is unknown.
String categoryLabel(AppLocalizations l10n, String slug) {
  switch (slug) {
    case 'dairy':
      return l10n.categoryDairy;
    case 'meat-fish':
      return l10n.categoryMeatFish;
    case 'vegetables':
      return l10n.categoryVegetables;
    case 'fruits':
      return l10n.categoryFruits;
    case 'bakery':
      return l10n.categoryBakery;
    case 'pantry':
      return l10n.categoryPantry;
    case 'snacks':
      return l10n.categorySnacks;
    case 'drinks':
      return l10n.categoryDrinks;
    case 'alcohol':
      return l10n.categoryAlcohol;
    case 'sauces':
      return l10n.categorySauces;
    case 'frozen':
      return l10n.categoryFrozen;
    case 'canned-prepared':
      return l10n.categoryCannedPrepared;
    default:
      return l10n.categoryOther;
  }
}

/// Resolves a localized day name. Input is the canonical English day name
/// returned by the backend (e.g. `"Monday"`).
String plannerDayLabel(AppLocalizations l10n, String day) {
  switch (day) {
    case 'Monday':
      return l10n.plannerDayMonday;
    case 'Tuesday':
      return l10n.plannerDayTuesday;
    case 'Wednesday':
      return l10n.plannerDayWednesday;
    case 'Thursday':
      return l10n.plannerDayThursday;
    case 'Friday':
      return l10n.plannerDayFriday;
    case 'Saturday':
      return l10n.plannerDaySaturday;
    case 'Sunday':
      return l10n.plannerDaySunday;
    default:
      return day;
  }
}
