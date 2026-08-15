import 'package:flutter/material.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/primary_button.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  void _backToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.landing,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 18, 40, 42),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    fixedSize: const Size(62, 62),
                    backgroundColor: const Color(0xFF232323),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const _ComingSoonContent(),
              const Spacer(),
              PrimaryButton(
                label: 'Back to Home',
                isLight: false,
                onTap: () => _backToHome(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonContent extends StatelessWidget {
  const _ComingSoonContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFF232323),
            borderRadius: BorderRadius.circular(38),
          ),
          child: const Icon(
            Icons.schedule_outlined,
            color: AppColors.gold,
            size: 48,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Coming Soon',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Text(
            "Full registration is on its way. We'll let\nyou know when it's ready.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF777777),
              fontSize: 17,
              height: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}
