import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/pages/paynym/paynym_claim_view.dart';
import 'package:stackduo/pages/paynym/paynym_home_view.dart';
import 'package:stackduo/pages_desktop_specific/coin_control/desktop_coin_control_view.dart';
import 'package:stackduo/pages_desktop_specific/desktop_menu.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/more_features/more_features_dialog.dart';
import 'package:stackduo/providers/desktop/current_desktop_menu_item.dart';
import 'package:stackduo/providers/global/paynym_api_provider.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/providers/wallet/my_paynym_account_state_provider.dart';
import 'package:stackduo/services/mixins/paynym_wallet_interface.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/logger.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/loading_indicator.dart';

class DesktopWalletFeatures extends ConsumerStatefulWidget {
  const DesktopWalletFeatures({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  final String walletId;

  @override
  ConsumerState<DesktopWalletFeatures> createState() =>
      _DesktopWalletFeaturesState();
}

class _DesktopWalletFeaturesState extends ConsumerState<DesktopWalletFeatures> {
  static const double buttonWidth = 120;

  Future<void> _onSwapPressed() async {
    ref.read(currentDesktopMenuItemProvider.state).state =
        DesktopMenuItemId.exchange;
    ref.read(prevDesktopMenuItemProvider.state).state =
        DesktopMenuItemId.exchange;
  }

  Future<void> _onBuyPressed() async {
    ref.read(currentDesktopMenuItemProvider.state).state =
        DesktopMenuItemId.buy;
    ref.read(prevDesktopMenuItemProvider.state).state = DesktopMenuItemId.buy;
  }

  Future<void> _onMorePressed() async {
    await showDialog<void>(
      context: context,
      builder: (_) => MoreFeaturesDialog(
        walletId: widget.walletId,
        onPaynymPressed: _onPaynymPressed,
        onCoinControlPressed: _onCoinControlPressed,
        onWhirlpoolPressed: _onWhirlpoolPressed,
      ),
    );
  }

  void _onWhirlpoolPressed() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _onCoinControlPressed() {
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.of(context).pushNamed(
      DesktopCoinControlView.routeName,
      arguments: widget.walletId,
    );
  }

  Future<void> _onPaynymPressed() async {
    Navigator.of(context, rootNavigator: true).pop();

    unawaited(
      showDialog(
        context: context,
        builder: (context) {
          return const LoadingIndicator(
            width: 100,
          );
        },
      ),
    );

    final manager =
        ref.read(walletsChangeNotifierProvider).getManager(widget.walletId);

    final wallet = manager.wallet as PaynymWalletInterface;

    final code = await wallet.getPaymentCode(isSegwit: false);

    final account = await ref.read(paynymAPIProvider).nym(code.toString());

    Logging.instance.log(
      "my nym account: $account",
      level: LogLevel.Info,
    );

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();

      // check if account exists and for matching code to see if claimed
      if (account.value != null &&
          account.value!.nonSegwitPaymentCode.claimed &&
          account.value!.segwit) {
        ref.read(myPaynymAccountStateProvider.state).state = account.value!;

        await Navigator.of(context).pushNamed(
          PaynymHomeView.routeName,
          arguments: widget.walletId,
        );
      } else {
        await Navigator.of(context).pushNamed(
          PaynymClaimView.routeName,
          arguments: widget.walletId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(
      walletsChangeNotifierProvider.select(
        (value) => value.getManager(widget.walletId),
      ),
    );

    final showMore = manager.hasPaynymSupport ||
        (manager.hasCoinControlSupport &&
            ref.watch(
              prefsChangeNotifierProvider.select(
                (value) => value.enableCoinControl,
              ),
            )) ||
        manager.hasWhirlpoolSupport;

    return Row(
      children: [
        if (Constants.enableExchange)
          SecondaryButton(
            label: "Swap",
            width: buttonWidth,
            buttonHeight: ButtonHeight.l,
            icon: SvgPicture.asset(
              Assets.svg.arrowRotate,
              height: 20,
              width: 20,
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .buttonTextSecondary,
            ),
            onPressed: () => _onSwapPressed(),
          ),
        if (showMore)
          const SizedBox(
            width: 16,
          ),
        if (showMore)
          SecondaryButton(
            label: "More",
            width: buttonWidth,
            buttonHeight: ButtonHeight.l,
            icon: SvgPicture.asset(
              Assets.svg.bars,
              height: 20,
              width: 20,
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .buttonTextSecondary,
            ),
            onPressed: () => _onMorePressed(),
          ),
      ],
    );
  }
}
