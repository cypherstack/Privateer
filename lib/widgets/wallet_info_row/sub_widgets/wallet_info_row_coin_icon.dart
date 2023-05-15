import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/themes/coin_icon_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

class WalletInfoCoinIcon extends ConsumerWidget {
  const WalletInfoCoinIcon({
    Key? key,
    required this.coin,
    this.size = 32,
  }) : super(key: key);

  final Coin coin;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .extension<StackColors>()!
            .colorForCoin(coin)
            .withOpacity(0.4),
        borderRadius: BorderRadius.circular(
          Constants.size.circularBorderRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SvgPicture.file(
          File(
            ref.watch(coinIconProvider(coin)),
          ),
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}
