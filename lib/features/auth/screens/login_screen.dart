import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../widgets/brew_logo.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _shopCodeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _shopCodeController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final phoneDigits = _phoneController.text.trim();
    final password = _passwordController.text;
    if (phoneDigits.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phoneDigits)) {
      _showError('Enter a valid 10-digit phone number.');
      return;
    }
    if (password.isEmpty || _isLoading) {
      if (password.isEmpty) _showError('Enter your password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await FirebaseFirestore.instance
          .collection('user')
          .where('phoneNumber', isEqualTo: '+91$phoneDigits')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 12));
      if (result.docs.isEmpty || result.docs.first.data()['password'] != password) {
        _showError('The phone number or password is incorrect.');
        return;
      }

      final details = <String, dynamic>{
        ...result.docs.first.data(),
        'shopCode': _shopCodeController.text.trim(),
      };
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
          arguments: details,
        );
      }
    } on TimeoutException {
      _showError('Login took too long. Please check your connection and retry.');
    } on FirebaseException catch (error) {
      _showError('Could not log in. ${error.message ?? 'Please try again.'}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          return isWide ? _buildDesktop(context) : _buildMobile(context);
        },
      ),
    );
  }

  // ── Desktop layout ──────────────────────────────────────────────────────────

  Widget _buildDesktop(BuildContext context) {
    return Row(
      children: [
        // Left branding panel
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrewLogo(),
                const Spacer(),
                Text(
                  'Welcome\nback.',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in to manage your cafe operations.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                const Text(
                  '© 2025 Brew · Cafe Management',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        // Divider
        Container(width: 1, color: const Color(0xFF2A2A2A)),
        // Right form panel
        SizedBox(
          width: 580,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back link
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(
                      context, AppRoutes.landing),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_left_rounded,
                          color: AppColors.textMuted, size: 20),
                      SizedBox(width: 2),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _LoginForm(
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  shopCodeController: _shopCodeController,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                    label: _isLoading ? 'Logging in...' : 'Login',
                    isLight: true,
                    enabled: !_isLoading,
                    onTap: _onLogin),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile layout ───────────────────────────────────────────────────────────

  Widget _buildMobile(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.white, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
              child: _LoginForm(
                phoneController: _phoneController,
                passwordController: _passwordController,
                shopCodeController: _shopCodeController,
              ),
            ),
          ),
          // Login button pinned at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
            child: PrimaryButton(
                label: _isLoading ? 'Logging in...' : 'Login',
                isLight: true,
                enabled: !_isLoading,
                onTap: _onLogin),
          ),
        ],
      ),
    );
  }
}

// ── Shared form ─────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.phoneController,
    required this.passwordController,
    required this.shopCodeController,
  });

  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController shopCodeController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          'Sign in',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your credentials to continue.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),

        // Phone Number
        const _FieldLabel(text: 'PHONE NUMBER'),
        const SizedBox(height: 8),
        _PhoneField(controller: phoneController),
        const SizedBox(height: 16),

        const _FieldLabel(text: 'PASSWORD'),
        const SizedBox(height: 8),
        _PasswordField(controller: passwordController),
        const SizedBox(height: 16),

        // Shop Code
        const _FieldLabel(text: 'SHOP CODE'),
        const SizedBox(height: 8),
        _ShopCodeField(controller: shopCodeController),
        const SizedBox(height: 6),
        const Text(
          'Optional — provided by your cafe owner.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Small reusable pieces (private to this file) ────────────────────────────

/// Uppercase small label above each field.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Shared [InputDecoration] for all form fields.
InputDecoration _inputDecoration({String? hint, Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 15),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
    ),
  );
}

/// Phone field with +91 country code prefix.
class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Text(
                  '+91',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                    width: 1, height: 20, color: const Color(0xFF3A3A3A)),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppColors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: '98765 43210',
                hintStyle:
                    TextStyle(color: Color(0xFF555555), fontSize: 15),
                border: InputBorder.none,
                counterText: '',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}


/// Password field with show/hide toggle.
class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller});
  final TextEditingController controller;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: const TextStyle(color: AppColors.white, fontSize: 15),
      decoration: _inputDecoration(
        hint: '••••••••',
        suffix: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textMuted,
            size: 18,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

/// Shop code field.
class _ShopCodeField extends StatelessWidget {
  const _ShopCodeField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(color: AppColors.white, fontSize: 15),
      decoration: _inputDecoration(hint: 'e.g. BREW001'),
    );
  }
}
