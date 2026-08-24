import 'package:flutter/widgets.dart';

/// Calls [onActivated] whenever [isActive] transitions from `false` to
/// `true` — used by tabs kept alive in an `IndexedStack` (see
/// `home_shell_page.dart`) to refetch their data when the user switches
/// back to them, since `IndexedStack` never rebuilds/refetches a hidden tab
/// on its own.
class TabRefreshListener extends StatefulWidget {
  const TabRefreshListener({
    required this.isActive,
    required this.onActivated,
    required this.child,
    super.key,
  });

  final bool isActive;
  final void Function(BuildContext context) onActivated;
  final Widget child;

  @override
  State<TabRefreshListener> createState() => _TabRefreshListenerState();
}

class _TabRefreshListenerState extends State<TabRefreshListener> {
  @override
  void didUpdateWidget(covariant TabRefreshListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      widget.onActivated(context);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
