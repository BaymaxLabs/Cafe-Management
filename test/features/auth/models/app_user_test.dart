// Spec: AppUser model
//
// AppUser is a pure Dart data class representing a signed-in user.
// It must be serialisable to/from a Firestore document map.
//
// TODO: Restore import and remove skip once AppUser is built at
//       lib/features/auth/models/app_user.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUser', () {
    test('holds all fields', () {}, skip: 'AppUser not yet built');
    test('fromMap constructs correctly', () {}, skip: 'AppUser not yet built');
    test('fromMap uses empty string defaults for missing optional fields', () {}, skip: 'AppUser not yet built');
    test('toMap produces correct map without password field', () {}, skip: 'AppUser not yet built');
    test('copyWith replaces only specified fields', () {}, skip: 'AppUser not yet built');
    test('equality — two users with same uid are equal', () {}, skip: 'AppUser not yet built');
    test('equality — different uid means not equal', () {}, skip: 'AppUser not yet built');
  });
}
