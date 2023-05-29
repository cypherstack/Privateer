import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/amount/amount_formatter.dart';
import 'package:stackduo/utilities/text_styles.dart';
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

    Amount totalBalance;
    // EthContract? contract;
    // if (contractAddress == null) {
    totalBalance = manager.balance.total;
    // if (manager.coin == Coin.firo || manager.coin == Coin.firoTestNet) {
    //   totalBalance =
    //       totalBalance + (manager.wallet as FiroWallet).balancePrivate.total;
    // }
    // contract = null;
    // } else {
    //   final ethWallet = manager.wallet as EthereumWallet;
    //   contract = MainDB.instance.getEthContractSync(contractAddress!)!;
    //   totalBalance = ethWallet.getCachedTokenBalance(contract).total;
    // }

    return Text(
      ref
          .watch(pAmountFormatter(manager.coin))
          .format(totalBalance, ethContract: null),
      style: Util.isDesktop
          ? STextStyles.desktopTextExtraSmall(context).copyWith(
              color: Theme.of(context).extension<StackColors>()!.textSubtitle1,
            )
          : STextStyles.itemSubtitle(context),
    );
  }
}
