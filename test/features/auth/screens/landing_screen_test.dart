// Spec: LandingScreen widget
//
// The landing screen is the entry point. It shows the Brew branding and
// two buttons — Login and Register — that navigate to their respective screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cafe_management/core/router/app_routes.dart';
import 'package:cafe_management/features/auth/screens/landing_screen.dart';

void main() {
  // Use a standard mobile viewport to force the mobile layout and avoid
  // overflow errors from the desktop split-panel layout in small test surfaces.
  const mobileSize = Size(390, 844);

  group('LandingScreen', () {
    testWidgets('shows Login button', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      await tester.pumpWidget(const MaterialApp(home: LandingScreen()));
      expect(find.widgetWithText(TextButton, 'Login'), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('shows Register button', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      await tester.pumpWidget(const MaterialApp(home: LandingScreen()));
      expect(find.widgetWithText(TextButton, 'Register'), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('shows BREW logo text', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      await tester.pumpWidget(const MaterialApp(home: LandingScreen()));
      expect(find.text('BREW'), findsOneWidget);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('tapping Login navigates to login route', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      String? pushedRoute;
      await tester.pumpWidget(MaterialApp(
        home: const LandingScreen(),
        onGenerateRoute: (settings) {
          pushedRoute = settings.name;
          return MaterialPageRoute(builder: (_) => const Scaffold());
        },
      ));
      await tester.tap(find.widgetWithText(TextButton, 'Login'));
      await tester.pumpAndSettle();
      expect(pushedRoute, AppRoutes.login);
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('tapping Register navigates to register route', (tester) async {
      await tester.binding.setSurfaceSize(mobileSize);
      String? pushedRoute;
      await tester.pumpWidget(MaterialApp(
        home: const LandingScreen(),
        onGenerateRoute: (settings) {
          pushedRoute = settings.name;
          return MaterialPageRoute(builder: (_) => const Scaffold());
        },
      ));
      await tester.tap(find.widgetWithText(TextButton, 'Register'));
      await tester.pumpAndSettle();
      expect(pushedRoute, AppRoutes.register);
      await tester.binding.setSurfaceSize(null);
    });
  });
}
