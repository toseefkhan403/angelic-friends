import 'package:flutter/material.dart';

/// Small uppercase label above a slide's title, e.g. "Who these dogs are".
class SlideEyebrow extends StatelessWidget {
  const SlideEyebrow({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }
}
