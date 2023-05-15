import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/themes/stack_colors.dart';

class XIcon extends StatelessWidget {
  const XIcon({
    Key? key,
    this.width = 18,
    this.height = 18,
    this.color,
  }) : super(key: key);

  final double width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      Assets.svg.x,
      width: width,
      height: height,
      color: color ??
          Theme.of(context)
              .extension<StackColors>()!
              .textFieldActiveSearchIconRight,
    );
  }
}
