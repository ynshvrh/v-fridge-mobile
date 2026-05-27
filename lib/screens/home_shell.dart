import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import 'chat/chat_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'planner/planner_screen.dart';
import 'settings/settings_screen.dart';
import 'shopping/shopping_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static final _screens = const [
    DashboardScreen(),
    ShoppingScreen(),
    PlannerScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: _index == 0
          ? AppBar(title: Text(l10n.appTitle))
          : null, // child screens manage their own AppBars
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.kitchen_outlined), selectedIcon: const Icon(Icons.kitchen), label: l10n.navFridge),
          NavigationDestination(icon: const Icon(Icons.shopping_basket_outlined), selectedIcon: const Icon(Icons.shopping_basket), label: l10n.navShopping),
          NavigationDestination(icon: const Icon(Icons.calendar_today_outlined), selectedIcon: const Icon(Icons.calendar_today), label: l10n.navPlanner),
          NavigationDestination(icon: const Icon(Icons.restaurant_outlined), selectedIcon: const Icon(Icons.restaurant), label: l10n.navChef),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l10n.navSettings),
        ],
      ),
    );
  }
}
