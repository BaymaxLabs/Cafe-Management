// Spec: PrimaryButton widget
//
// PrimaryButton is a full-width button used across all features.
// It has two visual modes (light/dark) and a disabled state.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cafe_management/features/auth/widgets/primary_button.dart';

Widget buildSubject({
  required String label,
  required bool isLight,
  required VoidCallback onTap,
  bool enabled = true,
}) => MaterialApp(
      home: Scaffold(
        body: PrimaryButton(
          label: label,
          isLight: isLight,
          onTap: onTap,
          enabled: enabled,
        ),
      ),
    );

void main() {
  group('PrimaryButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(buildSubject(
        label: 'Login',
        isLight: true,
        onTap: () {},
      ));
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('calls onTap when enabled and tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(
        label: 'Login',
        isLight: true,
        onTap: () => tapped = true,
      ));
      await tester.tap(find.byType(TextButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(
        label: 'Login',
        isLight: true,
        onTap: () => tapped = true,
        enabled: false,
      ));
      await tester.tap(find.byType(TextButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('is full width', (tester) async {
      await tester.pumpWidget(buildSubject(
        label: 'Login',
        isLight: true,
        onTap: () {},
      ));
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, double.infinity);
    });
  });
}
