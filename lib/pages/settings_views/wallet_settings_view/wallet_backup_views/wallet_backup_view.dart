import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stackduo/pages/add_wallet_views/new_wallet_recovery_phrase_view/sub_widgets/mnemonic_table.dart';
import 'package:stackduo/providers/global/wallets_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/address_utils.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/widgets/background.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/stack_dialog.dart';

class WalletBackupView extends ConsumerStatefulWidget {
  const WalletBackupView({
    Key? key,
    required this.walletId,
    required this.mnemonic,
  }) : super(key: key);

  static const String routeName = "/walletBackup";

  final String walletId;
  final List<String> mnemonic;

  @override
  ConsumerState<WalletBackupView> createState() => _WalletBackupViewState();
}

class _WalletBackupViewState extends ConsumerState<WalletBackupView> {
  late List<String> _mnemonic;
  late String _walletId;

  Future<void> disableScreenshot() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void initState() {
    _walletId = widget.walletId;
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
          title: Text(
            "Wallet backup",
            style: STextStyles.navBarTitle(context),
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
                ref
                    .watch(walletsChangeNotifierProvider
                        .select((value) => value.getManager(_walletId)))
                    .walletName,
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
                    "Please write down your backup key. Keep it safe and never share it with anyone. Your backup key is the only way you can access your funds if you forget your PIN, lose your phone, etc.\n\nStack Duo does not keep nor is able to restore your backup key. Only you have access to your wallet.",
                    style: STextStyles.label(context),
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
                height: 12,
              ),
              TextButton(
                style: Theme.of(context)
                    .extension<StackColors>()!
                    .getPrimaryEnabledButtonStyle(context),
                onPressed: () {
                  String data = AddressUtils.encodeQRSeedData(_mnemonic);

                  showDialog<dynamic>(
                    context: context,
                    useSafeArea: false,
                    barrierDismissible: true,
                    builder: (_) {
                      final width = MediaQuery.of(context).size.width / 2;
                      return StackDialogBase(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                "Recovery phrase QR code",
                                style: STextStyles.pageTitleH2(context),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Center(
                              child: RepaintBoundary(
                                // key: _qrKey,
                                child: SizedBox(
                                  width: width + 20,
                                  height: width + 20,
                                  child: QrImageView(
                                      data: data,
                                      size: width,
                                      backgroundColor: Theme.of(context)
                                          .extension<StackColors>()!
                                          .popupBG,
                                      foregroundColor: Theme.of(context)
                                          .extension<StackColors>()!
                                          .accentColorDark),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Center(
                              child: SizedBox(
                                width: width,
                                child: TextButton(
                                  onPressed: () async {
                                    // await _capturePng(true);
                                    Navigator.of(context).pop();
                                  },
                                  style: Theme.of(context)
                                      .extension<StackColors>()!
                                      .getSecondaryEnabledButtonStyle(context),
                                  child: Text(
                                    "Cancel",
                                    style: STextStyles.button(context).copyWith(
                                        color: Theme.of(context)
                                            .extension<StackColors>()!
                                            .accentColorDark),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  "Show QR Code",
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
