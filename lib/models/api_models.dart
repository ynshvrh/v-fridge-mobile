/// Manually maintained DTOs that mirror the v-fridge-api OpenAPI schema.
/// Kept in sync with src/VFridge.Api/Contracts/* on the backend repo.
library;

import 'dart:convert';

import 'package:intl/intl.dart';

class ApiError implements Exception {
  final int status;
  final String code;
  final String message;
  final Map<String, List<String>>? validationErrors;

  ApiError(this.status, this.code, this.message, {this.validationErrors});

  @override
  String toString() => 'ApiError($status, $code): $message';
}

class TokenPair {
  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final UserSummary user;

  TokenPair({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory TokenPair.fromJson(Map<String, dynamic> j) => TokenPair(
        accessToken: j['accessToken'] as String,
        accessTokenExpiresAt: DateTime.parse(j['accessTokenExpiresAt'] as String),
        refreshToken: j['refreshToken'] as String,
        refreshTokenExpiresAt: DateTime.parse(j['refreshTokenExpiresAt'] as String),
        user: UserSummary.fromJson(j['user'] as Map<String, dynamic>),
      );
}

class UserSummary {
  final int id;
  final String username;
  final String email;
  final bool emailVerified;
  final String preferredLanguage;
  final String cuisinePreference;

  UserSummary({
    required this.id,
    required this.username,
    required this.email,
    required this.emailVerified,
    this.preferredLanguage = 'en',
    this.cuisinePreference = 'any',
  });

  factory UserSummary.fromJson(Map<String, dynamic> j) => UserSummary(
        id: j['id'] as int,
        username: j['username'] as String,
        email: j['email'] as String,
        emailVerified: j['emailVerified'] as bool,
        preferredLanguage: (j['preferredLanguage'] as String?) ?? 'en',
        cuisinePreference: (j['cuisinePreference'] as String?) ?? 'any',
      );
}

class Product {
  final int id;
  final String name;
  final String? description;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final String category;
  final int ownerId;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.category,
    required this.ownerId,
    this.createdAt,
  });

  bool get isPreparedMeal =>
      category == 'prepared-meals' ||
      unit.toLowerCase().contains('порц') ||
      unit.toLowerCase() == 'servings' ||
      (description != null && description!.contains('кКал'));

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as int,
        name: j['name'] as String,
        description: j['description'] as String?,
        quantity: (j['quantity'] as num).toDouble(),
        unit: j['unit'] as String,
        expiryDate: j['expiryDate'] != null ? DateTime.parse(j['expiryDate'] as String) : null,
        category: j['category'] as String? ?? 'other',
        ownerId: j['ownerId'] as int,
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt'] as String) : null,
      );
}


class ChatMessage {
  final int id;
  final String role;
  final String content;
  final DateTime? createdAt;

  ChatMessage({required this.id, required this.role, required this.content, this.createdAt});

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as int,
        role: j['role'] as String,
        content: j['content'] as String,
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt'] as String) : null,
      );
}

class ShoppingItem {
  final int id;
  final String name;
  final double? quantity;
  final String? unit;
  final String category;
  final bool checked;
  final DateTime? createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
    required this.category,
    required this.checked,
    this.createdAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> j) => ShoppingItem(
        id: j['id'] as int,
        name: j['name'] as String,
        quantity: (j['quantity'] as num?)?.toDouble(),
        unit: j['unit'] as String?,
        category: j['category'] as String? ?? 'other',
        checked: j['checked'] as bool? ?? false,
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt'] as String) : null,
      );
}

class MealPlan {
  final List<Meal> meals;
  final List<MealPlanGap> gapItems;
  final DateTime? generatedAt;

  MealPlan({required this.meals, required this.gapItems, this.generatedAt});

  factory MealPlan.fromJson(Map<String, dynamic> j) => MealPlan(
        meals: (j['meals'] as List).map((m) => Meal.fromJson(m as Map<String, dynamic>)).toList(),
        gapItems: (j['gapItems'] as List)
            .map((g) => MealPlanGap.fromJson(g as Map<String, dynamic>))
            .toList(),
        generatedAt: j['generatedAt'] is String
            ? DateTime.tryParse(j['generatedAt'] as String)
            : null,
      );
}

class Meal {
  final String name;
  final String day;
  final List<String> ingredients;
  final String? note;
  final String? description;
  final List<String> steps;
  final String? mealType;

  Meal({
    required this.name,
    required this.day,
    required this.ingredients,
    this.note,
    this.description,
    this.steps = const [],
    this.mealType,
  });

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
        name: j['name'] as String,
        day: j['day'] as String? ?? '',
        // Tolerate old cached plans that may be missing the list entirely.
        ingredients: (j['ingredients'] as List?)?.cast<String>() ?? const [],
        note: j['note'] as String?,
        description: j['description'] as String?,
        steps: (j['steps'] as List?)?.cast<String>() ?? const [],
        mealType: j['mealType'] as String?,
      );
}

class MealPlanGap {
  final String name;
  final String? quantity;
  final String? unit;
  final String category;

  MealPlanGap({required this.name, this.quantity, this.unit, required this.category});

  factory MealPlanGap.fromJson(Map<String, dynamic> j) => MealPlanGap(
        name: j['name'] as String,
        quantity: j['quantity']?.toString(),
        unit: j['unit'] as String?,
        category: j['category'] as String? ?? 'other',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
        'category': category,
      };
}

class Fridge {
  final int id;
  final String name;
  final int ownerId;
  final String role; // 'owner' | 'member'
  final int memberCount;
  final DateTime? createdAt;

  Fridge({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.role,
    required this.memberCount,
    this.createdAt,
  });

  bool get isOwner => role == 'owner';

  factory Fridge.fromJson(Map<String, dynamic> j) => Fridge(
        id: j['id'] as int,
        name: j['name'] as String,
        ownerId: j['ownerId'] as int,
        role: j['role'] as String,
        memberCount: j['memberCount'] as int? ?? 1,
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt'] as String) : null,
      );
}

class AnalyticsSummary {
  final List<AnalyticsLeader> mostWasted;
  final List<FastestConsumed> fastestConsumed;
  final List<WeeklyTrend> weeklyTrends;

  AnalyticsSummary({required this.mostWasted, required this.fastestConsumed, required this.weeklyTrends});

  factory AnalyticsSummary.fromJson(Map<String, dynamic> j) => AnalyticsSummary(
        mostWasted: ((j['mostWasted'] ?? []) as List)
            .map((x) => AnalyticsLeader.fromJson(x as Map<String, dynamic>))
            .toList(),
        fastestConsumed: ((j['fastestConsumed'] ?? []) as List)
            .map((x) => FastestConsumed.fromJson(x as Map<String, dynamic>))
            .toList(),
        weeklyTrends: ((j['weeklyTrends'] ?? []) as List)
            .map((x) => WeeklyTrend.fromJson(x as Map<String, dynamic>))
            .toList(),
      );

  bool get isEmpty => mostWasted.isEmpty && fastestConsumed.isEmpty && weeklyTrends.isEmpty;
}

class AnalyticsLeader {
  final String productName;
  final double totalQuantity;
  final int occurrences;
  final String category;

  AnalyticsLeader({required this.productName, required this.totalQuantity, required this.occurrences, required this.category});

  factory AnalyticsLeader.fromJson(Map<String, dynamic> j) => AnalyticsLeader(
        productName: j['productName'] as String,
        totalQuantity: (j['totalQuantity'] as num).toDouble(),
        occurrences: j['occurrences'] as int,
        category: j['category'] as String? ?? 'other',
      );
}

class FastestConsumed {
  final String productName;
  final String category;
  final int ageDays;

  FastestConsumed({required this.productName, required this.category, required this.ageDays});

  factory FastestConsumed.fromJson(Map<String, dynamic> j) => FastestConsumed(
        productName: j['productName'] as String,
        category: j['category'] as String? ?? 'other',
        ageDays: j['ageDays'] as int,
      );
}

class WeeklyTrend {
  final String weekStart;
  final int consumed;
  final int wasted;
  final int expired;

  WeeklyTrend({required this.weekStart, required this.consumed, required this.wasted, required this.expired});

  factory WeeklyTrend.fromJson(Map<String, dynamic> j) => WeeklyTrend(
        weekStart: j['weekStart'] as String,
        consumed: (j['consumed'] as int?) ?? 0,
        wasted: (j['wasted'] as int?) ?? 0,
        expired: (j['expired'] as int?) ?? 0,
      );
}

/// Slug → English label catalog. Mirrors src/VFridge.Api/Contracts/ProductCategories.cs.
class Categories {
  static const slugs = [
    'dairy',
    'meat-fish',
    'vegetables',
    'fruits',
    'bakery',
    'pantry',
    'snacks',
    'drinks',
    'alcohol',
    'sauces',
    'frozen',
    'canned-prepared',
    'prepared-meals',
    'other',
  ];

  static const _labels = {
    'dairy': 'Dairy',
    'meat-fish': 'Meat & fish',
    'vegetables': 'Vegetables & greens',
    'fruits': 'Fruits & berries',
    'bakery': 'Bread & bakery',
    'pantry': 'Pantry staples',
    'snacks': 'Snacks & sweets',
    'drinks': 'Drinks',
    'alcohol': 'Alcohol',
    'sauces': 'Sauces, oils & spices',
    'frozen': 'Frozen',
    'canned-prepared': 'Canned & ready-to-eat',
    'prepared-meals': 'Prepared meals',
    'other': 'Other',
  };

  static String label(String slug) => _labels[slug] ?? 'Other';
}

class ConsumeProductResult {
  final bool success;
  final String message;
  final double remainingQuantity;
  final bool deleted;

  ConsumeProductResult({
    required this.success,
    required this.message,
    required this.remainingQuantity,
    required this.deleted,
  });

  factory ConsumeProductResult.fromJson(Map<String, dynamic> j) => ConsumeProductResult(
        success: j['success'] as bool? ?? true,
        message: j['message'] as String? ?? '',
        remainingQuantity: (j['remainingQuantity'] as num?)?.toDouble() ?? 0.0,
        deleted: j['deleted'] as bool? ?? false,
      );
}

class ParsedChefResponse {
  final String message;
  final ParsedRecipe? recipe;
  final List<ParsedShoppingItem> suggestedShoppingItems;

  ParsedChefResponse({
    required this.message,
    this.recipe,
    this.suggestedShoppingItems = const [],
  });

  factory ParsedChefResponse.fromRaw(String content) {
    final trimmed = content.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final j = jsonDecode(trimmed) as Map<String, dynamic>;
        ParsedRecipe? recipe;
        if (j['recipe'] is Map<String, dynamic>) {
          recipe = ParsedRecipe.fromJson(j['recipe'] as Map<String, dynamic>);
        }
        final shopping = <ParsedShoppingItem>[];
        if (j['suggestedShoppingItems'] is List) {
          for (final item in j['suggestedShoppingItems'] as List) {
            if (item is Map<String, dynamic>) {
              shopping.add(ParsedShoppingItem.fromJson(item));
            }
          }
        }
        return ParsedChefResponse(
          message: (j['message'] as String?) ?? (recipe != null ? '' : trimmed),
          recipe: recipe,
          suggestedShoppingItems: shopping,
        );
      } catch (_) {
        // Fall back to plain text
      }
    }
    return ParsedChefResponse(message: content);
  }
}

class ParsedRecipe {
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;
  final int portions;

  ParsedRecipe({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.portions,
  });

  factory ParsedRecipe.fromJson(Map<String, dynamic> j) => ParsedRecipe(
        name: (j['name'] ?? j['title'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        ingredients: (j['ingredients'] as List?)?.map((i) => i.toString()).toList() ?? const [],
        steps: (j['steps'] as List?)?.map((s) => s.toString()).toList() ?? const [],
        calories: (j['calories'] as num?)?.toInt() ?? 0,
        protein: (j['protein'] as num?)?.toInt() ?? 0,
        fat: (j['fat'] as num?)?.toInt() ?? 0,
        carbs: (j['carbs'] as num?)?.toInt() ?? 0,
        portions: (j['portions'] as num?)?.toInt() ?? 2,
      );
}

class ParsedShoppingItem {
  final String name;
  final double quantity;
  final String unit;
  final String category;

  ParsedShoppingItem({
    required this.name,
    this.quantity = 1,
    this.unit = 'pcs',
    this.category = 'other',
  });

  factory ParsedShoppingItem.fromJson(Map<String, dynamic> j) => ParsedShoppingItem(
        name: (j['name'] ?? '') as String,
        quantity: (j['quantity'] as num?)?.toDouble() ?? 1.0,
        unit: (j['unit'] ?? 'pcs') as String,
        category: (j['category'] ?? 'other') as String,
      );
}

String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

