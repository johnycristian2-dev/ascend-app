import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'backend/config/firebase_options.dart';
import 'frontend/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    initError = e;
  }
  runApp(initError == null ? const AscendApp() : FirebaseSetupError(error: initError));
}
