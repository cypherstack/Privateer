import 'package:flutter/material.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/animated_widgets/rotating_arrows.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog_close_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/stack_dialog.dart';

class ClaimingPaynymDialog extends StatefulWidget {
  const ClaimingPaynymDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ClaimingPaynymDialog> createState() => _RestoringDialogState();
}

class _RestoringDialogState extends State<ClaimingPaynymDialog> {
  @override
  Widget build(BuildContext context) {
    if (Util.isDesktop) {
      return DesktopDialog(
        maxWidth: 580,
        maxHeight: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DesktopDialogCloseButton(
                  onPressedOverride: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
            const RotatingArrows(
              width: 40,
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Claiming PayNym",
                    style: STextStyles.desktopH2(context),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "We are generating your PayNym",
                    style: STextStyles.desktopTextMedium(context).copyWith(
                      color:
                          Theme.of(context).extension<StackColors>()!.textDark3,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  SecondaryButton(
                    label: "Cancel",
                    width: 272,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: StackDialog(
          title: "Claiming PayNym",
          message: "We are generating your PayNym",
          icon: const RotatingArrows(
            width: 24,
            height: 24,
          ),
          rightButton: SecondaryButton(
            label: "Cancel",
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
      );
    }
  }
}
