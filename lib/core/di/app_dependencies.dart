import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sponsor_a_dog/core/analytics/analytics_service.dart';
import 'package:sponsor_a_dog/core/analytics/firebase_analytics_service.dart';
import 'package:sponsor_a_dog/core/analytics/noop_analytics_service.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/auth/supabase_auth_repository.dart';
import 'package:sponsor_a_dog/core/network/network_info.dart';
import 'package:sponsor_a_dog/features/dogs/data/datasources/dog_remote_data_source.dart';
import 'package:sponsor_a_dog/features/dogs/data/repositories/dog_repository_impl.dart';
import 'package:sponsor_a_dog/features/dogs/domain/repositories/dog_repository.dart';
import 'package:sponsor_a_dog/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:sponsor_a_dog/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Hand-assembled composition root — no service locator. Built once in
/// `main()` (after `Supabase.initialize()`) and handed down the widget tree
/// via [RepositoryProvider]s in [SponsorADogApp]; use cases and blocs are
/// constructed at the point of use from the repositories exposed here.
class AppDependencies {
  const AppDependencies({
    required this.analytics,
    required this.supabaseClient,
    required this.authRepository,
    required this.onboardingRepository,
    required this.dogRepository,
  });

  final AnalyticsService analytics;
  final SupabaseClient supabaseClient;
  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final DogRepository dogRepository;
}

Future<AppDependencies> createAppDependencies() async {
  final networkInfo = NetworkInfoImpl(Connectivity());
  final supabaseClient = Supabase.instance.client;

  final supportsFirebase = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  final analytics = supportsFirebase
      ? FirebaseAnalyticsService(FirebaseAnalytics.instance)
      : const NoOpAnalyticsService();

  return AppDependencies(
    analytics: analytics,
    supabaseClient: supabaseClient,
    authRepository: SupabaseAuthRepository(supabaseClient),
    onboardingRepository: OnboardingRepositoryImpl(
      remoteDataSource: OnboardingRemoteDataSourceImpl(supabaseClient),
    ),
    dogRepository: DogRepositoryImpl(
      remoteDataSource: DogRemoteDataSourceImpl(supabaseClient),
      networkInfo: networkInfo,
    ),
  );
}
