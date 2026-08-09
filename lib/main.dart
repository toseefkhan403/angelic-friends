import 'package:firebase_core/firebase_core.dart';
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
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  final dependencies = await createAppDependencies();
  runApp(SponsorADogApp(dependencies: dependencies));
}
