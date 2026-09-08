// Config real do projeto `ascend-1d51e`, baixada com `firebase apps:sdkconfig`
// (Configurações do projeto → Geral → Seus apps, no console do Firebase).
//
// A versão anterior deste arquivo apontava para um projeto diferente
// (`ascend-ff71d`) que não tem o Cloud Firestore habilitado — Auth
// funcionava (criava a conta), mas qualquer leitura/escrita no caderno
// falhava com "Não foi possível entrar. Tente de novo.", porque o erro
// do Firestore não é um FirebaseAuthException e cai no fallback genérico
// de AuthService.friendlyMessage. `ascend-1d51e` é o projeto que consta
// em `.firebaserc` e já tem Firestore (Native) criado e os apps Web,
// Android e iOS registrados de verdade — por isso os três blocos abaixo
// têm valores próprios, em vez de reaproveitar o app Web.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não configurado para esta plataforma. '
          'Rode `flutterfire configure` para gerar as opções corretas.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA5a5WcoptV1TLz48pBQVdiNDC18umW5e8',
    appId: '1:109142925517:web:e5a8f64ad0f42aa470c984',
    messagingSenderId: '109142925517',
    projectId: 'ascend-1d51e',
    authDomain: 'ascend-1d51e.firebaseapp.com',
    databaseURL: 'https://ascend-1d51e-default-rtdb.firebaseio.com',
    storageBucket: 'ascend-1d51e.firebasestorage.app',
    measurementId: 'G-V6SCTK3PL0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8BX4gVL7_T9cPYZms3aTMiO6W4TKXSvQ',
    appId: '1:109142925517:android:ed77a8e44c9eca9c70c984',
    messagingSenderId: '109142925517',
    projectId: 'ascend-1d51e',
    databaseURL: 'https://ascend-1d51e-default-rtdb.firebaseio.com',
    storageBucket: 'ascend-1d51e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD019VCR0-sTmM7332k-tEvcNP6B8un_A8',
    appId: '1:109142925517:ios:41a3c50e5e410fc870c984',
    messagingSenderId: '109142925517',
    projectId: 'ascend-1d51e',
    databaseURL: 'https://ascend-1d51e-default-rtdb.firebaseio.com',
    storageBucket: 'ascend-1d51e.firebasestorage.app',
    iosBundleId: 'br.com.ascend.ascend',
  );
}
