// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA04xajxsIe3Iykwbb_SgdyftbbHxcyu2g',
    appId: '1:415743077340:web:4bc4e7965b9a4b6575bd19',
    messagingSenderId: '415743077340',
    projectId: 'tailmate-8c9d0',
    authDomain: 'tailmate-8c9d0.firebaseapp.com',
    storageBucket: 'tailmate-8c9d0.firebasestorage.app',
    measurementId: 'G-8DCEXCBRHV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDG-z336VAGYvLOtGvH_R7v0jLQQuCaV6g',
    appId: '1:415743077340:android:71f4051cade490d075bd19',
    messagingSenderId: '415743077340',
    projectId: 'tailmate-8c9d0',
    storageBucket: 'tailmate-8c9d0.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA04xajxsIe3Iykwbb_SgdyftbbHxcyu2g',
    appId: '1:415743077340:web:57a4c1fa3ee355bd75bd19',
    messagingSenderId: '415743077340',
    projectId: 'tailmate-8c9d0',
    authDomain: 'tailmate-8c9d0.firebaseapp.com',
    storageBucket: 'tailmate-8c9d0.firebasestorage.app',
    measurementId: 'G-SQR73LVMFY',
  );
}
