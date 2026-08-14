import 'package:flutter/material.dart';
import '../router/app_routes.dart';
import '../../features/auth/screens/landing_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/coming_soon_screen.dart';
import '../../features/home/screens/home_screen.dart';

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
      case AppRoutes.comingSoon:
        return _fade(const ComingSoonScreen());
      case AppRoutes.dashboard:
        final userDetails = settings.arguments as Map<String, dynamic>? ?? {};
        return _fade(HomeScreen(userDetails: userDetails));
      default:
        return _fade(const LandingScreen());
    }
  }

  static PageRouteBuilder<T> _fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
