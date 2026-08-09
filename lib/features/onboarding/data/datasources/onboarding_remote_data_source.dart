import 'package:sponsor_a_dog/core/error/exceptions.dart';
import 'package:sponsor_a_dog/features/onboarding/data/models/onboarding_slide_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingSlideModel>> getOnboardingSlides();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  const OnboardingRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<OnboardingSlideModel>> getOnboardingSlides() async {
    try {
      final rows = await _client.from('onboarding_slides').select().order('sort_order');
      return rows.map(OnboardingSlideModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }
}
