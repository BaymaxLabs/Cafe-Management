import 'package:flutter_test/flutter_test.dart';

import 'package:cafe_management/main.dart';

void main() {
  testWidgets('shows the full-screen message view', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TestMessageApp());

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.byType(TestMessageScreen), findsOneWidget);
  });
}
