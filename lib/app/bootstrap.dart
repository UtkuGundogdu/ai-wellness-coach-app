import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../core/di/app_scope.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseException? firebaseInitializationError;

  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (error) {
    firebaseInitializationError = error;
  } catch (_) {}

  final scope = await AppScope.create(
    firebaseInitializationError: firebaseInitializationError,
  );

  runApp(WellnessCoachApp(scope: scope));
}
