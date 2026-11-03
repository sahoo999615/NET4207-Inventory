import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Configure with the lecturer-provided Firebase project credentials.
class DefaultFirebaseOptions {
  static const String projectId = 'net4207-stock-inventory';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoLabKeyWeb1234567890abcdef',
    appId: '1:100000000000:web:1234567890abcdef123456',
    messagingSenderId: '100000000000',
    projectId: projectId,
    authDomain: '$projectId.firebaseapp.com',
    storageBucket: '$projectId.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoLabKeyAndroid1234567890abcdef',
    appId: '1:100000000000:android:1234567890abcdef123456',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoLabKeyIos1234567890abcdef',
    appId: '1:100000000000:ios:1234567890abcdef123456',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
    iosBundleId: 'com.stockinventory.stockInventoryApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoLabKeyMacos1234567890abcdef',
    appId: '1:100000000000:ios:1234567890abcdef123456',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
    iosBundleId: 'com.stockinventory.stockInventoryApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoLabKeyWindows1234567890abcdef',
    appId: '1:100000000000:windows:1234567890abcdef123456',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
  );
}
