// Synced with android/app/google-services.json (project cassava-1fae6).
// For Google Sign-In on Android: Firebase Console → Project settings → Your apps
// → add SHA-1 (and SHA-256) for this package, then re-download google-services.json
// so "oauth_client" is not empty.
// For iOS: add an iOS app in Firebase, download GoogleService-Info.plist, then run:
//   flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not configured.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1_LYp0bCqTbZWkEgwUmCp_cAGzixrl0I',
    appId: '1:85251160050:web:ffffffffffffffffffffffff',
    messagingSenderId: '85251160050',
    projectId: 'cassava-1fae6',
    authDomain: 'cassava-1fae6.firebaseapp.com',
    storageBucket: 'cassava-1fae6.firebasestorage.app',
  );

  /// Matches google-services.json (mobilesdk_app_id, api_key, project_info).
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1_LYp0bCqTbZWkEgwUmCp_cAGzixrl0I',
    appId: '1:85251160050:android:9b23809695829ad0b5dd6b',
    messagingSenderId: '85251160050',
    projectId: 'cassava-1fae6',
    storageBucket: 'cassava-1fae6.firebasestorage.app',
  );

  /// Same Firebase project as Android. Replace appId (and iosClientId) after you
  /// register the iOS app and run flutterfire configure, or paste from plist.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1_LYp0bCqTbZWkEgwUmCp_cAGzixrl0I',
    appId: '1:85251160050:ios:ffffffffffffffffffffffff',
    messagingSenderId: '85251160050',
    projectId: 'cassava-1fae6',
    storageBucket: 'cassava-1fae6.firebasestorage.app',
    iosBundleId: 'com.cassavaguard.cassavaGuard',
  );
}
