import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';

class RotatingArrowsController {
  VoidCallback? forward;
  VoidCallback? repeat;
  VoidCallback? stop;
}

class RotatingArrows extends StatefulWidget {
  const RotatingArrows({
    Key? key,
    required this.height,
    required this.width,
    this.controller,
    this.color,
    this.spinByDefault = true,
  }) : super(key: key);

  final double height;
  final double width;
  final RotatingArrowsController? controller;
  final Color? color;
  final bool spinByDefault;

  @override
  State<RotatingArrows> createState() => _RotatingArrowsState();
}

class _RotatingArrowsState extends State<RotatingArrows>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(vsync: this);

    widget.controller?.forward = animationController.forward;
    widget.controller?.repeat = animationController.repeat;
    widget.controller?.stop = animationController.stop;

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    widget.controller?.forward = null;
    widget.controller?.repeat = null;
    widget.controller?.stop = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      Assets.lottie.arrowRotate,
      controller: animationController,
      height: widget.height,
      width: widget.width,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ["**"],
            value: widget.color ??
                Theme.of(context).extension<StackColors>()!.accentColorDark,
          ),
          ValueDelegate.strokeColor(
            const ["**"],
            value: widget.color ??
                Theme.of(context).extension<StackColors>()!.accentColorDark,
          ),
        ],
      ),
      onLoaded: (composition) {
        animationController.duration = composition.duration;

        // if controller was not set just assume continuous repeat
        if (widget.spinByDefault) {
          animationController.repeat();
        }
      },
    );
  }
}
