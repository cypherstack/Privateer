import 'package:flutter/material.dart';
import 'package:stackduo/utilities/util.dart';

enum ButtonHeight {
  xxs,
  xs,
  s,
  m,
  l,
  xl,
  xxl,
}

class CustomTextButtonBase extends StatelessWidget {
  const CustomTextButtonBase({
    Key? key,
    this.width,
    this.height,
    this.textButton,
  }) : super(key: key);

  final double? width;
  final double? height;
  final TextButton? textButton;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Util.isDesktop;

    return SizedBox(
      height: isDesktop && height == null ? 70 : height,
      width: width,
      child: textButton,
    );
  }
}
