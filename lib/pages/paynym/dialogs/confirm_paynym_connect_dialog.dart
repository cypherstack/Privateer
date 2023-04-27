import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog_close_button.dart';
import 'package:stackduo/widgets/desktop/primary_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/stack_dialog.dart';

class ConfirmPaynymConnectDialog extends StatelessWidget {
  const ConfirmPaynymConnectDialog({
    Key? key,
    required this.nymName,
    required this.locale,
    required this.onConfirmPressed,
    required this.amount,
    required this.coin,
  }) : super(key: key);

  final String nymName;
  final String locale;
  final VoidCallback onConfirmPressed;
  final Amount amount;
  final Coin coin;

  String get title => "Connect to $nymName";

  String get message => "A one-time connection fee of "
      "${amount.localizedStringAsFixed(locale: locale)} ${coin.ticker} "
      "will be charged to connect to this PayNym.\n\nThis fee "
      "covers the cost of creating a one-time transaction to create a "
      "record on the blockchain. This keeps PayNyms decentralized.";

  @override
  Widget build(BuildContext context) {
    if (Util.isDesktop) {
      return DesktopDialog(
        maxHeight: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: SvgPicture.asset(
                    Assets.svg.userPlus,
                    color: Theme.of(context).extension<StackColors>()!.textDark,
                    width: 32,
                    height: 32,
                  ),
                ),
                const DesktopDialogCloseButton(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 40,
                bottom: 32,
                right: 40,
              ),
              child: Text(
                title,
                style: STextStyles.desktopH3(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 40,
                right: 40,
              ),
              child: Text(
                message,
                style: STextStyles.desktopTextMedium(context).copyWith(
                  color: Theme.of(context).extension<StackColors>()!.textDark3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 40,
                bottom: 40,
                right: 40,
                top: 32,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      buttonHeight: ButtonHeight.l,
                      label: "Cancel",
                      onPressed: Navigator.of(context).pop,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: PrimaryButton(
                      buttonHeight: ButtonHeight.l,
                      label: "Connect",
                      onPressed: onConfirmPressed,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return StackDialog(
        title: title,
        icon: SvgPicture.asset(
          Assets.svg.userPlus,
          color: Theme.of(context).extension<StackColors>()!.textDark,
          width: 24,
          height: 24,
        ),
        message: message,
        leftButton: SecondaryButton(
          buttonHeight: ButtonHeight.xl,
          label: "Cancel",
          onPressed: Navigator.of(context).pop,
        ),
        rightButton: PrimaryButton(
          buttonHeight: ButtonHeight.xl,
          label: "Connect",
          onPressed: onConfirmPressed,
        ),
      );
    }
  }
}
