import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/themes/stack_colors.dart';

class PaynymNavIcon extends StatelessWidget {
  const PaynymNavIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      Assets.svg.robotHead,
      height: 20,
      width: 20,
      color: Theme.of(context).extension<StackColors>()!.bottomNavIconIcon,
    );
  }
}
