import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sponsor_a_dog/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

/// A muted, looping video that plays only while [isActive] is true —
/// e.g. only while its page is the current one in a PageView/carousel.
class AutoPlayVideo extends StatefulWidget {
  const AutoPlayVideo({required this.videoUrl, required this.isActive, this.thumbnailUrl, super.key});

  final String videoUrl;
  final String? thumbnailUrl;
  final bool isActive;

  @override
  State<AutoPlayVideo> createState() => _AutoPlayVideoState();
}

class _AutoPlayVideoState extends State<AutoPlayVideo> {
  late final VideoPlayerController _controller;
  bool _initialized = false;

  // The controller's texture can still paint a stray blank/white frame or
  // two right as it swaps in, even once "initialized" and even once
  // `position` has started advancing. Keeping the thumbnail underneath and
  // cross-fading the video in on top (instead of a hard swap) blends that
  // over instead of showing it as a flash.
  bool _showVideo = false;

  // On Android the reported frame size can still change a few frames after
  // `initialize()` resolves (the platform view refines it once the codec is
  // fully configured). Re-syncing on every size change — not just once —
  // keeps the FittedBox's cover math from locking onto a stale aspect ratio,
  // which otherwise shows up as a black bar down one side of the video.
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setVolume(0)
      ..setLooping(true)
      ..addListener(_onControllerUpdate)
      ..initialize().then((_) {
        if (!mounted) return;
        _lastSize = _controller.value.size;
        setState(() => _initialized = true);
        if (widget.isActive) _controller.play();
      });
  }

  void _onControllerUpdate() {
    if (!_controller.value.isInitialized) return;

    final showVideo = !_showVideo && _controller.value.position > Duration.zero;
    final sizeChanged = _controller.value.size != _lastSize;
    if (!showVideo && !sizeChanged) return;

    setState(() {
      if (showVideo) _showVideo = true;
      if (sizeChanged) _lastSize = _controller.value.size;
    });
  }

  @override
  void didUpdateWidget(covariant AutoPlayVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive && _controller.value.isInitialized) {
      widget.isActive ? _controller.play() : _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.thumbnailUrl != null)
          CachedNetworkImage(imageUrl: widget.thumbnailUrl!, fit: BoxFit.cover)
        else
          Container(color: AppColors.neutralFill),
        if (_initialized)
          AnimatedOpacity(
            opacity: _showVideo ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
            child: FittedBox(
              fit: BoxFit.cover,
              // FittedBox does not clip by default — with BoxFit.cover the
              // child is scaled up until it covers this box, which for most
              // video aspect ratios means it grows past this box's own
              // bounds and paints outside the card unless clipping is
              // turned on.
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _lastSize.width,
                height: _lastSize.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
      ],
    );
  }
}
