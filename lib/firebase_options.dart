// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
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
    apiKey: 'AIzaSyDEYt1wxzTf1o6jN-jPJIEOabyXEr7pX1M',
    appId: '1:749797511925:web:12630a190576d1bf3d2bbc',
    messagingSenderId: '749797511925',
    projectId: 'chess-gpt4',
    authDomain: 'chess-gpt4.firebaseapp.com',
    databaseURL: 'https://chess-gpt4-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chess-gpt4.appspot.com',
    measurementId: 'G-SCWHC5GSJZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDxV8i2LpUpnxu4-4tVcpssxio5eR_wA7k',
    appId: '1:749797511925:android:6f333aaf7c512cd23d2bbc',
    messagingSenderId: '749797511925',
    projectId: 'chess-gpt4',
    databaseURL: 'https://chess-gpt4-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chess-gpt4.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkmonu4K5rx2bA-gAWq4oGaJ4g1sf4MRo',
    appId: '1:749797511925:ios:617b77398de99c7c3d2bbc',
    messagingSenderId: '749797511925',
    projectId: 'chess-gpt4',
    databaseURL: 'https://chess-gpt4-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chess-gpt4.appspot.com',
    iosClientId: '749797511925-6jsugr6ch5eu1fd8q2h74fan4vd5p7rq.apps.googleusercontent.com',
    iosBundleId: 'com.example.ajedrez',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAkmonu4K5rx2bA-gAWq4oGaJ4g1sf4MRo',
    appId: '1:749797511925:ios:617b77398de99c7c3d2bbc',
    messagingSenderId: '749797511925',
    projectId: 'chess-gpt4',
    databaseURL: 'https://chess-gpt4-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chess-gpt4.appspot.com',
    iosClientId: '749797511925-6jsugr6ch5eu1fd8q2h74fan4vd5p7rq.apps.googleusercontent.com',
    iosBundleId: 'com.example.ajedrez',
  );
}
