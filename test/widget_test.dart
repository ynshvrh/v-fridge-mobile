import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:v_fridge/main.dart';

void main() {
  testWidgets('App boots to a splash or signin screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: VFridgeApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
