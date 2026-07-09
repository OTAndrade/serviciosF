import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuracion Firebase centralizada para Android, iOS y Web.
/// Generada a partir de google-services.json y GoogleService-Info.plist del proyecto iNeed.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

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
        throw UnsupportedError(
          'DefaultFirebaseOptions no esta configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCDyO2UXQFGonrNwnUBCbjqPuWYNagBtwA',
    appId: '1:1022994478603:web:ineed-flutter-web',
    messagingSenderId: '1022994478603',
    projectId: 'servicios-fc6a6',
    authDomain: 'servicios-fc6a6.firebaseapp.com',
    databaseURL: 'https://servicios-fc6a6.firebaseio.com',
    storageBucket: 'servicios-fc6a6.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKdSkXRV6hlcpd7KVFuYGkhCmzod_OMtc',
    appId: '1:1022994478603:android:164d41e85f8e44411a790e',
    messagingSenderId: '1022994478603',
    projectId: 'servicios-fc6a6',
    databaseURL: 'https://servicios-fc6a6.firebaseio.com',
    storageBucket: 'servicios-fc6a6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDyO2UXQFGonrNwnUBCbjqPuWYNagBtwA',
    appId: '1:1022994478603:ios:5866215a7df112bb1a790e',
    messagingSenderId: '1022994478603',
    projectId: 'servicios-fc6a6',
    databaseURL: 'https://servicios-fc6a6.firebaseio.com',
    storageBucket: 'servicios-fc6a6.appspot.com',
    iosBundleId: 'com.ineedserv.servicios',
  );
}
