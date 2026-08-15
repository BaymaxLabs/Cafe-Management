import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/widgets/brew_logo.dart';
import '../../auth/widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.userDetails});

  final Map<String, dynamic> userDetails;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 800;
    final content = _UserDetails(userDetails: userDetails);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrewLogo(),
                          const Spacer(),
                          Text('Your cafe.', style: Theme.of(context).textTheme.displayLarge),
                          const SizedBox(height: 16),
                          Text('Your dashboard will be ready here soon.', style: Theme.of(context).textTheme.bodyLarge),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, color: const Color(0xFF2A2A2A)),
                  SizedBox(width: 580, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 452), child: content))),
                ],
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                child: content,
              ),
      ),
    );
  }
}

class _UserDetails extends StatelessWidget {
  const _UserDetails({required this.userDetails});

  final Map<String, dynamic> userDetails;

  @override
  Widget build(BuildContext context) {
    final cafeName = userDetails['cafeName'] as String? ?? 'Your cafe';
    final phone = userDetails['phoneNumber'] as String? ?? '—';
    final shopCode = userDetails['shopCode'] as String? ?? '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.storefront_outlined, color: AppColors.gold, size: 30),
        ),
        const SizedBox(height: 28),
        Text('Welcome back,', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
        Text(cafeName, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.gold, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text('You are signed in. Your home dashboard has no operational data yet.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF202020), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF2B2B2B))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ACCOUNT DETAILS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(height: 18),
              _DetailRow(label: 'Cafe', value: cafeName),
              const SizedBox(height: 14),
              _DetailRow(label: 'Phone', value: phone),
              if (shopCode.isNotEmpty) ...[
                const SizedBox(height: 14),
                _DetailRow(label: 'Shop code', value: shopCode),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Log out',
          isLight: false,
          onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.landing, (route) => false),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 92, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
