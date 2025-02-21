import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:stackduo/pages/add_wallet_views/new_wallet_recovery_phrase_view/sub_widgets/mnemonic_table.dart';
import 'package:stackduo/pages/home_view/home_view.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/services/coins/manager.dart';
import 'package:stackduo/utilities/clipboard_interface.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/widgets/background.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/stack_dialog.dart';

class DeleteWalletRecoveryPhraseView extends ConsumerStatefulWidget {
  const DeleteWalletRecoveryPhraseView({
    Key? key,
    required this.manager,
    required this.mnemonic,
  }) : super(key: key);

  static const routeName = "/deleteWalletRecoveryPhrase";

  final Manager manager;
  final List<String> mnemonic;

  @override
  ConsumerState<DeleteWalletRecoveryPhraseView> createState() =>
      _DeleteWalletRecoveryPhraseViewState();
}

class _DeleteWalletRecoveryPhraseViewState
    extends ConsumerState<DeleteWalletRecoveryPhraseView> {
  late Manager _manager;
  late List<String> _mnemonic;
  late ClipboardInterface _clipboardInterface;

  @override
  void initState() {
    _manager = widget.manager;
    _mnemonic = widget.mnemonic;
    disableScreenshot();
    super.initState();
  }

  @override
  void dispose() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
    super.dispose();
  }

  Future<void> disableScreenshot() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD: $runtimeType");

    return Background(
      child: Scaffold(
        backgroundColor: Theme.of(context).extension<StackColors>()!.background,
        appBar: AppBar(
          leading: AppBarBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 4,
              ),
              Text(
                _manager.walletName,
                textAlign: TextAlign.center,
                style: STextStyles.label(context).copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "Recovery Phrase",
                textAlign: TextAlign.center,
                style: STextStyles.pageTitleH1(context),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).extension<StackColors>()!.popupBG,
                  borderRadius: BorderRadius.circular(
                      Constants.size.circularBorderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Please write down your recovery phrase in the correct order and save it to keep your funds secure. You will also be asked to verify the words on the next screen.",
                    style: STextStyles.label(context).copyWith(
                        color: Theme.of(context)
                            .extension<StackColors>()!
                            .accentColorDark),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: MnemonicTable(
                    words: _mnemonic,
                    isDesktop: false,
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextButton(
                style: Theme.of(context)
                    .extension<StackColors>()!
                    .getPrimaryEnabledButtonStyle(context),
                onPressed: () {
                  showDialog<dynamic>(
                    barrierDismissible: true,
                    context: context,
                    builder: (_) => StackDialog(
                      title: "Thanks! Your wallet will be deleted.",
                      leftButton: TextButton(
                        style: Theme.of(context)
                            .extension<StackColors>()!
                            .getSecondaryEnabledButtonStyle(context),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: STextStyles.button(context).copyWith(
                              color: Theme.of(context)
                                  .extension<StackColors>()!
                                  .accentColorDark),
                        ),
                      ),
                      rightButton: TextButton(
                        style: Theme.of(context)
                            .extension<StackColors>()!
                            .getPrimaryEnabledButtonStyle(context),
                        onPressed: () async {
                          final walletId = _manager.walletId;
                          final walletsInstance =
                              ref.read(walletsChangeNotifierProvider);
                          await ref
                              .read(walletsServiceChangeNotifierProvider)
                              .deleteWallet(_manager.walletName, true);

                          if (mounted) {
                            Navigator.of(context).popUntil(
                                ModalRoute.withName(HomeView.routeName));
                          }

                          // wait for widget tree to dispose of any widgets watching the manager
                          await Future<void>.delayed(
                              const Duration(seconds: 1));
                          walletsInstance.removeWallet(walletId: walletId);
                        },
                        child: Text(
                          "Ok",
                          style: STextStyles.button(context),
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  "Continue",
                  style: STextStyles.button(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
