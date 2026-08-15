import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BrewLogo extends StatelessWidget {
  const BrewLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.coffee_rounded,
            color: AppColors.background,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'BREW',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}
