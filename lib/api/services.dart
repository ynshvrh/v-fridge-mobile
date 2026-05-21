import '../models/api_models.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<UserSummary> signup(String username, String email, String password) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/signup',
      body: {'username': username, 'email': email, 'password': password},
      skipAuth: true,
    );
    return UserSummary.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<TokenPair> login(String email, String password) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      body: {'email': email, 'password': password},
      skipAuth: true,
    );
    final pair = TokenPair.fromJson(data);
    await _api.storeTokens(pair);
    return pair;
  }

  Future<TokenPair> verifyEmail(String token) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/verify-email',
      body: {'token': token},
      skipAuth: true,
    );
    final pair = TokenPair.fromJson(data);
    await _api.storeTokens(pair);
    return pair;
  }

  Future<void> resendVerification(String email) =>
      _api.post('/auth/resend-verification', body: {'email': email}, skipAuth: true);

  Future<TokenPair> loginWithGoogle(String idToken) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/google',
      body: {'idToken': idToken},
      skipAuth: true,
    );
    final pair = TokenPair.fromJson(data);
    await _api.storeTokens(pair);
    return pair;
  }

  Future<UserSummary> me() async {
    final data = await _api.get<Map<String, dynamic>>('/auth/me');
    return UserSummary.fromJson(data);
  }

  Future<void> logout() async {
    final refresh = await _api.getRefreshToken();
    if (refresh != null) {
      try {
        await _api.post('/auth/logout', body: {'refreshToken': refresh}, skipAuth: true);
      } catch (_) {/* best-effort */}
    }
    await _api.clearTokens();
  }
}

class ProductsService {
  ProductsService(this._api);
  final ApiClient _api;

  Future<List<Product>> list() async {
    final data = await _api.get<List<dynamic>>('/products');
    return data.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();
  }

  Future<Product> create({
    required String name,
    String? description,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
    String category = 'other',
  }) async {
    final data = await _api.post<Map<String, dynamic>>('/products', body: {
      'name': name,
      if (description != null) 'description': description,
      'quantity': quantity,
      'unit': unit,
      if (expiryDate != null) 'expiryDate': formatDate(expiryDate),
      'category': category,
    });
    return Product.fromJson(data);
  }

  Future<void> patch(int id, {double? quantity, String? category}) =>
      _api.patch('/products/$id', body: {
        if (quantity != null) 'quantity': quantity,
        if (category != null) 'category': category,
      });

  Future<void> delete(int id) => _api.delete('/products/$id');

  /// Bulk-deletes every product in the active fridge. Each row writes a consumption_log entry.
  Future<int> deleteAll() async {
    final data = await _api.delete<Map<String, dynamic>>('/products');
    return (data['deleted'] as int?) ?? 0;
  }
}

class AnalyticsService {
  AnalyticsService(this._api);
  final ApiClient _api;

  Future<AnalyticsSummary> summary() async {
    final data = await _api.get<Map<String, dynamic>>('/analytics');
    return AnalyticsSummary.fromJson(data);
  }
}

class ChatService {
  ChatService(this._api);
  final ApiClient _api;

  Future<List<ChatMessage>> history() async {
    final data = await _api.get<List<dynamic>>('/chat');
    return data.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<ChatMessage> send(String content) async {
    final data = await _api.post<Map<String, dynamic>>('/chat', body: {'content': content});
    return ChatMessage.fromJson(data);
  }

  Future<void> clear() => _api.delete('/chat');
}

class ShoppingService {
  ShoppingService(this._api);
  final ApiClient _api;

  Future<List<ShoppingItem>> list() async {
    final data = await _api.get<List<dynamic>>('/shopping');
    return data.map((i) => ShoppingItem.fromJson(i as Map<String, dynamic>)).toList();
  }

  Future<ShoppingItem> create({
    required String name,
    double? quantity,
    String? unit,
    String category = 'other',
  }) async {
    final data = await _api.post<Map<String, dynamic>>('/shopping', body: {
      'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      'category': category,
    });
    return ShoppingItem.fromJson(data);
  }

  Future<ShoppingItem> patch(int id, {bool? checked, String? category}) async {
    final data = await _api.patch<Map<String, dynamic>>('/shopping/$id', body: {
      if (checked != null) 'checked': checked,
      if (category != null) 'category': category,
    });
    return ShoppingItem.fromJson(data);
  }

  Future<void> delete(int id) => _api.delete('/shopping/$id');

  Future<Product> purchase(int id, {DateTime? expiryDate}) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/shopping/$id/purchase',
      body: {'expiryDate': expiryDate == null ? null : formatDate(expiryDate)},
    );
    return Product.fromJson(data);
  }
}

class PlannerService {
  PlannerService(this._api);
  final ApiClient _api;

  Future<MealPlan> generate() async {
    final data = await _api.post<Map<String, dynamic>>('/meal-plan', body: {});
    return MealPlan.fromJson(data);
  }

  Future<({int created, int skipped})> importGaps(List<MealPlanGap> items) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/meal-plan/import-gaps',
      body: {'items': items.map((g) => g.toJson()).toList()},
    );
    return (created: data['created'] as int, skipped: data['skipped'] as int);
  }
}

class FridgesService {
  FridgesService(this._api);
  final ApiClient _api;

  Future<List<Fridge>> list() async {
    final data = await _api.get<List<dynamic>>('/fridges');
    return data.map((f) => Fridge.fromJson(f as Map<String, dynamic>)).toList();
  }

  Future<Fridge> create(String name) async {
    final data = await _api.post<Map<String, dynamic>>('/fridges', body: {'name': name});
    return Fridge.fromJson(data);
  }

  Future<Fridge> rename(int id, String name) async {
    final data = await _api.patch<Map<String, dynamic>>('/fridges/$id', body: {'name': name});
    return Fridge.fromJson(data);
  }

  Future<void> delete(int id) => _api.delete('/fridges/$id');

  Future<void> leave(int id) => _api.delete('/fridges/$id/members/me');

  Future<void> invite(int fridgeId, String email) =>
      _api.post('/fridges/$fridgeId/invites', body: {'email': email});

  Future<({int fridgeId, String fridgeName})> acceptInvite(String token) async {
    final data = await _api.post<Map<String, dynamic>>('/fridges/accept', body: {'token': token});
    return (fridgeId: data['fridgeId'] as int, fridgeName: data['fridgeName'] as String);
  }
}
