import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stackduo/notifications/show_flush_bar.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/clipboard_interface.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog_close_button.dart';
import 'package:stackduo/widgets/desktop/primary_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';

class DesktopShowXpubDialog extends ConsumerStatefulWidget {
  const DesktopShowXpubDialog({
    Key? key,
    required this.xpub,
    this.clipboardInterface = const ClipboardWrapper(),
  }) : super(key: key);

  final String xpub;

  final ClipboardInterface clipboardInterface;

  static const String routeName = "/desktopShowXpubDialog";

  @override
  ConsumerState<DesktopShowXpubDialog> createState() =>
      _DesktopShowXpubDialog();
}

class _DesktopShowXpubDialog extends ConsumerState<DesktopShowXpubDialog> {
  late ClipboardInterface _clipboardInterface;

  @override
  void initState() {
    _clipboardInterface = widget.clipboardInterface;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _copy() async {
    await _clipboardInterface.setData(ClipboardData(text: widget.xpub));
    unawaited(showFloatingFlushBar(
      type: FlushBarType.info,
      message: "Copied to clipboard",
      iconAsset: Assets.svg.copy,
      context: context,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DesktopDialog(
      maxWidth: 580,
      maxHeight: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DesktopDialogCloseButton(
                onPressedOverride: Navigator.of(
                  context,
                  rootNavigator: true,
                ).pop,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 26),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  "Wallet Xpub",
                  style: STextStyles.desktopH2(context),
                ),
                const SizedBox(height: 14),
                QrImage(
                  data: widget.xpub,
                  size: 300,
                  foregroundColor: Theme.of(context)
                      .extension<StackColors>()!
                      .accentColorDark,
                ),
                const SizedBox(height: 25),
                Text(widget.xpub!, style: STextStyles.largeMedium14(context)),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SecondaryButton(
                        width: 250,
                        buttonHeight: ButtonHeight.xl,
                        label: "Copy",
                        onPressed: () async {
                          await _copy();
                        }),
                    const SizedBox(width: 16),
                    PrimaryButton(
                        width: 250,
                        buttonHeight: ButtonHeight.xl,
                        label: "Continue",
                        onPressed: Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
