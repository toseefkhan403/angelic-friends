import 'package:brutalist_ui/brutalist_ui.dart' show NeoTheme;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/analytics/analytics_service.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/di/app_dependencies.dart';
import 'package:sponsor_a_dog/core/navigation/home_shell_page.dart';
import 'package:sponsor_a_dog/core/theme/app_neo_theme.dart';
import 'package:sponsor_a_dog/core/theme/app_theme.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/pages/onboarding_intro_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SponsorADogApp extends StatelessWidget {
  const SponsorADogApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AnalyticsService>.value(value: dependencies.analytics),
        RepositoryProvider<SupabaseClient>.value(value: dependencies.supabaseClient),
        RepositoryProvider<AuthRepository>.value(value: dependencies.authRepository),
        RepositoryProvider<OnboardingRepository>.value(
          value: dependencies.onboardingRepository,
        ),
        RepositoryProvider<DogRepository>.value(value: dependencies.dogRepository),
      ],
      child: MaterialApp(
        title: 'Angelic Friends',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        builder: (context, child) =>
            NeoTheme(data: AppNeoTheme.data, child: child ?? const SizedBox.shrink()),
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    return StreamBuilder<bool>(
      initialData: authRepository.isSignedIn,
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const HomeShellPage() : const OnboardingIntroPage();
      },
    );
  }
}
