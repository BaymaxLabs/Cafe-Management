import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/brew_logo.dart';
import '../widgets/primary_button.dart';

enum _LoginMethod { password, phoneOtp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _LoginMethod _method = _LoginMethod.password;
  bool _loading = false;
  bool _otpSent = false;
  String? _verificationId;
  ConfirmationResult? _webConfirmation;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _shopCode = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _otp.dispose();
    _shopCode.dispose();
    super.dispose();
  }

  String get _phoneNumber => '+91${_phone.text.trim()}';
  bool get _validEmail =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim());

  void _changeMethod(_LoginMethod value) {
    if (_loading) return;
    setState(() {
      _method = value;
      _otpSent = false;
      _otp.clear();
      _verificationId = null;
      _webConfirmation = null;
    });
  }

  Future<void> _submitPassword() async {
    if (!_validEmail) {
      return _error('Enter the email address you used when registering.');
    }
    if (_password.text.isEmpty) return _error('Enter your password.');
    setState(() => _loading = true);
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      await _finishLogin(result.user!);
    } on FirebaseAuthException catch (e) {
      _error(_message(e));
    } on TimeoutException {
      _error('Login took too long. Please check your connection and retry.');
    } on StateError catch (e) {
      _error(e.message.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendOtp() async {
    if (!RegExp(r'^\d{10}$').hasMatch(_phone.text.trim())) {
      return _error('Enter a valid 10-digit phone number.');
    }
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (kIsWeb) {
        _webConfirmation = await FirebaseAuth.instance.signInWithPhoneNumber(
          _phoneNumber,
        );
        if (mounted) setState(() => _otpSent = true);
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _phoneNumber,
          verificationCompleted: _nativeVerified,
          verificationFailed: (e) {
            if (mounted) setState(() => _loading = false);
            _error(_message(e));
          },
          codeSent: (id, _) {
            if (mounted) {
              setState(() {
                _verificationId = id;
                _otpSent = true;
                _loading = false;
              });
            }
          },
          codeAutoRetrievalTimeout: (id) {
            _verificationId = id;
            if (mounted) setState(() => _loading = false);
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      _error(_message(e));
    } finally {
      if (mounted && kIsWeb) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.text.trim().length != 6) {
      return _error('Enter the 6-digit code sent to your phone.');
    }
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final UserCredential result;
      if (kIsWeb) {
        if (_webConfirmation == null) {
          throw StateError('Please request a new OTP.');
        }
        result = await _webConfirmation!.confirm(_otp.text.trim());
      } else {
        if (_verificationId == null) {
          throw StateError('Please request a new OTP.');
        }
        result = await FirebaseAuth.instance.signInWithCredential(
          PhoneAuthProvider.credential(
            verificationId: _verificationId!,
            smsCode: _otp.text.trim(),
          ),
        );
      }
      await _finishLogin(result.user!);
    } on FirebaseAuthException catch (e) {
      _error(_message(e));
    } on StateError catch (e) {
      _error(e.message.toString());
    } on TimeoutException {
      _error('Login took too long. Please check your connection and retry.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _nativeVerified(PhoneAuthCredential credential) async {
    try {
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      await _finishLogin(result.user!);
    } on FirebaseAuthException catch (e) {
      _error(_message(e));
    } on StateError catch (e) {
      _error(e.message.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finishLogin(User user) async {
    final profile = await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 12));
    if (!profile.exists) {
      await FirebaseAuth.instance.signOut();
      throw StateError(
        'Your account setup is incomplete. Please register again.',
      );
    }
    if (!mounted) return;
    final userDetails = Map<String, dynamic>.from(profile.data()!);
    final enteredShopCode = _shopCode.text.trim();
    if (enteredShopCode.isNotEmpty) {
      userDetails['shopCode'] = enteredShopCode;
    }
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.dashboard,
      arguments: userDetails,
    );
  }

  Future<void> _resetPassword() async {
    final controller = TextEditingController(text: _email.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        title: const Text(
          'Reset password',
          style: TextStyle(color: AppColors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.white),
          decoration: _decoration('you@example.com'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text(
              'Send reset link',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || email.isEmpty) return;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return _error('Enter a valid email address.');
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'If an account exists, a password reset link has been sent.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _error(_message(e));
    }
  }

  String _message(FirebaseAuthException e) => switch (e.code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'The email or password is incorrect.',
    'invalid-email' => 'Enter a valid email address.',
    'invalid-phone-number' => 'The phone number is invalid.',
    'invalid-verification-code' => 'The verification code is incorrect.',
    'session-expired' => 'The OTP session expired. Request a new code.',
    'too-many-requests' =>
      'Too many attempts. Please wait a moment and try again.',
    _ => 'Firebase could not complete this request. Please try again.',
  };
  void _error(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 8)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final submit = _method == _LoginMethod.password
        ? _submitPassword
        : (_otpSent ? _verifyOtp : _sendOtp);
    final label = _loading
        ? 'Please wait...'
        : _method == _LoginMethod.password
        ? 'Sign in'
        : _otpSent
        ? 'Verify & sign in'
        : 'Send OTP';
    final form = _Form(
      method: _method,
      otpSent: _otpSent,
      email: _email,
      password: _password,
      phone: _phone,
      otp: _otp,
      shopCode: _shopCode,
      onMethod: _changeMethod,
      onForgot: _resetPassword,
      onResend: _sendOtp,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (_, box) {
          if (box.maxWidth >= 800) {
            return Row(
              children: [
                const Expanded(child: _Brand()),
                Container(width: 1, color: const Color(0xFF2A2A2A)),
                SizedBox(
                  width: 580,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 64,
                      vertical: 48,
                    ),
                    child: _DesktopContent(
                      form: form,
                      label: label,
                      loading: _loading,
                      submit: submit,
                    ),
                  ),
                ),
              ],
            );
          }
          return SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: IconButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.landing,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2A),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                    child: form,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
                  child: PrimaryButton(
                    label: label,
                    isLight: true,
                    enabled: !_loading,
                    onTap: submit,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrewLogo(),
        const Spacer(),
        Text('Welcome\nback.', style: Theme.of(c).textTheme.displayLarge),
        const SizedBox(height: 16),
        Text(
          'Use your password or a one-time code to manage your cafe.',
          style: Theme.of(c).textTheme.bodyLarge,
        ),
        const Spacer(),
        const Text(
          '© 2025 Brew · Cafe Management',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _DesktopContent extends StatelessWidget {
  const _DesktopContent({
    required this.form,
    required this.label,
    required this.loading,
    required this.submit,
  });
  final Widget form;
  final String label;
  final bool loading;
  final VoidCallback submit;
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(c, AppRoutes.landing),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
            Text('Back', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
      const Spacer(),
      form,
      const SizedBox(height: 32),
      PrimaryButton(
        label: label,
        isLight: true,
        enabled: !loading,
        onTap: submit,
      ),
      const Spacer(),
    ],
  );
}

class _Form extends StatelessWidget {
  const _Form({
    required this.method,
    required this.otpSent,
    required this.email,
    required this.password,
    required this.phone,
    required this.otp,
    required this.shopCode,
    required this.onMethod,
    required this.onForgot,
    required this.onResend,
  });
  final _LoginMethod method;
  final bool otpSent;
  final TextEditingController email, password, phone, otp, shopCode;
  final ValueChanged<_LoginMethod> onMethod;
  final VoidCallback onForgot, onResend;
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Sign in',
        style: Theme.of(c).textTheme.headlineLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Choose the sign-in method that works for you.',
        style: Theme.of(c).textTheme.bodyLarge,
      ),
      const SizedBox(height: 28),
      Row(
        children: [
          _Method(
            label: 'Email & password',
            icon: Icons.lock_outline,
            selected: method == _LoginMethod.password,
            onTap: () => onMethod(_LoginMethod.password),
          ),
          const SizedBox(width: 12),
          _Method(
            label: 'Phone OTP',
            icon: Icons.sms_outlined,
            selected: method == _LoginMethod.phoneOtp,
            onTap: () => onMethod(_LoginMethod.phoneOtp),
          ),
        ],
      ),
      const SizedBox(height: 28),
      if (method == _LoginMethod.password) ...[
        _Label('EMAIL ADDRESS'),
        const SizedBox(height: 8),
        _Text(
          controller: email,
          hint: 'you@example.com',
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _Label('PASSWORD'),
        const SizedBox(height: 8),
        _Password(controller: password),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgot,
            child: const Text(
              'Forgot password?',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ),
      ] else ...[
        _Label('PHONE NUMBER'),
        const SizedBox(height: 8),
        _Phone(controller: phone),
        if (otpSent) ...[
          const SizedBox(height: 16),
          _Label('ONE-TIME PASSWORD'),
          const SizedBox(height: 8),
          _Text(
            controller: otp,
            hint: '6-digit code',
            type: TextInputType.number,
            length: 6,
            digits: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onResend,
              child: const Text(
                'Send a new code',
                style: TextStyle(color: AppColors.gold),
              ),
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'We’ll send a one-time code to this number.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
      ],
      const SizedBox(height: 8),
      _Label('SHOP CODE (OPTIONAL)'),
      const SizedBox(height: 8),
      _Text(
        controller: shopCode,
        hint: 'e.g. BREW001',
        capitalization: TextCapitalization.characters,
      ),
    ],
  );
}

class _Method extends StatelessWidget {
  const _Method({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3A321F) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.gold : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.gold : AppColors.textMuted,
              size: 17,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.white : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext c) => Text(
    text,
    style: const TextStyle(
      color: AppColors.textMuted,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
  );
}

InputDecoration _decoration(String hint, {Widget? suffix}) => InputDecoration(
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
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
  ),
);

class _Text extends StatelessWidget {
  const _Text({
    required this.controller,
    required this.hint,
    this.type,
    this.length,
    this.digits = false,
    this.capitalization,
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType? type;
  final int? length;
  final bool digits;
  final TextCapitalization? capitalization;
  @override
  Widget build(BuildContext c) => TextField(
    controller: controller,
    keyboardType: type,
    maxLength: length,
    textCapitalization: capitalization ?? TextCapitalization.none,
    inputFormatters: digits ? [FilteringTextInputFormatter.digitsOnly] : null,
    style: const TextStyle(color: AppColors.white),
    decoration: _decoration(hint).copyWith(counterText: ''),
  );
}

class _Phone extends StatelessWidget {
  const _Phone({required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext c) => Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('+91', style: TextStyle(color: AppColors.textMuted)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _Text(
          controller: controller,
          hint: '98765 43210',
          type: TextInputType.phone,
          length: 10,
          digits: true,
        ),
      ),
    ],
  );
}

class _Password extends StatefulWidget {
  const _Password({required this.controller});
  final TextEditingController controller;
  @override
  State<_Password> createState() => _PasswordState();
}

class _PasswordState extends State<_Password> {
  bool _obscure = true;
  @override
  Widget build(BuildContext c) => TextField(
    controller: widget.controller,
    obscureText: _obscure,
    enableSuggestions: false,
    autocorrect: false,
    style: const TextStyle(color: AppColors.white),
    decoration: _decoration(
      '••••••••',
      suffix: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textMuted,
        ),
      ),
    ),
  );
}
