import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/models/add_wallet_list_entity/add_wallet_list_entity.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/themes/coin_icon_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/util.dart';

class CoinSelectItem extends ConsumerWidget {
  const CoinSelectItem({
    Key? key,
    required this.entity,
  }) : super(key: key);

  final AddWalletListEntity entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("BUILD: CoinSelectItem for ${entity.name}");
    final selectedEntity = ref.watch(addWalletSelectedEntityStateProvider);

    final isDesktop = Util.isDesktop;

    String? tokenImageUri;
    // if (entity is EthTokenEntity) {
    //   final currency = ExchangeDataLoadingService.instance.isar.currencies
    //       .where()
    //       .exchangeNameEqualTo(ChangeNowExchange.exchangeName)
    //       .filter()
    //       .tokenContractEqualTo(
    //         (entity as EthTokenEntity).token.address,
    //         caseSensitive: false,
    //       )
    //       .and()
    //       .imageIsNotEmpty()
    //       .findFirstSync();
    //   tokenImageUri = currency?.image;
    // }

    return Container(
      decoration: BoxDecoration(
        color: selectedEntity == entity
            ? Theme.of(context).extension<StackColors>()!.textFieldActiveBG
            : Theme.of(context).extension<StackColors>()!.popupBG,
        borderRadius:
            BorderRadius.circular(Constants.size.circularBorderRadius),
      ),
      child: MaterialButton(
        key: Key("coinSelectItemButtonKey_${entity.name}${entity.ticker}"),
        padding: isDesktop
            ? const EdgeInsets.only(left: 24)
            : const EdgeInsets.all(12),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(Constants.size.circularBorderRadius),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: isDesktop ? 70 : 0,
          ),
          child: Row(
            children: [
              tokenImageUri != null
                  ? SvgPicture.network(
                      tokenImageUri,
                      width: 26,
                      height: 26,
                    )
                  : SvgPicture.file(
                      File(
                        ref.watch(coinIconProvider(entity.coin)),
                      ),
                      width: 26,
                      height: 26,
                    ),
              SizedBox(
                width: isDesktop ? 12 : 10,
              ),
              Text(
                "${entity.name} (${entity.ticker})",
                style: isDesktop
                    ? STextStyles.desktopTextMedium(context)
                    : STextStyles.subtitle600(context).copyWith(
                        fontSize: 14,
                      ),
              ),
              if (isDesktop && selectedEntity == entity) const Spacer(),
              if (isDesktop && selectedEntity == entity)
                Padding(
                  padding: const EdgeInsets.only(
                    right: 18,
                  ),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      Assets.svg.check,
                      color: Theme.of(context)
                          .extension<StackColors>()!
                          .accentColorDark,
                    ),
                  ),
                ),
            ],
          ),
        ),
        onPressed: () {
          ref.read(addWalletSelectedEntityStateProvider.state).state = entity;
        },
      ),
    );
  }
}
