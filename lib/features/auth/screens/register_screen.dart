import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../../firebase_options.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/brew_logo.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 1; // 1 = Phone, 2 = Verify, 3 = Password, 4 = Cafe, 5 = Ready
  int _phoneDigits = 0;
  bool _isLoading = false;
  bool _isSendingOtp = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _emailCredentialLinked = false;
  String? _verificationId;
  ConfirmationResult? _webConfirmationResult;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cafeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() => _phoneDigits = _phoneController.text.length);
    });
    _passwordController.addListener(_refresh);
    _confirmPasswordController.addListener(_refresh);
    _emailController.addListener(_refresh);
    _cafeNameController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cafeNameController.dispose();
    super.dispose();
  }

  String get _phoneNumber => '+91${_phoneController.text.trim()}';

  Future<void> _onSendOtp() async {
    if (_phoneDigits != 10 || _isSendingOtp || _isLoading) return;

    setState(() => _isSendingOtp = true);
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
          verificationFailed: (error) {
            if (mounted) setState(() => _isSendingOtp = false);
            _showError(_messageFor(error));
          },
          codeSent: (verificationId, _) {
            if (mounted) {
              setState(() {
                _verificationId = verificationId;
                _step = 2;
                _isSendingOtp = false;
              });
            }
          },
          codeAutoRetrievalTimeout: (verificationId) {
            _verificationId = verificationId;
            if (mounted) setState(() => _isSendingOtp = false);
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _isSendingOtp = false);
      _showError(_messageFor(error));
    } catch (error, stackTrace) {
      if (mounted) setState(() => _isSendingOtp = false);
      debugPrintStack(
        label: 'Phone Auth send OTP error: $error',
        stackTrace: stackTrace,
      );
      _showError('Unexpected error: $error');
    } finally {
      // On native, verifyPhoneNumber returns before Firebase has sent the SMS.
      // Keep the button disabled until codeSent or verificationFailed runs.
      if (mounted && kIsWeb) setState(() => _isSendingOtp = false);
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
      if (mounted) setState(() => _step = 3);
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
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
          _step = 3;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _isSendingOtp = false);
      _showError(_messageFor(error));
    }
  }

  String _messageFor(FirebaseAuthException error) {
    final summary = switch (error.code) {
      'invalid-phone-number' => 'The phone number is invalid.',
      'invalid-verification-code' => 'The verification code is incorrect.',
      'session-expired' => 'The OTP session has expired.',
      'too-many-requests' => 'Firebase is rate-limiting requests.',
      'email-already-in-use' =>
        'This email address is already linked to another account.',
      'credential-already-in-use' =>
        'This email address is already linked to another account.',
      'invalid-email' => 'Enter a valid email address.',
      'weak-password' => 'Choose a stronger password.',
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
        SnackBar(content: Text(message), duration: const Duration(seconds: 12)),
      );
  }

  void _onBack(BuildContext context) {
    if (_step > 1 && _step < 5) {
      setState(() {
        _step -= 1;
        if (_step == 1) {
          _otpController.clear();
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  bool get _hasEightCharacters => _passwordController.text.length >= 8;
  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordController.text);
  bool get _hasSymbol =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(_passwordController.text);
  bool get _passwordIsValid => _hasEightCharacters && _hasNumber && _hasSymbol;
  bool get _passwordsMatch =>
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmPasswordController.text;

  bool get _emailIsValid => RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  ).hasMatch(_emailController.text.trim());

  Future<void> _onPasswordContinue() async {
    final email = _emailController.text.trim();
    if (!_emailIsValid) {
      _showError(
        'Enter a valid email address for password sign-in and recovery.',
      );
      return;
    }
    if (!_passwordIsValid) {
      _showError('Use at least 8 characters, including a number and symbol.');
      return;
    }
    if (!_passwordsMatch) {
      _showError('Your passwords do not match.');
      return;
    }
    if (_emailCredentialLinked) {
      setState(() => _step = 4);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError(
        'Your sign-in session has expired. Please verify your phone again.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await user.linkWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: _passwordController.text,
        ),
      );
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        setState(() {
          _emailCredentialLinked = true;
          _step = 4;
        });
      }
    } on FirebaseAuthException catch (error) {
      _showError(_messageFor(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onFinishSetup() async {
    final cafeName = _cafeNameController.text.trim();
    if (cafeName.isEmpty || _isLoading) {
      if (cafeName.isEmpty) _showError('Enter your cafe or restaurant name.');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError(
        'Your sign-in session has expired. Please verify your phone again.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _writeProfileWithFirestore(
        user,
        cafeName,
      ).timeout(const Duration(seconds: 6));
      if (mounted) {
        setState(() => _step = 5);
      }
    } on TimeoutException {
      try {
        // The Firestore web SDK uses a persistent streaming channel which can
        // be blocked by some networks. Use the authenticated REST API as a
        // fallback so setup is not stranded on that connection.
        await _writeProfileWithRest(
          user,
          cafeName,
        ).timeout(const Duration(seconds: 12));
        if (mounted) {
          setState(() => _step = 5);
        }
      } on TimeoutException {
        _showError(
          'Saving your cafe timed out. Please check your network and try again.',
        );
      } on StateError catch (error) {
        _showError(error.message.toString());
      } on Exception catch (error) {
        debugPrint('Firestore REST fallback failed: $error');
        _showError(
          'Could not save your cafe. Please check your connection and try again.',
        );
      }
    } on FirebaseException catch (error) {
      _showError(
        'Could not finish setup. ${error.message ?? 'Please try again.'}',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _writeProfileWithFirestore(User user, String cafeName) {
    return FirebaseFirestore.instance.collection('user').doc(user.uid).set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber ?? _phoneNumber,
      'email': user.email ?? _emailController.text.trim(),
      'emailVerified': user.emailVerified,
      'cafeName': cafeName,
      'shopCode': 'T001',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _writeProfileWithRest(User user, String cafeName) async {
    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw StateError(
        'Your sign-in session has expired. Please verify your phone again.',
      );
    }

    final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
    final documentName =
        'projects/$projectId/databases/(default)/documents/user/${user.uid}';
    final response = await http.post(
      Uri.https(
        'firestore.googleapis.com',
        '/v1/projects/$projectId/databases/(default)/documents:commit',
      ),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'writes': [
          {
            'update': {
              'name': documentName,
              'fields': {
                'uid': {'stringValue': user.uid},
                'phoneNumber': {
                  'stringValue': user.phoneNumber ?? _phoneNumber,
                },
                'email': {
                  'stringValue': user.email ?? _emailController.text.trim(),
                },
                'emailVerified': {'booleanValue': user.emailVerified},
                'cafeName': {'stringValue': cafeName},
                'shopCode': {'stringValue': 'T001'},
              },
            },
            'updateTransforms': [
              {'fieldPath': 'createdAt', 'setToServerValue': 'REQUEST_TIME'},
            ],
          },
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        'Firestore REST write failed: ${response.statusCode} ${response.body}',
      );
      throw StateError(
        'Could not save your cafe (${response.statusCode}). Please try again.',
      );
    }
  }

  String get _actionLabel => switch (_step) {
    1 => _isSendingOtp ? 'Sending OTP...' : 'Send OTP',
    2 => _isLoading ? 'Verifying...' : 'Verify',
    3 => _isLoading ? 'Securing account...' : 'Continue',
    4 => _isLoading ? 'Finishing setup...' : 'Finish Setup',
    _ => 'Go to Orders',
  };

  bool get _actionEnabled => switch (_step) {
    1 => !_isSendingOtp && !_isLoading && _phoneDigits == 10,
    2 => !_isLoading,
    3 => !_isLoading && _emailIsValid && _passwordIsValid && _passwordsMatch,
    4 => !_isLoading && _cafeNameController.text.trim().isNotEmpty,
    _ => true,
  };

  VoidCallback get _onAction => switch (_step) {
    1 => _onSendOtp,
    2 => _onVerify,
    3 => _onPasswordContinue,
    4 => _onFinishSetup,
    _ => () {},
  };

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
    if (_step == 5) {
      return _SetupCompleteScreen(cafeName: _cafeNameController.text.trim());
    }
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
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  cafeNameController: _cafeNameController,
                  passwordVisible: _passwordVisible,
                  confirmPasswordVisible: _confirmPasswordVisible,
                  hasEightCharacters: _hasEightCharacters,
                  hasNumber: _hasNumber,
                  hasSymbol: _hasSymbol,
                  onTogglePassword: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  onToggleConfirmPassword: () => setState(
                    () => _confirmPasswordVisible = !_confirmPasswordVisible,
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: _actionLabel,
                  isLight: false,
                  enabled: _actionEnabled,
                  onTap: _onAction,
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
    if (_step == 5) {
      return _SetupCompleteScreen(cafeName: _cafeNameController.text.trim());
    }
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
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                cafeNameController: _cafeNameController,
                passwordVisible: _passwordVisible,
                confirmPasswordVisible: _confirmPasswordVisible,
                hasEightCharacters: _hasEightCharacters,
                hasNumber: _hasNumber,
                hasSymbol: _hasSymbol,
                onTogglePassword: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
                onToggleConfirmPassword: () => setState(
                  () => _confirmPasswordVisible = !_confirmPasswordVisible,
                ),
              ),
            ),
          ),
          // Action button pinned at bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
            child: PrimaryButton(
              label: _actionLabel,
              isLight: false,
              enabled: _actionEnabled,
              onTap: _onAction,
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
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.cafeNameController,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.hasEightCharacters,
    required this.hasNumber,
    required this.hasSymbol,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  final int step;
  final TextEditingController phoneController;
  final TextEditingController otpController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController cafeNameController;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final bool hasEightCharacters;
  final bool hasNumber;
  final bool hasSymbol;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          step == 3
              ? 'Secure your account.'
              : step == 4
              ? 'Name your cafe.'
              : 'Create account.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step == 3
              ? 'Use your email and password to sign in without an SMS.'
              : step == 4
              ? 'This will be shown to your team and customers.'
              : 'Let\'s get your cafe set up.',
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
          child: switch (step) {
            1 => _PhoneStep(
              key: const ValueKey(1),
              controller: phoneController,
            ),
            2 => _VerifyStep(key: const ValueKey(2), controller: otpController),
            3 => _PasswordStep(
              key: const ValueKey(3),
              emailController: emailController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              passwordVisible: passwordVisible,
              confirmPasswordVisible: confirmPasswordVisible,
              hasEightCharacters: hasEightCharacters,
              hasNumber: hasNumber,
              hasSymbol: hasSymbol,
              onTogglePassword: onTogglePassword,
              onToggleConfirmPassword: onToggleConfirmPassword,
            ),
            _ => _CafeNameStep(
              key: const ValueKey(4),
              controller: cafeNameController,
            ),
          },
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StepDot(number: 1, label: 'Phone', currentStep: currentStep),
          const _StepConnector(),
          _StepDot(number: 2, label: 'Verify', currentStep: currentStep),
          const _StepConnector(),
          _StepDot(number: 3, label: 'Account', currentStep: currentStep),
          const _StepConnector(),
          _StepDot(number: 4, label: 'Cafe', currentStep: currentStep),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFF2A2A2A),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    required this.currentStep,
  });
  final int number;
  final String label;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final isComplete = currentStep > number;
    final isActive = currentStep == number;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete
                ? AppColors.gold
                : (isActive ? AppColors.loginButton : const Color(0xFF222222)),
            border: Border.all(
              color: isComplete || isActive
                  ? Colors.transparent
                  : const Color(0xFF2A2A2A),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isComplete
              ? const Icon(
                  Icons.check_rounded,
                  color: AppColors.background,
                  size: 17,
                )
              : Text(
                  '$number',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.background
                        : const Color(0xFF777777),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isComplete || isActive
                ? AppColors.white
                : const Color(0xFF777777),
            fontSize: 13,
            fontWeight: isComplete || isActive
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.hasEightCharacters,
    required this.hasNumber,
    required this.hasSymbol,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  final TextEditingController passwordController;
  final TextEditingController emailController;
  final TextEditingController confirmPasswordController;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final bool hasEightCharacters;
  final bool hasNumber;
  final bool hasSymbol;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(text: 'EMAIL ADDRESS'),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          decoration: _inputDecoration(hint: 'you@example.com'),
        ),
        const SizedBox(height: 20),
        const _FieldLabel(text: 'PASSWORD'),
        const SizedBox(height: 8),
        _PasswordField(
          controller: passwordController,
          visible: passwordVisible,
          hint: 'Min. 8 characters',
          onToggle: onTogglePassword,
        ),
        const SizedBox(height: 20),
        const _FieldLabel(text: 'CONFIRM PASSWORD'),
        const SizedBox(height: 8),
        _PasswordField(
          controller: confirmPasswordController,
          visible: confirmPasswordVisible,
          hint: 'Re-enter password',
          onToggle: onToggleConfirmPassword,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _PasswordRequirement(label: '8+ chars', met: hasEightCharacters),
            _PasswordRequirement(label: 'Number', met: hasNumber),
            _PasswordRequirement(label: 'Symbol', met: hasSymbol),
          ],
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.visible,
    required this.hint,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool visible;
  final String hint;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      enableSuggestions: false,
      autocorrect: false,
      style: const TextStyle(color: AppColors.white, fontSize: 15),
      decoration: _inputDecoration(
        hint: hint,
        suffix: TextButton(
          onPressed: onToggle,
          child: Text(
            visible ? 'Hide' : 'Show',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  const _PasswordRequirement({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? const Color(0xFF20D67A) : const Color(0xFF555555);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class _CafeNameStep extends StatelessWidget {
  const _CafeNameStep({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(text: 'CAFE / RESTAURANT NAME'),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: AppColors.white, fontSize: 15),
          decoration: _inputDecoration(hint: 'e.g. The Brew House'),
        ),
        const SizedBox(height: 16),
        const Text(
          'This name will appear on your orders, QR codes and staff app.',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SetupCompleteScreen extends StatelessWidget {
  const _SetupCompleteScreen({required this.cafeName});

  final String cafeName;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 800;
    final content = _CompletionContent(cafeName: cafeName);
    return SafeArea(
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 64,
                      vertical: 48,
                    ),
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
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, color: const Color(0xFF2A2A2A)),
                SizedBox(
                  width: 580,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 452),
                      child: content,
                    ),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(28, 42, 28, 32),
              child: content,
            ),
    );
  }
}

class _CompletionContent extends StatelessWidget {
  const _CompletionContent({required this.cafeName});

  final String cafeName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: const Color(0xFF173425),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF20D67A),
            size: 36,
          ),
        ),
        const SizedBox(height: 34),
        Text(
          'Welcome,',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          '$cafeName!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.gold,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your account is ready. We sent a verification link to your email—open it to confirm your recovery address.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 30),
        const _TaskCard(
          icon: Icons.format_list_bulleted_rounded,
          title: 'Add your menu',
          subtitle: 'Add items with prices, photos and categories',
        ),
        const SizedBox(height: 12),
        const _TaskCard(
          icon: Icons.grid_view_rounded,
          title: 'Set up inventory',
          subtitle: 'Add raw materials, set stock limits and alerts',
        ),
        const SizedBox(height: 12),
        const _TaskCard(
          icon: Icons.person_add_alt_1_rounded,
          title: 'Add your team',
          subtitle: 'Invite staff, assign roles and set permissions',
        ),
        const SizedBox(height: 34),
        PrimaryButton(label: 'Go to Orders', isLight: true, onTap: () {}),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF292929),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.gold, size: 25),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2B2B2B), width: 2),
            ),
          ),
        ],
      ),
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
