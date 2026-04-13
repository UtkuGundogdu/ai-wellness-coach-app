import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/di/app_scope.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? firebaseSetupError;

  try {
    if (kIsWeb) {
      firebaseSetupError =
          'Firebase web options are missing. Run flutterfire configure and initialize Firebase with DefaultFirebaseOptions.currentPlatform.';
    } else {
      await Firebase.initializeApp();
    }
  } on FirebaseException catch (error) {
    firebaseSetupError = error.message ?? error.toString();
  } catch (error) {
    firebaseSetupError = error.toString();
  }

  final scope = await AppScope.create(
    firebaseSetupError: firebaseSetupError,
  );

  runApp(WellnessCoachApp(scope: scope));
}
