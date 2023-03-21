import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/coin_wallets_table.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/desktop_wallet_view.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/format.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/widgets/table_view/table_view.dart';
import 'package:stackduo/widgets/table_view/table_view_cell.dart';
import 'package:stackduo/widgets/table_view/table_view_row.dart';

class WalletSummaryTable extends ConsumerStatefulWidget {
  const WalletSummaryTable({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletSummaryTable> createState() => _WalletTableState();
}

class _WalletTableState extends ConsumerState<WalletSummaryTable> {
  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD: $runtimeType");
    final providersByCoin = ref.watch(
      walletsChangeNotifierProvider.select(
        (value) => value.getManagerProvidersByCoin(),
      ),
    );

    return TableView(
      rows: [
        for (int i = 0; i < providersByCoin.length; i++)
          Builder(
            key: Key("${providersByCoin[i].item1.name}_${runtimeType}_key"),
            builder: (context) {
              final providers = providersByCoin[i].item2;

              VoidCallback? expandOverride;
              if (providers.length == 1) {
                expandOverride = () async {
                  final manager = ref.read(providers.first);
                  if (manager.coin == Coin.monero) {
                    await manager.initializeExisting();
                  }
                  await Navigator.of(context).pushNamed(
                    DesktopWalletView.routeName,
                    arguments: manager.walletId,
                  );
                };
              }

              return TableViewRow(
                expandOverride: expandOverride,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).extension<StackColors>()!.popupBG,
                  borderRadius: BorderRadius.circular(
                    Constants.size.circularBorderRadius,
                  ),
                ),
                cells: [
                  TableViewCell(
                    flex: 4,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          Assets.svg.iconFor(coin: providersByCoin[i].item1),
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          providersByCoin[i].item1.prettyName,
                          style: STextStyles.desktopTextExtraSmall(context)
                              .copyWith(
                            color: Theme.of(context)
                                .extension<StackColors>()!
                                .textDark,
                          ),
                        )
                      ],
                    ),
                  ),
                  TableViewCell(
                    flex: 4,
                    child: Text(
                      providers.length == 1
                          ? "${providers.length} wallet"
                          : "${providers.length} wallets",
                      style:
                          STextStyles.desktopTextExtraSmall(context).copyWith(
                        color: Theme.of(context)
                            .extension<StackColors>()!
                            .textSubtitle1,
                      ),
                    ),
                  ),
                  TableViewCell(
                    flex: 6,
                    child: TablePriceInfo(
                      coin: providersByCoin[i].item1,
                    ),
                  ),
                ],
                expandingChild: CoinWalletsTable(
                  coin: providersByCoin[i].item1,
                ),
              );
            },
          ),
      ],
    );
  }
}

class TablePriceInfo extends ConsumerWidget {
  const TablePriceInfo({Key? key, required this.coin}) : super(key: key);

  final Coin coin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tuple = ref.watch(
      priceAnd24hChangeNotifierProvider.select(
        (value) => value.getPrice(coin),
      ),
    );

    final currency = ref.watch(
      prefsChangeNotifierProvider.select(
        (value) => value.currency,
      ),
    );

    final priceString = Format.localizedStringAsFixed(
      value: tuple.item1,
      locale: ref
          .watch(
            localeServiceChangeNotifierProvider.notifier,
          )
          .locale,
      decimalPlaces: 2,
    );

    final double percentChange = tuple.item2;

    var percentChangedColor =
        Theme.of(context).extension<StackColors>()!.textDark;
    if (percentChange > 0) {
      percentChangedColor =
          Theme.of(context).extension<StackColors>()!.accentColorGreen;
    } else if (percentChange < 0) {
      percentChangedColor =
          Theme.of(context).extension<StackColors>()!.accentColorRed;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$priceString $currency/${coin.ticker}",
          style: STextStyles.desktopTextExtraSmall(context).copyWith(
            color: Theme.of(context).extension<StackColors>()!.textSubtitle1,
          ),
        ),
        Text(
          "${percentChange.toStringAsFixed(2)}%",
          style: STextStyles.desktopTextExtraSmall(context).copyWith(
            color: percentChangedColor,
          ),
        ),
      ],
    );
  }
}
