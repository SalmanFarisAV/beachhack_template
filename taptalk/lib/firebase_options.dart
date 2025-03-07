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
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD9OGXl1caC-WDxL_Hw67Twdt6L23f26qE',
    appId: '1:1028551103947:web:643dee8bdf1b3c39fbd24e',
    messagingSenderId: '1028551103947',
    projectId: 'taptalk-32542',
    authDomain: 'taptalk-32542.firebaseapp.com',
    storageBucket: 'taptalk-32542.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChHrCD3TChDgfe56wbuYCgeGgjukLwYCk',
    appId: '1:1028551103947:android:b11bc536d924486dfbd24e',
    messagingSenderId: '1028551103947',
    projectId: 'taptalk-32542',
    storageBucket: 'taptalk-32542.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASGleiT2a0isBLPqMJZvbYE3-l7Q3VsTU',
    appId: '1:1028551103947:ios:708c2c2b91cd454efbd24e',
    messagingSenderId: '1028551103947',
    projectId: 'taptalk-32542',
    storageBucket: 'taptalk-32542.firebasestorage.app',
    iosBundleId: 'com.example.taptalk',
  );
}
