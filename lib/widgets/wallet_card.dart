import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/pages/wallet_view/wallet_view.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/desktop_wallet_view.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/conditional_parent.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';
import 'package:stackduo/widgets/wallet_info_row/wallet_info_row.dart';
import 'package:tuple/tuple.dart';

class SimpleWalletCard extends ConsumerWidget {
  const SimpleWalletCard({
    Key? key,
    required this.walletId,
    this.contractAddress,
    this.popPrevious = false,
    this.desktopNavigatorState,
  }) : super(key: key);

  final String walletId;
  final String? contractAddress;
  final bool popPrevious;
  final NavigatorState? desktopNavigatorState;

  void _openWallet(BuildContext context, WidgetRef ref) async {
    final nav = Navigator.of(context);

    final manager =
        ref.read(walletsChangeNotifierProvider).getManager(walletId);
    if (manager.coin == Coin.monero) {
      await manager.initializeExisting();
    }
    if (context.mounted) {
      if (popPrevious) nav.pop();

      if (desktopNavigatorState != null) {
        unawaited(
          desktopNavigatorState!.pushNamed(
            DesktopWalletView.routeName,
            arguments: walletId,
          ),
        );
      } else {
        unawaited(
          nav.pushNamed(
            WalletView.routeName,
            arguments: Tuple2(
              walletId,
              ref
                  .read(walletsChangeNotifierProvider)
                  .getManagerProvider(walletId),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConditionalParent(
      condition: !Util.isDesktop,
      builder: (child) => RoundedWhiteContainer(
        padding: const EdgeInsets.all(0),
        child: MaterialButton(
          // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
          key: Key("walletsSheetItemButtonKey_$walletId"),
          padding: const EdgeInsets.all(10),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Constants.size.circularBorderRadius,
            ),
          ),
          onPressed: () => _openWallet(context, ref),
          child: child,
        ),
      ),
      child: WalletInfoRow(
        walletId: walletId,
        contractAddress: null,
        onPressedDesktop:
            Util.isDesktop ? () => _openWallet(context, ref) : null,
      ),
    );
  }
}
