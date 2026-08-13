import 'package:flutter/material.dart';
import '../router/app_routes.dart';
import '../../features/auth/screens/landing_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.landing:
        return _fade(const LandingScreen());
      case AppRoutes.login:
        return _fade(const LoginScreen());
      case AppRoutes.register:
        return _fade(const RegisterScreen());
      default:
        return _fade(const LandingScreen());
    }
  }

  static PageRouteBuilder<T> _fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
