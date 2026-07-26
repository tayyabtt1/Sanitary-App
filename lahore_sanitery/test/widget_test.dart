
// Basic smoke test to confirm the app boots without crashing.
// This replaces Flutter's default template test, which referenced a
// placeholder "MyApp" class that doesn't exist in this project.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:lahore_sanitery/services/product_repository.dart';
import 'package:lahore_sanitery/widgets/main_nav.dart';

void main() {
  testWidgets('App boots and shows bottom navigation', (tester) async {
    // Hive needs to be initialized before ProductRepository is used,
    // same as in main.dart, otherwise this test will crash on setup.
    await Hive.initFlutter();
    await ProductRepository.init();

    await tester.pumpWidget(
      const MaterialApp(home: MainNav()),
    );

    // Confirms the 3-tab bottom nav rendered successfully.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Manage'), findsOneWidget);
  });
} 