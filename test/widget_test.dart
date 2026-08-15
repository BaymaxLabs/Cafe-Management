import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cafe_management/features/auth/screens/coming_soon_screen.dart';

void main() {
  testWidgets('shows the coming soon registration screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ComingSoonScreen()));

    expect(find.text('Coming Soon'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });
}
