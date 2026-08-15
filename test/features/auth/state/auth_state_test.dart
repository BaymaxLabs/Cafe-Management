// Spec: AuthState
//
// AuthState is a ChangeNotifier that wraps AuthService and drives all
// auth-related UI state: loading, current user, and error messages.
//
// TODO: Restore imports and remove skip once AuthState is built at
//       lib/features/auth/state/auth_state.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('initial state', () {
    test('currentUser is null', () {}, skip: 'AuthState not yet built');
    test('isLoading is false', () {}, skip: 'AuthState not yet built');
    test('error is null', () {}, skip: 'AuthState not yet built');
    test('isAuthenticated is false', () {}, skip: 'AuthState not yet built');
  });

  group('login', () {
    test('sets currentUser and clears error on success', () {}, skip: 'AuthState not yet built');
    test('sets error and keeps currentUser null on failure', () {}, skip: 'AuthState not yet built');
    test('isLoading is true during login then false after', () {}, skip: 'AuthState not yet built');
    test('notifies listeners on success', () {}, skip: 'AuthState not yet built');
  });

  group('register', () {
    test('sets currentUser on success', () {}, skip: 'AuthState not yet built');
    test('sets error on failure', () {}, skip: 'AuthState not yet built');
  });

  group('logout', () {
    test('clears currentUser and resets state', () {}, skip: 'AuthState not yet built');
  });

  group('clearError', () {
    test('clears error and notifies listeners', () {}, skip: 'AuthState not yet built');
  });
}
