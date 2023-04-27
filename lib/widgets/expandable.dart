import 'package:flutter/material.dart';

enum ExpandableState {
  collapsed,
  expanded,
}

class ExpandableController {
  VoidCallback? toggle;
  ExpandableState state = ExpandableState.collapsed;
}

class Expandable extends StatefulWidget {
  const Expandable({
    Key? key,
    required this.header,
    required this.body,
    this.animationController,
    this.animation,
    this.animationDurationMultiplier = 1.0,
    this.onExpandChanged,
    this.onExpandWillChange,
    this.controller,
    this.expandOverride,
    this.curve = Curves.easeInOut,
    this.initialState = ExpandableState.collapsed,
  }) : super(key: key);

  final Widget header;
  final Widget body;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final double animationDurationMultiplier;
  final void Function(ExpandableState)? onExpandChanged;
  final void Function(ExpandableState)? onExpandWillChange;
  final ExpandableController? controller;
  final VoidCallback? expandOverride;
  final Curve curve;
  final ExpandableState initialState;

  @override
  State<Expandable> createState() => _ExpandableState();
}

class _ExpandableState extends State<Expandable> with TickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> animation;
  late final Duration duration;
  late final ExpandableController? controller;

  late ExpandableState _toggleState;

  Future<void> toggle() async {
    if (animation.isDismissed) {
      widget.onExpandWillChange?.call(ExpandableState.expanded);
      await animationController.forward();
      _toggleState = ExpandableState.expanded;
      widget.onExpandChanged?.call(_toggleState);
    } else if (animation.isCompleted) {
      widget.onExpandWillChange?.call(ExpandableState.collapsed);
      await animationController.reverse();
      _toggleState = ExpandableState.collapsed;
      widget.onExpandChanged?.call(_toggleState);
    }
    controller?.state = _toggleState;
  }

  @override
  void initState() {
    _toggleState = widget.initialState;
    controller = widget.controller;
    controller?.toggle = toggle;

    duration = Duration(
      milliseconds: (500 * widget.animationDurationMultiplier).toInt(),
    );
    animationController = widget.animationController ??
        AnimationController(
          vsync: this,
          duration: duration,
        );

    final tween = _toggleState == ExpandableState.collapsed
        ? Tween<double>(begin: 0.0, end: 1.0)
        : Tween<double>(begin: 1.0, end: 0.0);

    animation = widget.animation ??
        tween.animate(
          CurvedAnimation(
            curve: widget.curve,
            parent: animationController,
          ),
        );
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.expandOverride ?? toggle,
            child: Container(
              color: Colors.transparent,
              child: widget.header,
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: animation,
          axisAlignment: 1.0,
          child: widget.body,
        ),
      ],
    );
  }
}
