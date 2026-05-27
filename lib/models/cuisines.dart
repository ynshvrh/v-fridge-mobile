import 'dart:ui';

/// Cuisine slugs the API accepts. Keep in sync with `SupportedCuisines.cs` and
/// the CHECK constraint in migration 008.
class Cuisines {
  static const any = 'any';

  /// Order shown in the picker. `any` lives at the top as the neutral default.
  static const slugs = <String>[
    any,
    'ukrainian',
    'georgian',
    'italian',
    'french',
    'mexican',
    'middle-eastern',
    'indian',
    'chinese',
    'japanese',
    'thai',
    'american',
  ];

  /// Maps a device country code (ISO 3166-1 alpha-2) to the most reasonable cuisine
  /// default. Anything outside this list falls back to [any] — the chef stays
  /// neutral until the user picks something explicitly.
  static const _countryToCuisine = <String, String>{
    'UA': 'ukrainian',
    'GE': 'georgian',
    'IT': 'italian',
    'FR': 'french',
    'MX': 'mexican',
    'IL': 'middle-eastern',
    'AE': 'middle-eastern',
    'SA': 'middle-eastern',
    'EG': 'middle-eastern',
    'TR': 'middle-eastern',
    'LB': 'middle-eastern',
    'IN': 'indian',
    'CN': 'chinese',
    'HK': 'chinese',
    'TW': 'chinese',
    'JP': 'japanese',
    'TH': 'thai',
    'US': 'american',
    'CA': 'american',
  };

  static String fromCountryCode(String? countryCode) {
    if (countryCode == null) return any;
    return _countryToCuisine[countryCode.toUpperCase()] ?? any;
  }

  /// Best-effort: returns the cuisine slug that matches the device's current locale
  /// country, or `any` if the country is unknown / unsupported.
  static String defaultForDevice() {
    final locales = PlatformDispatcher.instance.locales;
    for (final loc in locales) {
      final picked = fromCountryCode(loc.countryCode);
      if (picked != any) return picked;
    }
    return any;
  }
}
