import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/brew_logo.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 1; // 1 = Phone, 2 = Verify
  int _phoneDigits = 0;
  bool _isLoading = false;
  String? _verificationId;
  ConfirmationResult? _webConfirmationResult;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() => _phoneDigits = _phoneController.text.length);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String get _phoneNumber => '+91${_phoneController.text.trim()}';

  Future<void> _onSendOtp() async {
    if (_phoneDigits != 10 || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        // Firebase displays and verifies the web reCAPTCHA before sending SMS.
        _webConfirmationResult = await FirebaseAuth.instance
            .signInWithPhoneNumber(_phoneNumber);
        if (mounted) setState(() => _step = 2);
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _phoneNumber,
          verificationCompleted: _finishNativeVerification,
          verificationFailed: (error) => _showError(_messageFor(error)),
          codeSent: (verificationId, _) {
            if (mounted) {
              setState(() {
                _verificationId = verificationId;
                _step = 2;
              });
            }
          },
          codeAutoRetrievalTimeout: (verificationId) {
            _verificationId = verificationId;
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      _showError(_messageFor(error));
    } catch (error, stackTrace) {
      debugPrintStack(
        label: 'Phone Auth send OTP error: $error',
        stackTrace: stackTrace,
      );
      _showError('Unexpected error: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onVerify() async {
    final code = _otpController.text.trim();
    if (code.length != 6 || _isLoading) {
      _showError('Enter the 6-digit code sent to your phone.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        final result = _webConfirmationResult;
        if (result == null) throw StateError('Please request a new OTP.');
        await result.confirm(code);
      } else {
        final verificationId = _verificationId;
        if (verificationId == null) {
          throw StateError('Please request a new OTP.');
        }
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: code,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      if (mounted) Navigator.pushNamed(context, AppRoutes.comingSoon);
    } on FirebaseAuthException catch (error) {
      _showError(_messageFor(error));
    } on StateError catch (error) {
      _showError(error.message.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _finishNativeVerification(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) Navigator.pushNamed(context, AppRoutes.comingSoon);
    } on FirebaseAuthException catch (error) {
      _showError(_messageFor(error));
    }
  }

  String _messageFor(FirebaseAuthException error) {
    final summary = switch (error.code) {
      'invalid-phone-number' => 'The phone number is invalid.',
      'invalid-verification-code' => 'The verification code is incorrect.',
      'session-expired' => 'The OTP session has expired.',
      'too-many-requests' => 'Firebase is rate-limiting requests.',
      _ => 'Firebase could not complete this request.',
    };
    final firebaseMessage = error.message?.trim();
    final details = firebaseMessage == null || firebaseMessage.isEmpty
        ? ''
        : '\n$firebaseMessage';

    debugPrint('Firebase phone auth error [${error.code}]: $firebaseMessage');
    return '$summary\nCode: ${error.code}$details';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 12),
        ),
      );
  }

  void _onBack(BuildContext context) {
    if (_step == 2) {
      setState(() {
        _step = 1;
        _otpController.clear();
      });
    } else {
      Navigator.pop(context);
    }
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
                  'Open\nyour cafe.',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Register your cafe and get your team up and running.',
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
                  onTap: () => _onBack(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
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
                _RegisterForm(
                  step: _step,
                  phoneController: _phoneController,
                  otpController: _otpController,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: _isLoading
                      ? (_step == 1 ? 'Sending OTP...' : 'Verifying...')
                      : (_step == 1 ? 'Send OTP' : 'Verify'),
                  isLight: false,
                  enabled:
                      !_isLoading && (_step == 1 ? _phoneDigits == 10 : true),
                  onTap: _step == 1 ? _onSendOtp : _onVerify,
                ),
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
              onPressed: () => _onBack(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.white,
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
              child: _RegisterForm(
                step: _step,
                phoneController: _phoneController,
                otpController: _otpController,
              ),
            ),
          ),
          // Action button pinned at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
            child: PrimaryButton(
              label: _isLoading
                  ? (_step == 1 ? 'Sending OTP...' : 'Verifying...')
                  : (_step == 1 ? 'Send OTP' : 'Verify'),
              isLight: false,
              enabled: !_isLoading && (_step == 1 ? _phoneDigits == 10 : true),
              onTap: _step == 1 ? _onSendOtp : _onVerify,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared form ─────────────────────────────────────────────────────────────

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.step,
    required this.phoneController,
    required this.otpController,
  });

  final int step;
  final TextEditingController phoneController;
  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          'Create account.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let\'s get your cafe set up.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),

        // Step indicator
        _StepIndicator(currentStep: step),
        const SizedBox(height: 28),

        // Step content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: step == 1
              ? _PhoneStep(key: const ValueKey(1), controller: phoneController)
              : _VerifyStep(key: const ValueKey(2), controller: otpController),
        ),
      ],
    );
  }
}

// ── Step indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(number: 1, label: 'Phone', isActive: currentStep >= 1),
        // Connector line
        Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: currentStep >= 2 ? AppColors.white : const Color(0xFF3A3A3A),
          ),
        ),
        _StepDot(number: 2, label: 'Verify', isActive: currentStep >= 2),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    required this.isActive,
  });
  final int number;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.white : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.white : const Color(0xFF555555),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: isActive ? AppColors.background : const Color(0xFF555555),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.white : const Color(0xFF555555),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Step 1: Phone ────────────────────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(text: 'PHONE NUMBER'),
        const SizedBox(height: 8),
        _PhoneField(controller: controller),
      ],
    );
  }
}

// ── Step 2: Verify OTP ───────────────────────────────────────────────────────

class _VerifyStep extends StatelessWidget {
  const _VerifyStep({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(text: 'ENTER OTP'),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 15,
            letterSpacing: 4,
          ),
          decoration: _inputDecoration(
            hint: '_ _ _ _ _ _',
          ).copyWith(counterText: ''),
        ),
        const SizedBox(height: 12),
        const Text(
          'OTP sent to your phone number.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Reusable private pieces ──────────────────────────────────────────────────

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
                Container(width: 1, height: 20, color: const Color(0xFF3A3A3A)),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppColors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(color: Color(0xFF555555), fontSize: 15),
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
