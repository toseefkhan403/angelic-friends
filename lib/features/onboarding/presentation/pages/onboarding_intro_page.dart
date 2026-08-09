import 'package:brutalist_ui/brutalist_ui.dart' show NeoButton, NeoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/analytics/analytics_service.dart';
import 'package:sponsor_a_dog/core/auth/auth_repository.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/core/navigation/home_shell_page.dart';
import 'package:sponsor_a_dog/core/widgets/async_state_view.dart';
import 'package:sponsor_a_dog/core/widgets/page_dots_indicator.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/usecases/get_onboarding_slides.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/onboarding_slide_view.dart';

class OnboardingIntroPage extends StatelessWidget {
  const OnboardingIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(
        getOnboardingSlides: GetOnboardingSlides(context.read<OnboardingRepository>()),
        authRepository: context.read<AuthRepository>(),
        analytics: context.read<AnalyticsService>(),
      )..add(const OnboardingEvent.started()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listenWhen: (previous, current) => previous.submitStatus != current.submitStatus,
          listener: (context, state) {
            if (state.submitStatus == NameSubmitStatus.success) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeShellPage()),
                (route) => false,
              );
            } else if (state.submitStatus == NameSubmitStatus.failure &&
                state.submitErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitErrorMessage!)),
              );
            }
          },
          builder: (context, state) {
            return switch (state.slidesStatus) {
              OnboardingSlidesStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              OnboardingSlidesStatus.failure => ErrorStateView(
                  message: state.slidesErrorMessage ?? 'Something went wrong.',
                  onRetry: () =>
                      context.read<OnboardingBloc>().add(const OnboardingEvent.started()),
                ),
              OnboardingSlidesStatus.loaded => _buildSlides(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildSlides(BuildContext context, OnboardingState state) {
    final slides = state.slides;
    final isLastSlide = _currentIndex == slides.length - 1;
    final isSubmitting = state.submitStatus == NameSubmitStatus.submitting;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final isLast = index == slides.length - 1;
              return OnboardingSlideView(
                slide: slides[index],
                trailing: isLast
                    ? NeoTextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        placeholder: 'Your name',
                        onChanged: (value) => context
                            .read<OnboardingBloc>()
                            .add(OnboardingEvent.nameChanged(value)),
                      )
                    : null,
              );
            },
          ),
        ),
        PageDotsIndicator(count: slides.length, currentIndex: _currentIndex),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: NeoButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      if (isLastSlide) {
                        context.read<OnboardingBloc>().add(const OnboardingEvent.submitted());
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLastSlide ? 'Get Started' : 'Next'),
            ),
          ),
        ),
      ],
    );
  }
}
