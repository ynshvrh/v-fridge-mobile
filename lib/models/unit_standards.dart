/// Unified standard for measurement units across the V-Fridge mobile client.
/// Provides canonical unit keys, normalization, localized display names (Ukrainian / English),
/// and dropdown options.
class UnitStandards {
  // Canonical keys matching VFridge.Api.Contracts.UnitStandards
  static const String piece = 'pcs';
  static const String gram = 'g';
  static const String kilogram = 'kg';
  static const String milliliter = 'ml';
  static const String liter = 'l';
  static const String tablespoon = 'tbsp';
  static const String teaspoon = 'tsp';
  static const String pinch = 'pinch';
  static const String clove = 'clove';
  static const String servings = 'servings';
  static const String pack = 'pack';

  static const List<String> canonicalUnits = [
    piece,
    gram,
    kilogram,
    milliliter,
    liter,
    tablespoon,
    teaspoon,
    pinch,
    clove,
    servings,
    pack,
  ];

  static const List<String> commonUnits = [
    piece,
    gram,
    kilogram,
    milliliter,
    liter,
    pack,
    servings,
  ];

  /// Normalizes localized or raw unit strings to canonical unit keys.
  static String normalize(String? unit) {
    if (unit == null || unit.trim().isEmpty) return piece;
    final u = unit.trim().toLowerCase().replaceAll(RegExp(r'\.$'), '');
    switch (u) {
      case 'кг':
      case 'kg':
      case 'кілограм':
      case 'кілограмів':
      case 'килограмм':
      case 'килограм':
        return kilogram;
      case 'г':
      case 'g':
      case 'грам':
      case 'грамів':
      case 'грамм':
      case 'гр':
        return gram;
      case 'л':
      case 'l':
      case 'літр':
      case 'літрів':
      case 'литр':
        return liter;
      case 'мл':
      case 'ml':
      case 'мілілітр':
      case 'мілілітрів':
      case 'миллилитр':
        return milliliter;
      case 'шт':
      case 'pcs':
      case 'штук':
      case 'штуки':
      case 'штука':
      case 'pc':
      case 'piece':
      case 'pieces':
        return piece;
      case 'ст.л':
      case 'ст. л':
      case 'ст л':
      case 'столова ложка':
      case 'столові ложки':
      case 'tbsp':
      case 'tablespoon':
        return tablespoon;
      case 'ч.л':
      case 'ч. л':
      case 'ч л':
      case 'чайна ложка':
      case 'чайні ложки':
      case 'tsp':
      case 'teaspoon':
        return teaspoon;
      case 'дрібка':
      case 'щепотка':
      case 'pinch':
        return pinch;
      case 'зубчик':
      case 'зубчики':
      case 'зубчиків':
      case 'clove':
      case 'cloves':
        return clove;
      case 'порція':
      case 'порції':
      case 'порцій':
      case 'порц':
      case 'serving':
      case 'servings':
        return servings;
      case 'уп':
      case 'упак':
      case 'упаковка':
      case 'упаковки':
      case 'pack':
      case 'packs':
      case 'pkg':
        return pack;
      default:
        return u;
    }
  }

  /// Formats a unit into a short localized string based on the given locale.
  static String format(String? unit, [String? locale]) {
    if (unit == null || unit.trim().isEmpty) {
      return (locale?.startsWith('uk') ?? false) ? 'шт' : 'pcs';
    }
    final norm = normalize(unit);
    final isUk = locale?.startsWith('uk') ?? false;

    switch (norm) {
      case piece:
        return isUk ? 'шт' : 'pcs';
      case gram:
        return isUk ? 'г' : 'g';
      case kilogram:
        return isUk ? 'кг' : 'kg';
      case milliliter:
        return isUk ? 'мл' : 'ml';
      case liter:
        return isUk ? 'л' : 'l';
      case tablespoon:
        return isUk ? 'ст. л.' : 'tbsp';
      case teaspoon:
        return isUk ? 'ч. л.' : 'tsp';
      case pinch:
        return isUk ? 'дрібка' : 'pinch';
      case clove:
        return isUk ? 'зубчик' : 'clove';
      case servings:
        return isUk ? 'порцій' : 'servings';
      case pack:
        return isUk ? 'уп' : 'pack';
      default:
        return unit.trim();
    }
  }

  /// Returns localized dropdown options for picking units.
  static List<({String value, String label})> options([String? locale, bool commonOnly = true]) {
    final list = commonOnly ? commonUnits : canonicalUnits;
    final isUk = locale?.startsWith('uk') ?? false;

    return list.map((u) {
      String label;
      switch (u) {
        case piece:
          label = isUk ? 'шт (штуки)' : 'pcs (pieces)';
          break;
        case gram:
          label = isUk ? 'г (грами)' : 'g (grams)';
          break;
        case kilogram:
          label = isUk ? 'кг (кілограми)' : 'kg (kilograms)';
          break;
        case milliliter:
          label = isUk ? 'мл (мілілітри)' : 'ml (milliliters)';
          break;
        case liter:
          label = isUk ? 'л (літри)' : 'l (liters)';
          break;
        case pack:
          label = isUk ? 'уп (упаковки)' : 'pack (packages)';
          break;
        case servings:
          label = isUk ? 'порцій (порції)' : 'servings';
          break;
        case tablespoon:
          label = isUk ? 'ст. л. (столові ложки)' : 'tbsp (tablespoons)';
          break;
        case teaspoon:
          label = isUk ? 'ч. л. (чайні ложки)' : 'tsp (teaspoons)';
          break;
        case pinch:
          label = isUk ? 'дрібка' : 'pinch';
          break;
        case clove:
          label = isUk ? 'зубчик' : 'clove';
          break;
        default:
          label = u;
      }
      return (value: u, label: label);
    }).toList();
  }
}
