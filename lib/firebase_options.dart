import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase settings for platforms configured in this project.
///
/// Run `flutterfire configure` when adding another Firebase platform (such as
/// iOS) to regenerate this file and the corresponding native configuration.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase has not been configured for this platform. '
          'Run `flutterfire configure` to add it.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASbfCgzknKxtu4QaJSMlej1-Xt8JrhFE8',
    appId: '1:986531542522:web:cafeman-3edff',
    messagingSenderId: '986531542522',
    projectId: 'cafeman-3edff',
    authDomain: 'cafeman-3edff.firebaseapp.com',
    storageBucket: 'cafeman-3edff.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASbfCgzknKxtu4QaJSMlej1-Xt8JrhFE8',
    appId: '1:986531542522:android:13c36a211052b3a6f8a043',
    messagingSenderId: '986531542522',
    projectId: 'cafeman-3edff',
    storageBucket: 'cafeman-3edff.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAnbLVjUTWSZcOaE9fsQfTgBjmjcQjapP4',
    appId: '1:986531542522:ios:e96a1687afc42194f8a043',
    messagingSenderId: '986531542522',
    projectId: 'cafeman-3edff',
    storageBucket: 'cafeman-3edff.firebasestorage.app',
    iosBundleId: 'com.example.cafeManagement',
  );
}
