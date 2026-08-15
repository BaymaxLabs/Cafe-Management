import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.isLight,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool isLight;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color bg = enabled
        ? (isLight ? AppColors.loginButton : AppColors.registerButton)
        : const Color(0xFF2A2A2A);
    final Color fg = enabled
        ? (isLight ? AppColors.loginButtonText : AppColors.white)
        : const Color(0xFF555555);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: enabled ? onTap : null,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
