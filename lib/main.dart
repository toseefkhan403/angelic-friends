import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sponsor_a_dog/app.dart';
import 'package:sponsor_a_dog/core/config/supabase_config.dart';
import 'package:sponsor_a_dog/core/di/app_dependencies.dart';
import 'package:sponsor_a_dog/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Only report crashes from release/profile builds so local debug runs
    // (hot reload exceptions, dev-only errors) don't pollute the Crashlytics
    // console.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Catch Flutter framework errors (widget build/layout/paint errors, etc).
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Catch uncaught async/platform errors that fall outside the Flutter
    // framework's own error zone (e.g. errors thrown in microtasks/isolates).
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  final dependencies = await createAppDependencies();
  runApp(SponsorADogApp(dependencies: dependencies));
}
