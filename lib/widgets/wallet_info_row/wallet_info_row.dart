import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/custom_buttons/blue_text_button.dart';
import 'package:stackduo/widgets/wallet_info_row/sub_widgets/wallet_info_row_balance.dart';
import 'package:stackduo/widgets/wallet_info_row/sub_widgets/wallet_info_row_coin_icon.dart';

class WalletInfoRow extends ConsumerWidget {
  const WalletInfoRow({
    Key? key,
    required this.walletId,
    this.onPressedDesktop,
    this.contractAddress,
    this.padding = const EdgeInsets.all(0),
  }) : super(key: key);

  final String walletId;
  final String? contractAddress;
  final VoidCallback? onPressedDesktop;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(ref
        .watch(walletsChangeNotifierProvider.notifier)
        .getManagerProvider(walletId));

    // EthContract? contract;
    // if (contractAddress != null) {
    //   contract = ref.watch(mainDBProvider
    //       .select((value) => value.getEthContractSync(contractAddress!)));
    // }

    if (Util.isDesktop) {
      return Padding(
        padding: padding,
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    WalletInfoCoinIcon(
                      coin: manager.coin,
                      contractAddress: contractAddress,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    // contract != null
                    //     ? Row(
                    //         children: [
                    //           Text(
                    //             contract.name,
                    //             style:
                    //                 STextStyles.desktopTextExtraSmall(context)
                    //                     .copyWith(
                    //               color: Theme.of(context)
                    //                   .extension<StackColors>()!
                    //                   .textDark,
                    //             ),
                    //           ),
                    //           const SizedBox(
                    //             width: 4,
                    //           ),
                    //           CoinTickerTag(
                    //             walletId: walletId,
                    //           ),
                    //         ],
                    //       )
                    //     :
                    Text(
                            manager.walletName,
                            style: STextStyles.desktopTextExtraSmall(context)
                                .copyWith(
                              color: Theme.of(context)
                                  .extension<StackColors>()!
                                  .textDark,
                            ),
                          ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: WalletInfoRowBalance(
                  walletId: walletId,
                  contractAddress: contractAddress,
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTextButton(
                      text: "Open wallet",
                      onTap: onPressedDesktop,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return Row(
        children: [
          WalletInfoCoinIcon(
            coin: manager.coin,
            contractAddress: contractAddress,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // contract != null
                //     ? Row(
                //         children: [
                //           Text(
                //             contract.name,
                //             style: STextStyles.titleBold12(context),
                //           ),
                //           const SizedBox(
                //             width: 4,
                //           ),
                //           CoinTickerTag(
                //             walletId: walletId,
                //           ),
                //         ],
                //       )
                //     :
                Text(
                        manager.walletName,
                        style: STextStyles.titleBold12(context),
                      ),
                const SizedBox(
                  height: 2,
                ),
                WalletInfoRowBalance(
                  walletId: walletId,
                  contractAddress: contractAddress,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
