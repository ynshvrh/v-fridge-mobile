import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/services.dart';
import '../models/api_models.dart';

/// Base URL of the v-fridge-api. Override at build time with:
///   flutter run --dart-define=API_URL=https://v-fridge-api.onrender.com
const _defaultApiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:5080',   // Android emulator → host machine
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(_defaultApiUrl));

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(apiClientProvider)));
final productsServiceProvider = Provider<ProductsService>((ref) => ProductsService(ref.watch(apiClientProvider)));
final chatServiceProvider = Provider<ChatService>((ref) => ChatService(ref.watch(apiClientProvider)));
final shoppingServiceProvider = Provider<ShoppingService>((ref) => ShoppingService(ref.watch(apiClientProvider)));
final plannerServiceProvider = Provider<PlannerService>((ref) => PlannerService(ref.watch(apiClientProvider)));
final fridgesServiceProvider = Provider<FridgesService>((ref) => FridgesService(ref.watch(apiClientProvider)));

enum AuthStatus { loading, authenticated, unauthenticated }

@immutable
class AuthState {
  final AuthStatus status;
  final UserSummary? user;
  const AuthState({this.status = AuthStatus.loading, this.user});

  AuthState copyWith({AuthStatus? status, UserSummary? user}) =>
      AuthState(status: status ?? this.status, user: user ?? this.user);
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._api, this._auth) : super(const AuthState()) {
    _bootstrap();
  }

  final ApiClient _api;
  final AuthService _auth;

  Future<void> _bootstrap() async {
    final token = await _api.getAccessToken();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final me = await _auth.me();
      state = AuthState(status: AuthStatus.authenticated, user: me);
    } catch (_) {
      await _api.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    final pair = await _auth.login(email, password);
    state = AuthState(status: AuthStatus.authenticated, user: pair.user);
  }

  /// Signup does NOT auto-login on the server — the user still needs to verify their email.
  Future<UserSummary> signup(String username, String email, String password) =>
      _auth.signup(username, email, password);

  Future<void> verifyEmail(String token) async {
    final pair = await _auth.verifyEmail(token);
    state = AuthState(status: AuthStatus.authenticated, user: pair.user);
  }

  Future<void> loginWithGoogle(String idToken) async {
    final pair = await _auth.loginWithGoogle(idToken);
    state = AuthState(status: AuthStatus.authenticated, user: pair.user);
  }

  Future<void> refreshUser() async {
    try {
      state = state.copyWith(user: await _auth.me());
    } catch (_) {/* keep current */}
  }

  Future<void> logout() async {
    await _auth.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(apiClientProvider), ref.watch(authServiceProvider)),
);
