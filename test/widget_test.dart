// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:food_waste_app/core/theme/app_theme.dart';

void main() {
  test('AppTheme loads successfully and contains correct primary color', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final theme = AppTheme.theme;
    expect(theme.primaryColor, const Color(0xFF1A237E));
  });
}
