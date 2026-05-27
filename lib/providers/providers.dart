import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/services.dart';
import '../models/api_models.dart';
import 'locale_provider.dart';

/// Base URL of the v-fridge-api. Override at build time with:
///   flutter run --dart-define=API_URL=https://v-fridge-api.onrender.com
const _defaultApiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:5080',   // Android emulator → host machine
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(_defaultApiUrl));

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(apiClientProvider)));
final productsServiceProvider = Provider<ProductsService>((ref) => ProductsService(ref.watch(apiClientProvider)));
final analyticsServiceProvider = Provider<AnalyticsService>((ref) => AnalyticsService(ref.watch(apiClientProvider)));
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
  AuthController(this._api, this._auth, this._locale) : super(const AuthState()) {
    _bootstrap();
  }

  final ApiClient _api;
  final AuthService _auth;
  final LocaleController _locale;

  Future<void> _bootstrap() async {
    final token = await _api.getAccessToken();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final me = await _auth.me();
      state = AuthState(status: AuthStatus.authenticated, user: me);
      await _locale.reconcileFromServer(me.preferredLanguage);
    } catch (_) {
      await _api.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    final pair = await _auth.login(email, password);
    state = AuthState(status: AuthStatus.authenticated, user: pair.user);
    await _locale.reconcileFromServer(pair.user.preferredLanguage);
  }

  /// Signup does NOT auto-login on the server — the user still needs to verify their email.
  /// The current resolved locale rides along so the new account starts with the right
  /// preferredLanguage (no extra PATCH needed after verification).
  Future<UserSummary> signup(String username, String email, String password) =>
      _auth.signup(
        username,
        email,
        password,
        preferredLanguage: LocaleController.resolveLanguageCode(_locale.state),
      );

  Future<void> verifyEmail(String token) async {
    final pair = await _auth.verifyEmail(token);
    state = AuthState(status: AuthStatus.authenticated, user: pair.user);
    await _locale.reconcileFromServer(pair.user.preferredLanguage);
  }

  Future<void> loginWithGoogle(String idToken) async {
    final pair = await _auth.loginWithGoogle(idToken);
    state = AuthState(status: AuthStatus.authenticated, user: pair.user);
    await _locale.reconcileFromServer(pair.user.preferredLanguage);
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

  /// Pushes a new preferred language to the server and rewrites local state with the
  /// returned summary. Caller is expected to also update [LocaleController] so the UI
  /// flips immediately.
  Future<void> updatePreferredLanguage(String code) async {
    if (state.status != AuthStatus.authenticated) return;
    final updated = await _auth.updatePreferences(preferredLanguage: code);
    state = state.copyWith(user: updated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    ref.watch(apiClientProvider),
    ref.watch(authServiceProvider),
    ref.watch(localeControllerProvider.notifier),
  ),
);
