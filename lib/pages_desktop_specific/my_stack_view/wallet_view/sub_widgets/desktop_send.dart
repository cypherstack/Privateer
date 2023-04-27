import 'dart:async';

import 'package:bip47/bip47.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/models/contact_address_entry.dart';
import 'package:stackduo/models/paynym/paynym_account_lite.dart';
import 'package:stackduo/models/send_view_auto_fill_data.dart';
import 'package:stackduo/pages/send_view/confirm_transaction_view.dart';
import 'package:stackduo/pages/send_view/sub_widgets/building_transaction_dialog.dart';
import 'package:stackduo/pages/send_view/sub_widgets/transaction_fee_selection_sheet.dart';
import 'package:stackduo/pages_desktop_specific/coin_control/desktop_coin_control_use_dialog.dart';
import 'package:stackduo/pages_desktop_specific/desktop_home_view.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/address_book_address_chooser/address_book_address_chooser.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/desktop_fee_dropdown.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/providers/ui/fee_rate_type_state_provider.dart';
import 'package:stackduo/providers/ui/preview_tx_button_state_provider.dart';
import 'package:stackduo/services/coins/manager.dart';
import 'package:stackduo/services/mixins/paynym_wallet_interface.dart';
import 'package:stackduo/utilities/address_utils.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/barcode_scanner_interface.dart';
import 'package:stackduo/utilities/clipboard_interface.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/logger.dart';
import 'package:stackduo/utilities/prefs.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/animated_text.dart';
import 'package:stackduo/widgets/custom_buttons/blue_text_button.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog_close_button.dart';
import 'package:stackduo/widgets/desktop/primary_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/icon_widgets/addressbook_icon.dart';
import 'package:stackduo/widgets/icon_widgets/clipboard_icon.dart';
import 'package:stackduo/widgets/icon_widgets/x_icon.dart';
import 'package:stackduo/widgets/rounded_container.dart';
import 'package:stackduo/widgets/stack_text_field.dart';
import 'package:stackduo/widgets/textfield_icon_button.dart';

class DesktopSend extends ConsumerStatefulWidget {
  const DesktopSend({
    Key? key,
    required this.walletId,
    this.autoFillData,
    this.clipboard = const ClipboardWrapper(),
    this.barcodeScanner = const BarcodeScannerWrapper(),
    this.accountLite,
  }) : super(key: key);

  final String walletId;
  final SendViewAutoFillData? autoFillData;
  final ClipboardInterface clipboard;
  final BarcodeScannerInterface barcodeScanner;
  final PaynymAccountLite? accountLite;

  @override
  ConsumerState<DesktopSend> createState() => _DesktopSendState();
}

class _DesktopSendState extends ConsumerState<DesktopSend> {
  late final String walletId;
  late final Coin coin;
  late final ClipboardInterface clipboard;
  late final BarcodeScannerInterface scanner;

  late TextEditingController sendToController;
  late TextEditingController cryptoAmountController;
  late TextEditingController baseAmountController;
  // late TextEditingController feeController;

  late final SendViewAutoFillData? _data;

  final _addressFocusNode = FocusNode();
  final _cryptoFocus = FocusNode();
  final _baseFocus = FocusNode();

  String? _note;

  Amount? _amountToSend;
  Amount? _cachedAmountToSend;
  String? _address;

  String? _privateBalanceString;
  String? _publicBalanceString;

  bool _addressToggleFlag = false;

  bool _cryptoAmountChangeLock = false;
  late VoidCallback onCryptoAmountChanged;

  bool get isPaynymSend => widget.accountLite != null;

  Future<void> previewSend() async {
    final manager =
        ref.read(walletsChangeNotifierProvider).getManager(walletId);

    final Amount amount = _amountToSend!;
    final Amount availableBalance = manager.balance.spendable;

    final coinControlEnabled =
        ref.read(prefsChangeNotifierProvider).enableCoinControl;

    if (!(manager.hasCoinControlSupport && coinControlEnabled) ||
        (manager.hasCoinControlSupport &&
            coinControlEnabled &&
            ref.read(desktopUseUTXOs).isEmpty)) {
      // confirm send all
      if (amount == availableBalance) {
        final bool? shouldSendAll = await showDialog<bool>(
          context: context,
          useSafeArea: false,
          barrierDismissible: true,
          builder: (context) {
            return DesktopDialog(
              maxWidth: 450,
              maxHeight: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 32,
                  bottom: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Confirm send all",
                          style: STextStyles.desktopH3(context),
                        ),
                        const DesktopDialogCloseButton(),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 32,
                      ),
                      child: Text(
                        "You are about to send your entire balance. Would you like to continue?",
                        textAlign: TextAlign.left,
                        style: STextStyles.desktopTextExtraExtraSmall(context)
                            .copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 32,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SecondaryButton(
                              buttonHeight: ButtonHeight.l,
                              label: "Cancel",
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: PrimaryButton(
                              buttonHeight: ButtonHeight.l,
                              label: "Yes",
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        if (shouldSendAll == null || shouldSendAll == false) {
          // cancel preview
          return;
        }
      }
    }

    try {
      bool wasCancelled = false;

      if (mounted) {
        unawaited(
          showDialog<dynamic>(
            context: context,
            useSafeArea: false,
            barrierDismissible: false,
            builder: (context) {
              return DesktopDialog(
                maxWidth: 400,
                maxHeight: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: BuildingTransactionDialog(
                    coin: manager.coin,
                    onCancel: () {
                      wasCancelled = true;

                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
          ),
        );
      }

      final time = Future<dynamic>.delayed(
        const Duration(
          milliseconds: 2500,
        ),
      );

      Map<String, dynamic> txData;
      Future<Map<String, dynamic>> txDataFuture;

      if (isPaynymSend) {
        final wallet = manager.wallet as PaynymWalletInterface;
        final paymentCode = PaymentCode.fromPaymentCode(
          widget.accountLite!.code,
          networkType: wallet.networkType,
        );
        final feeRate = ref.read(feeRateTypeStateProvider);
        txDataFuture = wallet.preparePaymentCodeSend(
          paymentCode: paymentCode,
          isSegwit: widget.accountLite!.segwit,
          amount: amount,
          args: {
            "feeRate": feeRate,
            "UTXOs": (manager.hasCoinControlSupport &&
                    coinControlEnabled &&
                    ref.read(desktopUseUTXOs).isNotEmpty)
                ? ref.read(desktopUseUTXOs)
                : null,
          },
        );
      } else {
        txDataFuture = manager.prepareSend(
          address: _address!,
          amount: amount,
          args: {
            "feeRate": ref.read(feeRateTypeStateProvider),
            "UTXOs": (manager.hasCoinControlSupport &&
                    coinControlEnabled &&
                    ref.read(desktopUseUTXOs).isNotEmpty)
                ? ref.read(desktopUseUTXOs)
                : null,
          },
        );
      }

      final results = await Future.wait([
        txDataFuture,
        time,
      ]);

      txData = results.first as Map<String, dynamic>;

      if (!wasCancelled && mounted) {
        if (isPaynymSend) {
          txData["paynymAccountLite"] = widget.accountLite!;
          txData["note"] = _note ?? "PayNym send";
        } else {
          txData["address"] = _address;
          txData["note"] = _note ?? "";
        }
        // pop building dialog
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();

        unawaited(
          showDialog(
            context: context,
            builder: (context) => DesktopDialog(
              maxHeight: double.infinity,
              maxWidth: 580,
              child: ConfirmTransactionView(
                transactionInfo: txData,
                walletId: walletId,
                isPaynymTransaction: isPaynymSend,
                routeOnSuccessName: DesktopHomeView.routeName,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // pop building dialog
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();

        unawaited(
          showDialog<void>(
            context: context,
            builder: (context) {
              return DesktopDialog(
                maxWidth: 450,
                maxHeight: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 32,
                    bottom: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Transaction failed",
                            style: STextStyles.desktopH3(context),
                          ),
                          const DesktopDialogCloseButton(),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 32,
                        ),
                        child: Text(
                          e.toString(),
                          textAlign: TextAlign.left,
                          style: STextStyles.desktopTextExtraExtraSmall(context)
                              .copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SecondaryButton(
                              buttonHeight: ButtonHeight.l,
                              label: "Ok",
                              onPressed: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 32,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    }
  }

  void _cryptoAmountChanged() async {
    if (!_cryptoAmountChangeLock) {
      final String cryptoAmount = cryptoAmountController.text;
      if (cryptoAmount.isNotEmpty &&
          cryptoAmount != "." &&
          cryptoAmount != ",") {
        _amountToSend = cryptoAmount.contains(",")
            ? Decimal.parse(cryptoAmount.replaceFirst(",", "."))
                .toAmount(fractionDigits: coin.decimals)
            : Decimal.parse(cryptoAmount)
                .toAmount(fractionDigits: coin.decimals);
        if (_cachedAmountToSend != null &&
            _cachedAmountToSend == _amountToSend) {
          return;
        }
        Logging.instance.log("it changed $_amountToSend $_cachedAmountToSend",
            level: LogLevel.Info);
        _cachedAmountToSend = _amountToSend;

        final price =
            ref.read(priceAnd24hChangeNotifierProvider).getPrice(coin).item1;

        if (price > Decimal.zero) {
          final String fiatAmountString = (_amountToSend!.decimal * price)
              .toAmount(fractionDigits: 2)
              .localizedStringAsFixed(
                locale: ref.read(localeServiceChangeNotifierProvider).locale,
              );

          baseAmountController.text = fiatAmountString;
        }
      } else {
        _amountToSend = null;
        _cachedAmountToSend = null;
        baseAmountController.text = "";
      }

      _updatePreviewButtonState(_address, _amountToSend);
    }
  }

  String? _updateInvalidAddressText(String address, Manager manager) {
    if (_data != null && _data!.contactLabel == address) {
      return null;
    }
    if (address.isNotEmpty && !manager.validateAddress(address)) {
      return "Invalid address";
    }
    return null;
  }

  void _updatePreviewButtonState(String? address, Amount? amount) {
    if (isPaynymSend) {
      ref.read(previewTxButtonStateProvider.state).state =
          (amount != null && amount > Amount.zero);
    } else {
      final isValidAddress = ref
          .read(walletsChangeNotifierProvider)
          .getManager(walletId)
          .validateAddress(address ?? "");
      ref.read(previewTxButtonStateProvider.state).state =
          (isValidAddress && amount != null && amount > Amount.zero);
    }
  }

  Widget firoBalanceFutureBuilder(
    BuildContext context,
    AsyncSnapshot<String?> snapshot,
    bool private,
  ) {
    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
      if (private) {
        _privateBalanceString = snapshot.data!;
      } else {
        _publicBalanceString = snapshot.data!;
      }
    }
    if (private && _privateBalanceString != null) {
      return Text(
        "$_privateBalanceString ${coin.ticker}",
        style: STextStyles.itemSubtitle(context),
      );
    } else if (!private && _publicBalanceString != null) {
      return Text(
        "$_publicBalanceString ${coin.ticker}",
        style: STextStyles.itemSubtitle(context),
      );
    } else {
      return AnimatedText(
        stringsToLoopThrough: const [
          "Loading balance",
          "Loading balance.",
          "Loading balance..",
          "Loading balance...",
        ],
        style: STextStyles.itemSubtitle(context),
      );
    }
  }

  Future<void> scanQr() async {
    try {
      if (FocusScope.of(context).hasFocus) {
        FocusScope.of(context).unfocus();
        await Future<void>.delayed(const Duration(milliseconds: 75));
      }

      final qrResult = await scanner.scan();

      Logging.instance.log("qrResult content: ${qrResult.rawContent}",
          level: LogLevel.Info);

      final results = AddressUtils.parseUri(qrResult.rawContent);

      Logging.instance.log("qrResult parsed: $results", level: LogLevel.Info);

      if (results.isNotEmpty && results["scheme"] == coin.uriScheme) {
        // auto fill address
        _address = results["address"] ?? "";
        sendToController.text = _address!;

        // autofill notes field
        if (results["message"] != null) {
          _note = results["message"]!;
        } else if (results["label"] != null) {
          _note = results["label"]!;
        }

        // autofill amount field
        if (results["amount"] != null) {
          final amount = Decimal.parse(results["amount"]!).toAmount(
            fractionDigits: coin.decimals,
          );
          cryptoAmountController.text = amount.localizedStringAsFixed(
            locale: ref.read(localeServiceChangeNotifierProvider).locale,
            decimalPlaces: Constants.decimalPlacesForCoin(coin),
          );
          amount.toString();
          _amountToSend = amount;
        }

        _updatePreviewButtonState(_address, _amountToSend);
        setState(() {
          _addressToggleFlag = sendToController.text.isNotEmpty;
        });

        // now check for non standard encoded basic address
      } else if (ref
          .read(walletsChangeNotifierProvider)
          .getManager(walletId)
          .validateAddress(qrResult.rawContent)) {
        _address = qrResult.rawContent;
        sendToController.text = _address ?? "";

        _updatePreviewButtonState(_address, _amountToSend);
        setState(() {
          _addressToggleFlag = sendToController.text.isNotEmpty;
        });
      }
    } on PlatformException catch (e, s) {
      // here we ignore the exception caused by not giving permission
      // to use the camera to scan a qr code
      Logging.instance.log(
          "Failed to get camera permissions while trying to scan qr code in SendView: $e\n$s",
          level: LogLevel.Warning);
    }
  }

  Future<void> pasteAddress() async {
    final ClipboardData? data = await clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      String content = data.text!.trim();
      if (content.contains("\n")) {
        content = content.substring(0, content.indexOf("\n"));
      }

      sendToController.text = content;
      _address = content;

      _updatePreviewButtonState(_address, _amountToSend);
      setState(() {
        _addressToggleFlag = sendToController.text.isNotEmpty;
      });
    }
  }

  void fiatTextFieldOnChanged(String baseAmountString) {
    if (baseAmountString.isNotEmpty &&
        baseAmountString != "." &&
        baseAmountString != ",") {
      final baseAmount = baseAmountString.contains(",")
          ? Decimal.parse(baseAmountString.replaceFirst(",", "."))
              .toAmount(fractionDigits: 2)
          : Decimal.parse(baseAmountString).toAmount(fractionDigits: 2);

      var _price =
          ref.read(priceAnd24hChangeNotifierProvider).getPrice(coin).item1;

      if (_price == Decimal.zero) {
        _amountToSend = Decimal.zero.toAmount(fractionDigits: coin.decimals);
      } else {
        _amountToSend = baseAmount <= Amount.zero
            ? Decimal.zero.toAmount(fractionDigits: coin.decimals)
            : (baseAmount.decimal / _price)
                .toDecimal(scaleOnInfinitePrecision: coin.decimals)
                .toAmount(fractionDigits: coin.decimals);
      }
      if (_cachedAmountToSend != null && _cachedAmountToSend == _amountToSend) {
        return;
      }
      _cachedAmountToSend = _amountToSend;
      Logging.instance.log("it changed $_amountToSend $_cachedAmountToSend",
          level: LogLevel.Info);

      final amountString = _amountToSend!.localizedStringAsFixed(
        locale: ref.read(localeServiceChangeNotifierProvider).locale,
        decimalPlaces: coin.decimals,
      );

      _cryptoAmountChangeLock = true;
      cryptoAmountController.text = amountString;
      _cryptoAmountChangeLock = false;
    } else {
      _amountToSend = Decimal.zero.toAmount(fractionDigits: coin.decimals);
      _cryptoAmountChangeLock = true;
      cryptoAmountController.text = "";
      _cryptoAmountChangeLock = false;
    }
    // setState(() {
    //   _calculateFeesFuture = calculateFees(
    //       Format.decimalAmountToSatoshis(
    //           _amountToSend!));
    // });
    _updatePreviewButtonState(_address, _amountToSend);
  }

  Future<void> sendAllTapped() async {
    cryptoAmountController.text = ref
        .read(walletsChangeNotifierProvider)
        .getManager(walletId)
        .balance
        .spendable
        .decimal
        .toStringAsFixed(coin.decimals);
  }

  void _showDesktopCoinControl() async {
    await showDialog<void>(
      context: context,
      builder: (context) => DesktopCoinControlUseDialog(
        walletId: widget.walletId,
        amountToSend: _amountToSend,
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(feeSheetSessionCacheProvider);
      ref.read(previewTxButtonStateProvider.state).state = false;
    });

    // _calculateFeesFuture = calculateFees(0);
    _data = widget.autoFillData;
    walletId = widget.walletId;
    coin = ref.read(walletsChangeNotifierProvider).getManager(walletId).coin;
    clipboard = widget.clipboard;
    scanner = widget.barcodeScanner;

    sendToController = TextEditingController();
    cryptoAmountController = TextEditingController();
    baseAmountController = TextEditingController();
    // feeController = TextEditingController();

    onCryptoAmountChanged = _cryptoAmountChanged;
    cryptoAmountController.addListener(onCryptoAmountChanged);

    if (_data != null) {
      if (_data!.amount != null) {
        cryptoAmountController.text = _data!.amount!.toString();
      }
      sendToController.text = _data!.contactLabel;
      _address = _data!.address;
      _addressToggleFlag = true;
    }

    if (isPaynymSend) {
      sendToController.text = widget.accountLite!.nymName;
    }

    _cryptoFocus.addListener(() {
      if (!_cryptoFocus.hasFocus && !_baseFocus.hasFocus) {
        if (_amountToSend == null) {
          ref.refresh(sendAmountProvider);
        } else {
          ref.read(sendAmountProvider.state).state = _amountToSend!;
        }
      }
    });

    _baseFocus.addListener(() {
      if (!_cryptoFocus.hasFocus && !_baseFocus.hasFocus) {
        if (_amountToSend == null) {
          ref.refresh(sendAmountProvider);
        } else {
          ref.read(sendAmountProvider.state).state = _amountToSend!;
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    cryptoAmountController.removeListener(onCryptoAmountChanged);

    sendToController.dispose();
    cryptoAmountController.dispose();
    baseAmountController.dispose();
    // feeController.dispose();

    _addressFocusNode.dispose();
    _cryptoFocus.dispose();
    _baseFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD: $runtimeType");
    final provider = ref.watch(walletsChangeNotifierProvider
        .select((value) => value.getManagerProvider(walletId)));
    final String locale = ref.watch(
        localeServiceChangeNotifierProvider.select((value) => value.locale));

    final showCoinControl = ref.watch(
          prefsChangeNotifierProvider.select(
            (value) => value.enableCoinControl,
          ),
        ) &&
        ref.watch(
          provider.select(
            (value) => value.hasCoinControlSupport,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 4,
        ),
        if (isPaynymSend)
          Text(
            "Send to PayNym address",
            style: STextStyles.smallMed12(context),
            textAlign: TextAlign.left,
          ),
        if (isPaynymSend)
          const SizedBox(
            height: 10,
          ),
        if (isPaynymSend)
          TextField(
            key: const Key("sendViewPaynymAddressFieldKey"),
            controller: sendToController,
            enabled: false,
            readOnly: true,
            style: STextStyles.desktopTextFieldLabel(context).copyWith(
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
          ),
        if (isPaynymSend)
          const SizedBox(
            height: 20,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Amount",
              style: STextStyles.desktopTextExtraSmall(context).copyWith(
                color: Theme.of(context)
                    .extension<StackColors>()!
                    .textFieldActiveSearchIconRight,
              ),
              textAlign: TextAlign.left,
            ),
            CustomTextButton(
              text: "Send all ${coin.ticker}",
              onTap: sendAllTapped,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        TextField(
          autocorrect: Util.isDesktop ? false : true,
          enableSuggestions: Util.isDesktop ? false : true,
          style: STextStyles.smallMed14(context).copyWith(
            color: Theme.of(context).extension<StackColors>()!.textDark,
          ),
          key: const Key("amountInputFieldCryptoTextFieldKey"),
          controller: cryptoAmountController,
          focusNode: _cryptoFocus,
          keyboardType: Util.isDesktop
              ? null
              : const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
          textAlign: TextAlign.right,
          inputFormatters: [
            // regex to validate a crypto amount with 8 decimal places
            TextInputFormatter.withFunction((oldValue, newValue) =>
                RegExp(r'^([0-9]*[,.]?[0-9]{0,8}|[,.][0-9]{0,8})$')
                        .hasMatch(newValue.text)
                    ? newValue
                    : oldValue),
          ],
          onChanged: (newValue) {},
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
              top: 22,
              right: 12,
              bottom: 22,
            ),
            hintText: "0",
            hintStyle: STextStyles.desktopTextExtraSmall(context).copyWith(
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .textFieldDefaultText,
            ),
            prefixIcon: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  coin.ticker,
                  style: STextStyles.smallMed14(context).copyWith(
                      color: Theme.of(context)
                          .extension<StackColors>()!
                          .accentColorDark),
                ),
              ),
            ),
          ),
        ),
        if (Prefs.instance.externalCalls)
          const SizedBox(
            height: 10,
          ),
        if (Prefs.instance.externalCalls)
          TextField(
            autocorrect: Util.isDesktop ? false : true,
            enableSuggestions: Util.isDesktop ? false : true,
            style: STextStyles.smallMed14(context).copyWith(
              color: Theme.of(context).extension<StackColors>()!.textDark,
            ),
            key: const Key("amountInputFieldFiatTextFieldKey"),
            controller: baseAmountController,
            focusNode: _baseFocus,
            keyboardType: Util.isDesktop
                ? null
                : const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
            textAlign: TextAlign.right,
            inputFormatters: [
              // regex to validate a fiat amount with 2 decimal places
              TextInputFormatter.withFunction((oldValue, newValue) =>
                  RegExp(r'^([0-9]*[,.]?[0-9]{0,2}|[,.][0-9]{0,2})$')
                          .hasMatch(newValue.text)
                      ? newValue
                      : oldValue),
            ],
            onChanged: fiatTextFieldOnChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                top: 22,
                right: 12,
                bottom: 22,
              ),
              hintText: "0",
              hintStyle: STextStyles.desktopTextExtraSmall(context).copyWith(
                color: Theme.of(context)
                    .extension<StackColors>()!
                    .textFieldDefaultText,
              ),
              prefixIcon: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    ref.watch(prefsChangeNotifierProvider
                        .select((value) => value.currency)),
                    style: STextStyles.smallMed14(context).copyWith(
                        color: Theme.of(context)
                            .extension<StackColors>()!
                            .accentColorDark),
                  ),
                ),
              ),
            ),
          ),
        if (showCoinControl)
          const SizedBox(
            height: 10,
          ),
        if (showCoinControl)
          RoundedContainer(
            color: Colors.transparent,
            borderColor:
                Theme.of(context).extension<StackColors>()!.textFieldDefaultBG,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Coin control",
                  style: STextStyles.desktopTextExtraExtraSmall(context),
                ),
                CustomTextButton(
                  text: ref.watch(desktopUseUTXOs.state).state.isEmpty
                      ? "Select coins"
                      : "Selected coins (${ref.watch(desktopUseUTXOs.state).state.length})",
                  onTap: _showDesktopCoinControl,
                ),
              ],
            ),
          ),
        const SizedBox(
          height: 20,
        ),
        if (!isPaynymSend)
          Text(
            "Send to",
            style: STextStyles.desktopTextExtraSmall(context).copyWith(
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .textFieldActiveSearchIconRight,
            ),
            textAlign: TextAlign.left,
          ),
        if (!isPaynymSend)
          const SizedBox(
            height: 10,
          ),
        if (!isPaynymSend)
          ClipRRect(
            borderRadius: BorderRadius.circular(
              Constants.size.circularBorderRadius,
            ),
            child: TextField(
              minLines: 1,
              maxLines: 5,
              key: const Key("sendViewAddressFieldKey"),
              controller: sendToController,
              readOnly: false,
              autocorrect: false,
              enableSuggestions: false,
              // inputFormatters: <TextInputFormatter>[
              //   FilteringTextInputFormatter.allow(
              //       RegExp("[a-zA-Z0-9]{34}")),
              // ],
              toolbarOptions: const ToolbarOptions(
                copy: false,
                cut: false,
                paste: true,
                selectAll: false,
              ),
              onChanged: (newValue) {
                _address = newValue;
                _updatePreviewButtonState(_address, _amountToSend);

                setState(() {
                  _addressToggleFlag = newValue.isNotEmpty;
                });
              },
              focusNode: _addressFocusNode,
              style: STextStyles.desktopTextExtraSmall(context).copyWith(
                color: Theme.of(context)
                    .extension<StackColors>()!
                    .textFieldActiveText,
                height: 1.8,
              ),
              decoration: standardInputDecoration(
                "Enter ${coin.ticker} address",
                _addressFocusNode,
                context,
                desktopMed: true,
              ).copyWith(
                contentPadding: const EdgeInsets.only(
                  left: 16,
                  top: 11,
                  bottom: 12,
                  right: 5,
                ),
                suffixIcon: Padding(
                  padding: sendToController.text.isEmpty
                      ? const EdgeInsets.only(right: 8)
                      : const EdgeInsets.only(right: 0),
                  child: UnconstrainedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _addressToggleFlag
                            ? TextFieldIconButton(
                                key: const Key(
                                    "sendViewClearAddressFieldButtonKey"),
                                onTap: () {
                                  sendToController.text = "";
                                  _address = "";
                                  _updatePreviewButtonState(
                                      _address, _amountToSend);
                                  setState(() {
                                    _addressToggleFlag = false;
                                  });
                                },
                                child: const XIcon(),
                              )
                            : TextFieldIconButton(
                                key: const Key(
                                    "sendViewPasteAddressFieldButtonKey"),
                                onTap: pasteAddress,
                                child: sendToController.text.isEmpty
                                    ? const ClipboardIcon()
                                    : const XIcon(),
                              ),
                        if (sendToController.text.isEmpty)
                          TextFieldIconButton(
                            key: const Key("sendViewAddressBookButtonKey"),
                            onTap: () async {
                              final entry =
                                  await showDialog<ContactAddressEntry?>(
                                context: context,
                                builder: (context) => DesktopDialog(
                                  maxWidth: 696,
                                  maxHeight: 600,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 32,
                                            ),
                                            child: Text(
                                              "Address book",
                                              style: STextStyles.desktopH3(
                                                  context),
                                            ),
                                          ),
                                          const DesktopDialogCloseButton(),
                                        ],
                                      ),
                                      Expanded(
                                        child: AddressBookAddressChooser(
                                          coin: coin,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (entry != null) {
                                sendToController.text =
                                    entry.other ?? entry.label;

                                _address = entry.address;

                                _updatePreviewButtonState(
                                  _address,
                                  _amountToSend,
                                );

                                setState(() {
                                  _addressToggleFlag = true;
                                });
                              }
                            },
                            child: const AddressBookIcon(),
                          ),
                        // if (sendToController.text.isEmpty)
                        //   TextFieldIconButton(
                        //     key: const Key("sendViewScanQrButtonKey"),
                        //     onTap: scanQr,
                        //     child: const QrCodeIcon(),
                        //   )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (!isPaynymSend)
          Builder(
            builder: (_) {
              final error = _updateInvalidAddressText(
                _address ?? "",
                ref.read(walletsChangeNotifierProvider).getManager(walletId),
              );

              if (error == null || error.isEmpty) {
                return Container();
              } else {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      top: 4.0,
                    ),
                    child: Text(
                      error,
                      textAlign: TextAlign.left,
                      style: STextStyles.label(context).copyWith(
                        color: Theme.of(context)
                            .extension<StackColors>()!
                            .textError,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        // const SizedBox(
        //   height: 20,
        // ),
        // Text(
        //   "Note (optional)",
        //   style: STextStyles.desktopTextExtraSmall(context).copyWith(
        //     color: Theme.of(context)
        //         .extension<StackColors>()!
        //         .textFieldActiveSearchIconRight,
        //   ),
        //   textAlign: TextAlign.left,
        // ),
        // const SizedBox(
        //   height: 10,
        // ),
        // ClipRRect(
        //   borderRadius: BorderRadius.circular(
        //     Constants.size.circularBorderRadius,
        //   ),
        //   child: TextField(
        //     minLines: 1,
        //     maxLines: 5,
        //     autocorrect: Util.isDesktop ? false : true,
        //     enableSuggestions: Util.isDesktop ? false : true,
        //     controller: noteController,
        //     focusNode: _noteFocusNode,
        //     style: STextStyles.desktopTextExtraSmall(context).copyWith(
        //       color: Theme.of(context)
        //           .extension<StackColors>()!
        //           .textFieldActiveText,
        //       height: 1.8,
        //     ),
        //     onChanged: (_) => setState(() {}),
        //     decoration: standardInputDecoration(
        //       "Type something...",
        //       _noteFocusNode,
        //       context,
        //       desktopMed: true,
        //     ).copyWith(
        //       contentPadding: const EdgeInsets.only(
        //         left: 16,
        //         top: 11,
        //         bottom: 12,
        //         right: 5,
        //       ),
        //       suffixIcon: noteController.text.isNotEmpty
        //           ? Padding(
        //               padding: const EdgeInsets.only(right: 0),
        //               child: UnconstrainedBox(
        //                 child: Row(
        //                   children: [
        //                     TextFieldIconButton(
        //                       child: const XIcon(),
        //                       onTap: () async {
        //                         setState(() {
        //                           noteController.text = "";
        //                         });
        //                       },
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             )
        //           : null,
        //     ),
        //   ),
        // ),
        if (!isPaynymSend)
          const SizedBox(
            height: 20,
          ),
        const SizedBox(
          height: 36,
        ),
        PrimaryButton(
          buttonHeight: ButtonHeight.l,
          label: "Preview send",
          enabled: ref.watch(previewTxButtonStateProvider.state).state,
          onPressed: ref.watch(previewTxButtonStateProvider.state).state
              ? previewSend
              : null,
        )
      ],
    );
  }
}

String formatAddress(String epicAddress) {
  // strip http:// or https:// prefixes if the address contains an @ symbol (and is thus an epicbox address)
  if ((epicAddress.startsWith("http://") ||
          epicAddress.startsWith("https://")) &&
      epicAddress.contains("@")) {
    epicAddress = epicAddress.replaceAll("http://", "");
    epicAddress = epicAddress.replaceAll("https://", "");
  }
  // strip mailto: prefix
  if (epicAddress.startsWith("mailto:")) {
    epicAddress = epicAddress.replaceAll("mailto:", "");
  }
  // strip / suffix if the address contains an @ symbol (and is thus an epicbox address)
  if (epicAddress.endsWith("/") && epicAddress.contains("@")) {
    epicAddress = epicAddress.substring(0, epicAddress.length - 1);
  }
  return epicAddress;
}
