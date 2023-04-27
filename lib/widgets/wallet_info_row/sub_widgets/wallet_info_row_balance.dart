import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';

class WalletInfoRowBalance extends ConsumerWidget {
  const WalletInfoRowBalance({
    Key? key,
    required this.walletId,
    this.contractAddress,
  }) : super(key: key);

  final String walletId;
  final String? contractAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(ref
        .watch(walletsChangeNotifierProvider.notifier)
        .getManagerProvider(walletId));

    final locale = ref.watch(
      localeServiceChangeNotifierProvider.select(
        (value) => value.locale,
      ),
    );

    Amount totalBalance;
    int decimals;
    String unit;
    totalBalance = manager.balance.total;
    unit = manager.coin.ticker;
    decimals = manager.coin.decimals;

    return Text(
      "${totalBalance.localizedStringAsFixed(
        locale: locale,
        decimalPlaces: decimals,
      )} $unit",
      style: Util.isDesktop
          ? STextStyles.desktopTextExtraSmall(context).copyWith(
              color: Theme.of(context).extension<StackColors>()!.textSubtitle1,
            )
          : STextStyles.itemSubtitle(context),
    );
  }
}
