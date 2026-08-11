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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setVolume(0)
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        if (widget.isActive) _controller.play();
      });
  }

  @override
  void didUpdateWidget(covariant AutoPlayVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive && _initialized) {
      widget.isActive ? _controller.play() : _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return widget.thumbnailUrl != null
          ? CachedNetworkImage(imageUrl: widget.thumbnailUrl!, fit: BoxFit.cover)
          : Container(color: AppColors.neutralFill);
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
