import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stackduo/models/paynym/paynym_account.dart';
import 'package:stackduo/notifications/show_flush_bar.dart';
import 'package:stackduo/pages/paynym/subwidgets/paynym_bot.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/custom_buttons/blue_text_button.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog_close_button.dart';

class PaynymQrPopup extends StatelessWidget {
  const PaynymQrPopup({
    Key? key,
    required this.paynymAccount,
  }) : super(key: key);

  final PaynymAccount paynymAccount;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Util.isDesktop;

    return DesktopDialog(
      maxWidth: isDesktop ? 580 : MediaQuery.of(context).size.width - 32,
      maxHeight: double.infinity,
      child: Column(
        children: [
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    "Address details",
                    style: STextStyles.desktopH3(context),
                  ),
                ),
                const DesktopDialogCloseButton(),
              ],
            ),
          Padding(
            padding: EdgeInsets.only(
              left: isDesktop ? 32 : 24,
              top: isDesktop ? 16 : 24,
              right: 24,
              bottom: 16,
            ),
            child: Row(
              children: [
                PayNymBot(
                  paymentCodeString: paynymAccount.nonSegwitPaymentCode.code,
                  size: isDesktop ? 56 : 36,
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  paynymAccount.nymName,
                  style: isDesktop
                      ? STextStyles.w500_24(context)
                      : STextStyles.w600_14(context),
                ),
              ],
            ),
          ),
          if (!isDesktop)
            Container(
              color:
                  Theme.of(context).extension<StackColors>()!.backgroundAppBar,
              height: 1,
            ),
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              top: 16,
              right: 24,
              bottom: 24,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isDesktop ? "PayNym address" : "Your PayNym address",
                          style: isDesktop
                              ? STextStyles.desktopTextSmall(context).copyWith(
                                  color: Theme.of(context)
                                      .extension<StackColors>()!
                                      .textSubtitle1,
                                )
                              : STextStyles.infoSmall(context).copyWith(
                                  fontSize: 12,
                                ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          paynymAccount.nonSegwitPaymentCode.code,
                          style: isDesktop
                              ? STextStyles.desktopTextSmall(context)
                              : STextStyles.infoSmall(context).copyWith(
                                  color: Theme.of(context)
                                      .extension<StackColors>()!
                                      .textDark,
                                  fontSize: 12,
                                ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        CustomTextButton(
                          text: "Copy",
                          textSize: isDesktop ? 18 : 14,
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: paynymAccount.nonSegwitPaymentCode.code,
                              ),
                            );
                            unawaited(
                              showFloatingFlushBar(
                                type: FlushBarType.info,
                                message: "Copied to clipboard",
                                iconAsset: Assets.svg.copy,
                                context: context,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                QrImage(
                  padding: const EdgeInsets.all(0),
                  size: 130,
                  data: paynymAccount.nonSegwitPaymentCode.code,
                  foregroundColor:
                      Theme.of(context).extension<StackColors>()!.textDark,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
