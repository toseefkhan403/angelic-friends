import 'package:brutalist_ui/brutalist_ui.dart' show NeoButton, NeoTextField;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' show AppleLogoPainter;
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

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
                    // The slide's own subtitle ("What should we call you?")
                    // only makes sense once the guest name field is showing —
                    // while the Google/Apple buttons are up, prompt for
                    // sign-in instead.
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
                    _SignInOptions(isSubmitting: isSubmitting),
                ],
              ),
            ),
          ),
        ),
        // Pinned to the bottom of the screen (not the scrollable content)
        // so it stays reachable as a "skip sign-in" option regardless of how
        // tall the Apple/Google buttons above end up.
        if (!_showGuestNameField)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                Text(
                  'OR',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: NeoButton(
                    onPressed:
                        isSubmitting ? null : () => setState(() => _showGuestNameField = true),
                    child: const Text('Continue as Guest'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

enum _PendingProvider { google, apple }

class _SignInOptions extends StatefulWidget {
  const _SignInOptions({required this.isSubmitting});

  final bool isSubmitting;

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
    // Sign in with Apple only has a real native flow on iOS/macOS (see
    // SocialAuthConfig.oAuthRedirectUrl) — hidden on Android rather than
    // falling back to a browser redirect there. Also shown on web so the
    // button design can be previewed without an iOS device.
    final showApple = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    return Column(
      children: [
        if (showApple) ...[
          SizedBox(
            width: double.infinity,
            child: _AppleSignInButton(
              isLoading: _pending == _PendingProvider.apple,
              onPressed: widget.isSubmitting
                  ? null
                  : () {
                      setState(() => _pending = _PendingProvider.apple);
                      context
                          .read<OnboardingBloc>()
                          .add(const OnboardingEvent.appleSignInRequested());
                    },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        SizedBox(
          width: double.infinity,
          child: _GoogleSignInButton(
            isLoading: _pending == _PendingProvider.google,
            onPressed: widget.isSubmitting
                ? null
                : () {
                    setState(() => _pending = _PendingProvider.google);
                    context
                        .read<OnboardingBloc>()
                        .add(const OnboardingEvent.googleSignInRequested());
                  },
          ),
        ),
      ],
    );
  }
}

/// A "Sign in with Apple" button matching Apple's black-button guidelines:
/// black background, the official Apple logo, and SF Pro Text — the same
/// font [_GoogleSignInButton] uses, so the two buttons read as a matched
/// pair.
/// https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple
class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({required this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

  static const _height = 44.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Material(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const CustomPaint(painter: AppleLogoPainter(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    isLoading ? 'Signing in…' : 'Sign in with Apple',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      inherit: false,
                      fontFamily: '.SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A "Sign in with Google" button following Google's branding guidelines:
/// white background, grey outline, the official "G" mark, and "Sign in
/// with Google" text in SF Pro Text (matching [_AppleSignInButton]).
/// https://developers.google.com/identity/branding-guidelines
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

  static const _height = 44.0;
  static const _borderColor = Color(0xFF747775);
  static const _textColor = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: isLoading
                      ? const CupertinoActivityIndicator()
                      : SvgPicture.asset('assets/icons/google_logo.svg', width: 18, height: 18),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    isLoading ? 'Signing in…' : 'Sign in with Google',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      inherit: false,
                      fontFamily: '.SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
