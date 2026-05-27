import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v_fridge/l10n/l10n.dart';

void main() {
  Widget wrap(Locale locale, Widget child) => MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedAppLocales,
        home: child,
      );

  testWidgets('English locale resolves expected strings', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(wrap(const Locale('en'), Builder(builder: (ctx) {
      l10n = AppLocalizations.of(ctx);
      return const SizedBox.shrink();
    })));
    expect(l10n.signinTitle, 'Welcome back');
    expect(l10n.dashboardAddProduct, 'Add product');
    expect(l10n.chatTitle, 'AI chef');
    expect(categoryLabel(l10n, 'meat-fish'), 'Meat & fish');
  });

  testWidgets('Ukrainian locale resolves expected strings', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(wrap(const Locale('uk'), Builder(builder: (ctx) {
      l10n = AppLocalizations.of(ctx);
      return const SizedBox.shrink();
    })));
    expect(l10n.signinTitle, 'З поверненням');
    expect(l10n.dashboardAddProduct, 'Додати продукт');
    expect(l10n.chatTitle, 'AI шеф');
    expect(categoryLabel(l10n, 'meat-fish'), 'М\'ясо та риба');
    expect(plannerDayLabel(l10n, 'Monday'), 'Понеділок');
  });

  testWidgets('Plural rules pick the right Ukrainian form', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(wrap(const Locale('uk'), Builder(builder: (ctx) {
      l10n = AppLocalizations.of(ctx);
      return const SizedBox.shrink();
    })));
    expect(l10n.productDaysLeft(1), 'залишився 1 день');
    expect(l10n.productDaysLeft(3), 'залишилось 3 дні');
    expect(l10n.productDaysLeft(5), 'залишилось 5 днів');
    expect(l10n.fridgesMembers(1), '1 учасник');
    expect(l10n.fridgesMembers(2), '2 учасники');
    expect(l10n.fridgesMembers(7), '7 учасників');
  });
}
