import 'package:flutter/material.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/brew_logo.dart';
import '../widgets/feature_item.dart';
import '../widgets/primary_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          return isWide
              ? _DesktopLayout(onLogin: _goLogin(context), onRegister: _goRegister(context))
              : _MobileLayout(onLogin: _goLogin(context), onRegister: _goRegister(context));
        },
      ),
    );
  }

  VoidCallback _goLogin(BuildContext context) =>
      () => Navigator.pushNamed(context, AppRoutes.login);

  VoidCallback _goRegister(BuildContext context) =>
      () => Navigator.pushNamed(context, AppRoutes.register);
}

// ─── Desktop (side-by-side) ───────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel
        Expanded(
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrewLogo(),
                const Spacer(),
                _HeroContent(),
                const Spacer(),
              ],
            ),
          ),
        ),
        // Divider
        Container(width: 1, color: const Color(0xFF2A2A2A)),
        // Right panel
        SizedBox(
          width: 580,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _GetStartedHeader(),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Login',
                  isLight: true,
                  onTap: onLogin,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Register',
                  isLight: false,
                  onTap: onRegister,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Mobile (stacked) ─────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: const BrewLogo(),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _HeroContent(showFeatures: false),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Login',
                  isLight: true,
                  onTap: onLogin,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Register',
                  isLight: false,
                  onTap: onRegister,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets (private to this file) ────────────────────────────────────

class _HeroContent extends StatelessWidget {
  const _HeroContent({this.showFeatures = true});

  final bool showFeatures;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cafe\nManagement.',
          style: isWide
              ? textTheme.displayLarge
              : textTheme.displayMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Simple tools for your team — orders, tables, and billing in one place.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        // Gold accent line
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (showFeatures) ...[
          const SizedBox(height: 40),
          Row(
            children: const [
              FeatureItem(title: 'Live orders', subtitle: 'Real-time SLA tracking'),
              SizedBox(width: 40),
              FeatureItem(title: 'Inventory', subtitle: 'Stock alerts & history'),
              SizedBox(width: 40),
              FeatureItem(title: 'QR tables', subtitle: 'Scan-to-order ready'),
            ],
          ),
        ],
      ],
    );
  }
}

class _GetStartedHeader extends StatelessWidget {
  const _GetStartedHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get started',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your workspace or register a new cafe.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
