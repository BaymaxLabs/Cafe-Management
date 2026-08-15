// Spec: RegisterScreen widget
//
// The register screen is a 4-step wizard: Phone → Verify → Password → Cafe.
// Each step validates before allowing progression.
// It delegates all Firebase calls to AuthState — never calls Firebase directly.
//
// TODO: Restore full test body once AuthState and provider are added
//       (feature/auth-service-and-state branch).

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterScreen — Step 1 (Phone)', () {
    test('shows Create account heading', () {}, skip: 'AuthState not yet built');
    test('shows step indicator with 4 steps', () {}, skip: 'AuthState not yet built');
    test('shows phone number field', () {}, skip: 'AuthState not yet built');
    test('Send OTP button is disabled when phone is empty', () {}, skip: 'AuthState not yet built');
    test('Send OTP button enables when 10 digits entered', () {}, skip: 'AuthState not yet built');
  });

  group('RegisterScreen — Step 3 (Password)', () {
    test('shows Set password heading', () {}, skip: 'AuthState not yet built');
    test('shows password requirements', () {}, skip: 'AuthState not yet built');
    test('Continue is disabled until password requirements met', () {}, skip: 'AuthState not yet built');
  });

  group('RegisterScreen — Step 4 (Cafe)', () {
    test('shows Name your cafe heading', () {}, skip: 'Requires full OTP flow — covered by integration test');
  });
}
