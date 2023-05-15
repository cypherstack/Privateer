import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:stackduo/pages/add_wallet_views/new_wallet_recovery_phrase_view/sub_widgets/mnemonic_table.dart';
import 'package:stackduo/pages/add_wallet_views/new_wallet_recovery_phrase_warning_view/new_wallet_recovery_phrase_warning_view.dart';
import 'package:stackduo/pages/add_wallet_views/verify_recovery_phrase_view/verify_recovery_phrase_view.dart';
import 'package:stackduo/pages_desktop_specific/desktop_home_view.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/exit_to_my_stack_button.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/services/coins/manager.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/desktop/desktop_app_bar.dart';
import 'package:stackduo/widgets/desktop/desktop_scaffold.dart';
import 'package:tuple/tuple.dart';

class NewWalletRecoveryPhraseView extends ConsumerStatefulWidget {
  const NewWalletRecoveryPhraseView({
    Key? key,
    required this.manager,
    required this.mnemonic,
  }) : super(key: key);

  static const routeName = "/newWalletRecoveryPhrase";

  final Manager manager;
  final List<String> mnemonic;

  @override
  ConsumerState<NewWalletRecoveryPhraseView> createState() =>
      _NewWalletRecoveryPhraseViewState();
}

class _NewWalletRecoveryPhraseViewState
    extends ConsumerState<NewWalletRecoveryPhraseView>
// with WidgetsBindingObserver
{
  late Manager _manager;
  late List<String> _mnemonic;
  // late FlutterWindowManager _windowManager;
  late final bool isDesktop;

  @override
  void initState() {
    _manager = widget.manager;
    _mnemonic = widget.mnemonic;
    disableScreenshot();
    isDesktop = Util.isDesktop;
    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
    super.dispose();
  }

  Future<bool> onWillPop() async {
    await delete();
    return true;
  }

  Future<void> delete() async {
    await ref
        .read(walletsServiceChangeNotifierProvider)
        .deleteWallet(_manager.walletName, false);
    await _manager.exitCurrentWallet();
  }

  Future<void> disableScreenshot() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD: $runtimeType");
    return WillPopScope(
      onWillPop: onWillPop,
      child: MasterScaffold(
        isDesktop: isDesktop,
        appBar: isDesktop
            ? DesktopAppBar(
                isCompactHeight: false,
                leading: AppBarBackButton(
                  onPressed: () async {
                    await delete();

                    if (mounted) {
                      Navigator.of(context).popUntil(
                        ModalRoute.withName(
                          NewWalletRecoveryPhraseWarningView.routeName,
                        ),
                      );
                    }
                    // Navigator.of(context).pop();
                  },
                ),
                trailing: ExitToMyStackButton(
                  onPressed: () async {
                    await delete();
                    if (mounted) {
                      Navigator.of(context).popUntil(
                        ModalRoute.withName(DesktopHomeView.routeName),
                      );
                    }
                  },
                ),
              )
            : AppBar(
                leading: AppBarBackButton(
                  onPressed: () async {
                    await delete();

                    if (mounted) {
                      Navigator.of(context).popUntil(
                        ModalRoute.withName(
                          NewWalletRecoveryPhraseWarningView.routeName,
                        ),
                      );
                    }
                  },
                ),
              ),
        body: Container(
          color: Theme.of(context).extension<StackColors>()!.background,
          width: isDesktop ? 600 : null,
          child: Padding(
            padding:
                isDesktop ? const EdgeInsets.all(0) : const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop)
                  const Spacer(
                    flex: 10,
                  ),
                if (!isDesktop)
                  const SizedBox(
                    height: 4,
                  ),
                if (!isDesktop)
                  Text(
                    _manager.walletName,
                    textAlign: TextAlign.center,
                    style: STextStyles.label(context).copyWith(
                      fontSize: 12,
                    ),
                  ),
                SizedBox(
                  height: isDesktop ? 24 : 4,
                ),
                Text(
                  "Recovery Phrase",
                  textAlign: TextAlign.center,
                  style: isDesktop
                      ? STextStyles.desktopH2(context)
                      : STextStyles.pageTitleH1(context),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDesktop
                        ? Theme.of(context).extension<StackColors>()!.background
                        : Theme.of(context).extension<StackColors>()!.popupBG,
                    borderRadius: BorderRadius.circular(
                        Constants.size.circularBorderRadius),
                  ),
                  child: Padding(
                    padding: isDesktop
                        ? const EdgeInsets.all(0)
                        : const EdgeInsets.all(12),
                    child: Text(
                      "Please write down your recovery phrase in the correct order and save it to keep your funds secure. You will also be asked to verify the words on the next screen.",
                      textAlign: TextAlign.center,
                      style: isDesktop
                          ? STextStyles.desktopSubtitleH2(context)
                          : STextStyles.label(context).copyWith(
                              color: Theme.of(context)
                                  .extension<StackColors>()!
                                  .accentColorDark),
                    ),
                  ),
                ),
                SizedBox(
                  height: isDesktop ? 21 : 8,
                ),
                if (!isDesktop)
                  Expanded(
                    child: SingleChildScrollView(
                      child: MnemonicTable(
                        words: _mnemonic,
                        isDesktop: isDesktop,
                      ),
                    ),
                  ),
                if (isDesktop)
                  MnemonicTable(
                    words: _mnemonic,
                    isDesktop: isDesktop,
                  ),
                SizedBox(
                  height: isDesktop ? 24 : 16,
                ),
                if (isDesktop)
                  const SizedBox(
                    height: 16,
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: isDesktop ? 70 : 0,
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final int next = Random().nextInt(_mnemonic.length);
                      ref
                          .read(verifyMnemonicWordIndexStateProvider.state)
                          .update((state) => next);

                      ref
                          .read(verifyMnemonicCorrectWordStateProvider.state)
                          .update((state) => _mnemonic[next]);

                      unawaited(Navigator.of(context).pushNamed(
                        VerifyRecoveryPhraseView.routeName,
                        arguments: Tuple2(_manager, _mnemonic),
                      ));
                    },
                    style: Theme.of(context)
                        .extension<StackColors>()!
                        .getPrimaryEnabledButtonStyle(context),
                    child: Text(
                      "I saved my recovery phrase",
                      style: isDesktop
                          ? STextStyles.desktopButtonEnabled(context)
                          : STextStyles.button(context),
                    ),
                  ),
                ),
                if (isDesktop)
                  const Spacer(
                    flex: 15,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
