import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const CafeManagementApp());
}

class CafeManagementApp extends StatelessWidget {
  const CafeManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brew — Cafe Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.landing,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
