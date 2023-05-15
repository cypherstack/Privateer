import 'package:flutter/material.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/animated_widgets/rotating_arrows.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog_close_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/stack_dialog.dart';

class RestoringDialog extends StatefulWidget {
  const RestoringDialog({
    Key? key,
    required this.onCancel,
  }) : super(key: key);

  final Future<void> Function() onCancel;

  @override
  State<RestoringDialog> createState() => _RestoringDialogState();
}

class _RestoringDialogState extends State<RestoringDialog> {
  late final Future<void> Function() onCancel;
  @override
  void initState() {
    onCancel = widget.onCancel;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Util.isDesktop) {
      return DesktopDialog(
        child: Column(
          children: [
            DesktopDialogCloseButton(
              onPressedOverride: () async {
                await onCancel.call();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const Spacer(
              flex: 1,
            ),
            const RotatingArrows(
              width: 40,
              height: 40,
            ),
            const Spacer(
              flex: 2,
            ),
            Text(
              "Restoring wallet...",
              style: STextStyles.desktopH2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              "Restoring your wallet may take a while.\nPlease do not exit this screen.",
              style: STextStyles.desktopTextMedium(context).copyWith(
                color: Theme.of(context).extension<StackColors>()!.textDark3,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(
              flex: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: 32,
              ),
              child: SecondaryButton(
                label: "Cancel",
                width: 272.5,
                onPressed: () async {
                  await onCancel.call();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
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
          title: "Restoring wallet",
          message: "This may take a while. Please do not exit this screen.",
          icon: const RotatingArrows(
            width: 24,
            height: 24,
          ),
          rightButton: TextButton(
            style: Theme.of(context)
                .extension<StackColors>()!
                .getSecondaryEnabledButtonStyle(context),
            child: Text(
              "Cancel",
              style: STextStyles.itemSubtitle12(context),
            ),
            onPressed: () async {
              await onCancel.call();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      );
    }
  }
}
