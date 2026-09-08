// Config real do projeto `ascend-ff71d`, copiada do console do Firebase
// (Configurações do projeto → Geral → Seus apps → app Web "ascend").
//
// Só o app Web foi registrado até agora — Android e iOS reaproveitam os
// mesmos valores por enquanto (funciona para login por e-mail/senha e
// Firestore, que é tudo que o app usa hoje). Antes de gerar um build
// nativo de verdade para a loja, registre um app Android/iOS próprio no
// console e rode `flutterfire configure` para gerar os arquivos nativos
// (google-services.json / GoogleService-Info.plist) — passo a passo no
// README.md.

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
    apiKey: 'AIzaSyCGeDzazNhRZ9OOckzbLjYxzZL6FGkI6hk',
    appId: '1:22520088791:web:2ebab1e607e9e7be924892',
    messagingSenderId: '22520088791',
    projectId: 'ascend-ff71d',
    authDomain: 'ascend-ff71d.firebaseapp.com',
    storageBucket: 'ascend-ff71d.firebasestorage.app',
    measurementId: 'G-NMNHTZQ11Y',
  );

  // Reaproveita o app Web até você registrar um app Android próprio no
  // console (Configurações do projeto → Seus apps → ícone Android).
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGeDzazNhRZ9OOckzbLjYxzZL6FGkI6hk',
    appId: '1:22520088791:web:2ebab1e607e9e7be924892',
    messagingSenderId: '22520088791',
    projectId: 'ascend-ff71d',
    storageBucket: 'ascend-ff71d.firebasestorage.app',
  );

  // Idem — reaproveita o app Web até você registrar um app iOS próprio.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGeDzazNhRZ9OOckzbLjYxzZL6FGkI6hk',
    appId: '1:22520088791:web:2ebab1e607e9e7be924892',
    messagingSenderId: '22520088791',
    projectId: 'ascend-ff71d',
    storageBucket: 'ascend-ff71d.firebasestorage.app',
    iosBundleId: 'com.example.ascend',
  );
}
