import 'package:brutalist_ui/brutalist_ui.dart' show NeoButton, NeoTextField;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sponsor_a_dog/core/constants/app_spacing.dart';
import 'package:sponsor_a_dog/features/onboarding/domain/entities/onboarding_slide.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:sponsor_a_dog/features/onboarding/presentation/widgets/slides/slide_eyebrow.dart';

/// Final onboarding slide: eyebrow/title/subtitle, then Google/Apple/Guest
/// sign-in options. Google and Apple sign in immediately; "Continue as
/// Guest" reveals the name field that doubles as this app's anonymous
/// login step.
class MarqueeNameCaptureSlide extends StatefulWidget {
  const MarqueeNameCaptureSlide({
    required this.slide,
    required this.nameController,
    required this.onNameChanged,
    super.key,
  });

  final OnboardingSlide slide;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;

  @override
  State<MarqueeNameCaptureSlide> createState() => _MarqueeNameCaptureSlideState();
}

class _MarqueeNameCaptureSlideState extends State<MarqueeNameCaptureSlide> {
  bool _showGuestNameField = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubmitting = context.select(
          (OnboardingBloc bloc) => bloc.state.submitStatus,
        ) ==
        OnboardingCompletionStatus.submitting;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.slide.eyebrow != null) SlideEyebrow(text: widget.slide.eyebrow!),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.slide.title,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              // The slide's own subtitle ("What should we call you?") only
              // makes sense once the guest name field is showing — while the
              // Google/Apple/Guest buttons are up, prompt for sign-in instead.
              _showGuestNameField ? widget.slide.subtitle : 'Sign in to continue',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_showGuestNameField)
              _GuestNameForm(
                nameController: widget.nameController,
                onNameChanged: widget.onNameChanged,
                isSubmitting: isSubmitting,
                onBack: () => setState(() => _showGuestNameField = false),
              )
            else
              _SignInOptions(
                isSubmitting: isSubmitting,
                onContinueAsGuest: () => setState(() => _showGuestNameField = true),
              ),
          ],
        ),
      ),
    );
  }
}

// apple is unused while the Apple sign-in button below is commented out;
// kept so re-enabling it is a one-line uncomment.
enum _PendingProvider { google, apple } // ignore: unused_field

class _SignInOptions extends StatefulWidget {
  const _SignInOptions({required this.isSubmitting, required this.onContinueAsGuest});

  final bool isSubmitting;
  final VoidCallback onContinueAsGuest;

  @override
  State<_SignInOptions> createState() => _SignInOptionsState();
}

class _SignInOptionsState extends State<_SignInOptions> {
  _PendingProvider? _pending;

  @override
  void didUpdateWidget(_SignInOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Once the bloc leaves the submitting state (success, failure, or a
    // silent cancel-reset), clear the local "which button" marker too —
    // otherwise a failed/cancelled sign-in would leave that button spinning
    // forever on the next render.
    if (oldWidget.isSubmitting && !widget.isSubmitting) {
      setState(() => _pending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeoButton(
            onPressed: widget.isSubmitting
                ? null
                : () {
                    setState(() => _pending = _PendingProvider.google);
                    context
                        .read<OnboardingBloc>()
                        .add(const OnboardingEvent.googleSignInRequested());
                  },
            child: _pending == _PendingProvider.google
                ? const SizedBox(width: 20, height: 20, child: CupertinoActivityIndicator())
                : const Text('Continue with Google'),
          ),
        ),
        // Commented out for now — see PendingProvider.apple/appleSignInRequested
        // wiring below, left intact for a quick re-enable.
        // const SizedBox(height: AppSpacing.sm),
        // SizedBox(
        //   width: double.infinity,
        //   child: NeoButton(
        //     onPressed: widget.isSubmitting
        //         ? null
        //         : () {
        //             setState(() => _pending = _PendingProvider.apple);
        //             context
        //                 .read<OnboardingBloc>()
        //                 .add(const OnboardingEvent.appleSignInRequested());
        //           },
        //     child: _pending == _PendingProvider.apple
        //         ? const SizedBox(width: 20, height: 20, child: CupertinoActivityIndicator())
        //         : const Text('Continue with Apple'),
        //   ),
        // ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: NeoButton(
            onPressed: widget.isSubmitting ? null : widget.onContinueAsGuest,
            child: const Text('Continue as Guest'),
          ),
        ),
      ],
    );
  }
}

class _GuestNameForm extends StatelessWidget {
  const _GuestNameForm({
    required this.nameController,
    required this.onNameChanged,
    required this.isSubmitting,
    required this.onBack,
  });

  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final bool isSubmitting;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: NeoTextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            placeholder: 'Your name',
            onChanged: onNameChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: NeoButton(
            onPressed: isSubmitting
                ? null
                : () => context.read<OnboardingBloc>().add(const OnboardingEvent.submitted()),
            child: isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CupertinoActivityIndicator())
                : const Text('Continue'),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: isSubmitting ? null : onBack,
          child: const Text('Back'),
        ),
      ],
    );
  }
}
