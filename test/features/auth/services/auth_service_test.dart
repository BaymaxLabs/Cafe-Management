// Spec: AuthService
//
// AuthService is the single point of contact for all Firebase Auth and
// Firestore operations. Screens and state must never call Firebase directly.
//
// TODO: Restore imports and remove skip once AuthService is built at
//       lib/features/auth/services/auth_service.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService.login', () {
    test('returns AppUser on success', () {}, skip: 'AuthService not yet built');
    test('sets currentUser after successful login', () {}, skip: 'AuthService not yet built');
    test('throws AuthException on bad credentials', () {}, skip: 'AuthService not yet built');
  });

  group('AuthService.register', () {
    test('returns AppUser on success', () {}, skip: 'AuthService not yet built');
    test('throws AuthException on failure', () {}, skip: 'AuthService not yet built');
  });

  group('AuthService.logout', () {
    test('clears currentUser', () {}, skip: 'AuthService not yet built');
  });
}
