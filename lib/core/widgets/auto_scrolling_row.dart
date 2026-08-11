import 'package:flutter/material.dart';

/// A horizontal row of cards that scrolls itself continuously, left to
/// right, looping seamlessly. Used for onboarding's dog/update marquees.
///
/// Seamless looping works by laying the item list out twice back-to-back
/// and animating the scroll offset from 0 to the width of a single set,
/// then snapping back to 0 — since the second copy is visually identical
/// to the first, the snap is imperceptible.
class AutoScrollingRow extends StatefulWidget {
  const AutoScrollingRow({
    required this.itemCount,
    required this.itemBuilder,
    required this.itemWidth,
    this.spacing = 12,
    this.pixelsPerSecond = 28,
    super.key,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double itemWidth;
  final double spacing;
  final double pixelsPerSecond;

  @override
  State<AutoScrollingRow> createState() => _AutoScrollingRowState();
}

class _AutoScrollingRowState extends State<AutoScrollingRow>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final AnimationController _controller;
  late Animation<double> _animation;

  // Every item (including the last one in a set) gets trailing spacing
  // below, so a full set's rendered width is itemCount * (item + spacing) —
  // that's the offset the loop must travel before snapping back to 0 for
  // the wraparound to land exactly on the start of the identical 2nd set.
  double get _singleSetWidth => widget.itemCount * (widget.itemWidth + widget.spacing);

  @override
  void initState() {
    super.initState();
    final duration = Duration(
      milliseconds: (_singleSetWidth / widget.pixelsPerSecond * 1000).round(),
    );
    _controller = AnimationController(vsync: this, duration: duration)
      ..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_animation.value);
        }
      })
      ..repeat();
    _animation = Tween<double>(begin: 0, end: _singleSetWidth).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: [
          for (var set = 0; set < 2; set++)
            for (var i = 0; i < widget.itemCount; i++)
              Padding(
                padding: EdgeInsets.only(right: widget.spacing),
                child: SizedBox(
                  width: widget.itemWidth,
                  child: widget.itemBuilder(context, i),
                ),
              ),
        ],
      ),
    );
  }
}
