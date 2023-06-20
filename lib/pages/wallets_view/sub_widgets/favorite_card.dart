import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stackduo/pages/wallet_view/wallet_view.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/desktop_wallet_view.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/themes/coin_icon_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/amount/amount_formatter.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/coin_card.dart';
import 'package:stackduo/widgets/conditional_parent.dart';
import 'package:tuple/tuple.dart';

class FavoriteCard extends ConsumerStatefulWidget {
  const FavoriteCard({
    Key? key,
    required this.walletId,
    required this.width,
    required this.height,
  }) : super(key: key);

  final String walletId;
  final double width;
  final double height;

  @override
  ConsumerState<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends ConsumerState<FavoriteCard> {
  late final String walletId;

  @override
  void initState() {
    walletId = widget.walletId;

    super.initState();
  }

  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final coin = ref.watch(
      walletsChangeNotifierProvider
          .select((value) => value.getManager(walletId).coin),
    );
    final externalCalls = ref.watch(
      prefsChangeNotifierProvider.select((value) => value.externalCalls),
    );

    return ConditionalParent(
      condition: Util.isDesktop,
      builder: (child) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            _hovering = true;
          });
        },
        onExit: (_) {
          setState(() {
            _hovering = false;
          });
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: _hovering ? 1.05 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: _hovering
                ? BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      Constants.size.circularBorderRadius,
                    ),
                    boxShadow: [
                      Theme.of(context)
                          .extension<StackColors>()!
                          .standardBoxShadow,
                      Theme.of(context)
                          .extension<StackColors>()!
                          .standardBoxShadow,
                      Theme.of(context)
                          .extension<StackColors>()!
                          .standardBoxShadow,
                    ],
                  )
                : BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      Constants.size.circularBorderRadius,
                    ),
                  ),
            child: child,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          if (coin == Coin.monero) {
            await ref
                .read(walletsChangeNotifierProvider)
                .getManager(walletId)
                .initializeExisting();
          }
          if (mounted) {
            if (Util.isDesktop) {
              await Navigator.of(context).pushNamed(
                DesktopWalletView.routeName,
                arguments: walletId,
              );
            } else {
              await Navigator.of(context).pushNamed(
                WalletView.routeName,
                arguments: Tuple2(
                  walletId,
                  ref
                      .read(walletsChangeNotifierProvider)
                      .getManagerProvider(walletId),
                ),
              );
            }
          }
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: CardOverlayStack(
            background: CoinCard(
              walletId: widget.walletId,
              width: widget.width,
              height: widget.height,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            ref.watch(
                              walletsChangeNotifierProvider.select(
                                (value) =>
                                    value.getManager(walletId).walletName,
                              ),
                            ),
                            style: STextStyles.itemSubtitle12(context).copyWith(
                              color: Theme.of(context)
                                  .extension<StackColors>()!
                                  .textFavoriteCard,
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        SvgPicture.file(
                          File(
                            ref.watch(coinIconProvider(coin)),
                          ),
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final balance = ref.watch(
                        walletsChangeNotifierProvider.select(
                          (value) => value.getManager(walletId).balance,
                        ),
                      );

                      Amount total = balance.total;

                      Amount fiatTotal = Amount.zero;

                      if (externalCalls && total > Amount.zero) {
                        fiatTotal = (total.decimal *
                                ref
                                    .watch(
                                      priceAnd24hChangeNotifierProvider.select(
                                        (value) => value.getPrice(coin),
                                      ),
                                    )
                                    .item1)
                            .toAmount(fractionDigits: 2);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              ref.watch(pAmountFormatter(coin)).format(total),
                              style: STextStyles.titleBold12(context).copyWith(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .extension<StackColors>()!
                                    .textFavoriteCard,
                              ),
                            ),
                          ),
                          if (externalCalls)
                            const SizedBox(
                              height: 4,
                            ),
                          if (externalCalls)
                            Text(
                              "${fiatTotal.fiatString(
                                locale: ref.watch(
                                  localeServiceChangeNotifierProvider.select(
                                    (value) => value.locale,
                                  ),
                                ),
                              )} ${ref.watch(
                                prefsChangeNotifierProvider.select(
                                  (value) => value.currency,
                                ),
                              )}",
                              style:
                                  STextStyles.itemSubtitle12(context).copyWith(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .extension<StackColors>()!
                                    .textFavoriteCard,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardOverlayStack extends StatelessWidget {
  const CardOverlayStack(
      {Key? key, required this.background, required this.child})
      : super(key: key);

  final Widget background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        background,
        child,
      ],
    );
  }
}
