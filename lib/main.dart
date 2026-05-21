import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/providers.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: VFridgeApp()));
}

class VFridgeApp extends ConsumerWidget {
  const VFridgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF8C5383), brightness: Brightness.light);
    final darkScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF8C5383), brightness: Brightness.dark);

    return MaterialApp(
      title: 'V-Fridge',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(useMaterial3: true, colorScheme: colorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkScheme),
      home: switch (auth.status) {
        AuthStatus.loading => const _SplashScreen(),
        AuthStatus.authenticated => const HomeShell(),
        AuthStatus.unauthenticated => const SignInScreen(),
      },
      routes: {
        '/signup': (_) => const SignUpScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
