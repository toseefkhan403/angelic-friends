import 'dart:async';

import 'package:brutalist_ui/brutalist_ui.dart' show NeoTheme;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/analytics/analytics_service.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/di/app_dependencies.dart';
import 'package:sponsor_a_dog/core/navigation/home_shell_page.dart';
import 'package:sponsor_a_dog/core/purchases/purchases_service.dart';
import 'package:sponsor_a_dog/core/theme/app_neo_theme.dart';
import 'package:sponsor_a_dog/core/theme/app_theme.dart';
import 'package:sponsor_a_dog/features/admin/domain/repositories/admin_repository.dart';
import 'package:sponsor_a_dog/features/angel/domain/repositories/angel_repository.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/pages/onboarding_intro_page.dart';
import 'package:sponsor_a_dog/features/sponsors/domain/repositories/sponsorship_repository.dart';
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
        RepositoryProvider<PurchasesService>.value(value: dependencies.purchasesService),
        RepositoryProvider<SponsorshipRepository>.value(
          value: dependencies.sponsorshipRepository,
        ),
        RepositoryProvider<AngelRepository>.value(value: dependencies.angelRepository),
        RepositoryProvider<AdminRepository>.value(value: dependencies.adminRepository),
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

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  StreamSubscription<bool>? _authSubscription;

  @override
  void initState() {
    super.initState();
    final authRepository = context.read<AuthRepository>();
    final purchasesService = context.read<PurchasesService>();
    // `createAppDependencies()` already identifies RevenueCat with whoever
    // was signed in at cold-start; this covers every sign-in/out that
    // happens *during* this app session (e.g. onboarding), which the
    // one-shot startup call can't see. Without it, purchases stay attributed
    // to RevenueCat's anonymous id and `revenuecat-webhook` has no real
    // Supabase user id to grant credits against.
    _authSubscription = authRepository.authStateChanges.listen((isSignedIn) {
      final userId = authRepository.currentUserId;
      if (isSignedIn && userId != null) {
        purchasesService.logIn(userId);
      } else {
        purchasesService.logOut();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    return StreamBuilder<bool>(
      initialData: authRepository.isSignedIn,
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
        }
        return snapshot.data! ? const HomeShellPage() : const OnboardingIntroPage();
      },
    );
  }
}
