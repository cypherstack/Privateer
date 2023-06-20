import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:isar/isar.dart';
import 'package:stackduo/models/isar/exchange_cache/currency.dart';
import 'package:stackduo/services/exchange/change_now/change_now_exchange.dart';
import 'package:stackduo/services/exchange/exchange_data_loading_service.dart';
import 'package:stackduo/themes/coin_icon_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

class WalletInfoCoinIcon extends ConsumerWidget {
  const WalletInfoCoinIcon({
    Key? key,
    required this.coin,
    this.size = 32,
    this.contractAddress,
  }) : super(key: key);

  final Coin coin;
  final String? contractAddress;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Currency? currency;
    if (contractAddress != null) {
      currency = ExchangeDataLoadingService.instance.isar.currencies
          .where()
          .exchangeNameEqualTo(ChangeNowExchange.exchangeName)
          .filter()
          .tokenContractEqualTo(
            contractAddress!,
            caseSensitive: false,
          )
          .and()
          .imageIsNotEmpty()
          .findFirstSync();
    }

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
        padding: EdgeInsets.all(size / 5),
        child: currency != null && currency.image.isNotEmpty
            ? SvgPicture.network(
                currency.image,
                width: 20,
                height: 20,
              )
            : SvgPicture.file(
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
