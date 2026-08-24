import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';

/// Wraps [child] with the app's standard shimmer sweep — a flat gray
/// sheen built from the existing neutral-fill/outline pair, rather than a
/// generic Material shimmer, so loading skeletons stay in the app's flat
/// neobrutalist palette.
///
/// [child] should be built from [ShimmerBox]es (or any solid-colored
/// boxes) shaped like the content being loaded.
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.outline,
      highlightColor: AppColors.neutralFill,
      child: child,
    );
  }
}

/// A solid gray block used as a skeleton placeholder for an image, line of
/// text, etc. Meant to be used as (a descendant of) a [ShimmerLoading].
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.outline,
        borderRadius: borderRadius,
      ),
    );
  }
}
