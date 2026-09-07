import 'package:flutter_test/flutter_test.dart';
import 'package:v_fridge/models/api_models.dart';
import 'package:v_fridge/models/unit_standards.dart';

void main() {
  group('UnitStandards normalization and formatting', () {
    test('normalizes Ukrainian and English synonyms to canonical keys', () {
      expect(UnitStandards.normalize('кг'), UnitStandards.kilogram);
      expect(UnitStandards.normalize('kg'), UnitStandards.kilogram);
      expect(UnitStandards.normalize('кілограмів'), UnitStandards.kilogram);
      expect(UnitStandards.normalize('г'), UnitStandards.gram);
      expect(UnitStandards.normalize('g'), UnitStandards.gram);
      expect(UnitStandards.normalize('мл'), UnitStandards.milliliter);
      expect(UnitStandards.normalize('ml'), UnitStandards.milliliter);
      expect(UnitStandards.normalize('л'), UnitStandards.liter);
      expect(UnitStandards.normalize('l'), UnitStandards.liter);
      expect(UnitStandards.normalize('шт'), UnitStandards.piece);
      expect(UnitStandards.normalize('pcs'), UnitStandards.piece);
      expect(UnitStandards.normalize('порцій'), UnitStandards.servings);
      expect(UnitStandards.normalize('порція'), UnitStandards.servings);
      expect(UnitStandards.normalize('servings'), UnitStandards.servings);
    });

    test('formats canonical keys for Ukrainian and English locales', () {
      expect(UnitStandards.format('kg', 'uk'), 'кг');
      expect(UnitStandards.format('kg', 'en'), 'kg');
      expect(UnitStandards.format('g', 'uk'), 'г');
      expect(UnitStandards.format('g', 'en'), 'g');
      expect(UnitStandards.format('ml', 'uk'), 'мл');
      expect(UnitStandards.format('ml', 'en'), 'ml');
      expect(UnitStandards.format('l', 'uk'), 'л');
      expect(UnitStandards.format('l', 'en'), 'l');
      expect(UnitStandards.format('pcs', 'uk'), 'шт');
      expect(UnitStandards.format('pcs', 'en'), 'pcs');
      expect(UnitStandards.format('servings', 'uk'), 'порцій');
      expect(UnitStandards.format('servings', 'en'), 'servings');
    });

    test('provides dropdown options with localized labels', () {
      final ukOptions = UnitStandards.options('uk');
      expect(ukOptions.any((o) => o.value == 'pcs' && o.label.contains('шт')), isTrue);
      expect(ukOptions.any((o) => o.value == 'kg' && o.label.contains('кг')), isTrue);

      final enOptions = UnitStandards.options('en');
      expect(enOptions.any((o) => o.value == 'pcs' && o.label.contains('pcs')), isTrue);
      expect(enOptions.any((o) => o.value == 'kg' && o.label.contains('kg')), isTrue);
    });
  });

  group('ParsedChefResponse JSON parsing', () {
    test('parses plain text as message without recipe', () {
      final response = ParsedChefResponse.fromRaw('Hello chef!');
      expect(response.message, 'Hello chef!');
      expect(response.recipe, isNull);
      expect(response.suggestedShoppingItems, isEmpty);
    });

    test('parses structured JSON with recipe and shopping suggestions', () {
      const raw = '''
      {
        "message": "Here is a recipe for Borscht",
        "recipe": {
          "name": "Borscht",
          "description": "Traditional beet soup",
          "ingredients": ["500g beets", "300g cabbage", "200g meat"],
          "steps": ["Chop vegetables", "Boil broth", "Simmer until tender"],
          "calories": 350,
          "protein": 18,
          "fat": 12,
          "carbs": 25,
          "portions": 4
        },
        "suggestedShoppingItems": [
          {"name": "Sour cream", "quantity": 1.0, "unit": "pack", "category": "dairy"}
        ]
      }
      ''';

      final response = ParsedChefResponse.fromRaw(raw);
      expect(response.message, 'Here is a recipe for Borscht');
      expect(response.recipe, isNotNull);
      expect(response.recipe!.name, 'Borscht');
      expect(response.recipe!.calories, 350);
      expect(response.recipe!.portions, 4);
      expect(response.recipe!.ingredients.length, 3);
      expect(response.suggestedShoppingItems.length, 1);
      expect(response.suggestedShoppingItems.first.name, 'Sour cream');
      expect(response.suggestedShoppingItems.first.unit, 'pack');
    });
  });
}
