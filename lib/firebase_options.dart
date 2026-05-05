import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```
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
        return macos;
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
    apiKey: 'AIzaSyAzeym5I1DdH3wz_TKELLJAaBZOpkP_EwA',
    appId: '1:650379673071:web:fc3e9e1175ad7040f6ca1a',
    messagingSenderId: '650379673071',
    projectId: 'qaztender-2ef18',
    authDomain: 'qaztender-2ef18.firebaseapp.com',
    storageBucket: 'qaztender-2ef18.firebasestorage.app',
    measurementId: 'G-PJG8ZX0ZRS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBu6vVBwuaTTPsoDaqul4E9e4f3xuBqm2g',
    appId: '1:650379673071:android:b93308f8248e31f7f6ca1a',
    messagingSenderId: '650379673071',
    projectId: 'qaztender-2ef18',
    storageBucket: 'qaztender-2ef18.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBM9kcC89ZaaYPIAxYpVKWfN0uphInRWI',
    appId: '1:650379673071:ios:acab054ada64097af6ca1a',
    messagingSenderId: '650379673071',
    projectId: 'qaztender-2ef18',
    storageBucket: 'qaztender-2ef18.firebasestorage.app',
    iosBundleId: 'com.example.mvptender',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBM9kcC89ZaaYPIAxYpVKWfN0uphInRWI',
    appId: '1:650379673071:ios:acab054ada64097af6ca1a',
    messagingSenderId: '650379673071',
    projectId: 'qaztender-2ef18',
    storageBucket: 'qaztender-2ef18.firebasestorage.app',
    iosBundleId: 'com.example.mvptender',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAzeym5I1DdH3wz_TKELLJAaBZOpkP_EwA',
    appId: '1:650379673071:web:18c418b1acf98303f6ca1a',
    messagingSenderId: '650379673071',
    projectId: 'qaztender-2ef18',
    authDomain: 'qaztender-2ef18.firebaseapp.com',
    storageBucket: 'qaztender-2ef18.firebasestorage.app',
    measurementId: 'G-J8MLNDE44Z',
  );

}