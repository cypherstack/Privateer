import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stackduo/models/exchange/incomplete_exchange.dart';
import 'package:stackduo/models/exchange/response_objects/trade.dart';
import 'package:stackduo/pages/exchange_view/send_from_view.dart';
import 'package:stackduo/pages_desktop_specific/desktop_exchange/exchange_steps/subwidgets/desktop_step_1.dart';
import 'package:stackduo/pages_desktop_specific/desktop_exchange/exchange_steps/subwidgets/desktop_step_2.dart';
import 'package:stackduo/pages_desktop_specific/desktop_exchange/exchange_steps/subwidgets/desktop_step_3.dart';
import 'package:stackduo/pages_desktop_specific/desktop_exchange/exchange_steps/subwidgets/desktop_step_4.dart';
import 'package:stackduo/pages_desktop_specific/desktop_exchange/subwidgets/desktop_exchange_steps_indicator.dart';
import 'package:stackduo/providers/exchange/exchange_form_state_provider.dart';
import 'package:stackduo/providers/global/trades_service_provider.dart';
import 'package:stackduo/route_generator.dart';
import 'package:stackduo/services/exchange/exchange_response.dart';
import 'package:stackduo/services/notifications_api.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/enums/exchange_rate_type_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/custom_loading_overlay.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog_close_button.dart';
import 'package:stackduo/widgets/desktop/primary_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/desktop/simple_desktop_dialog.dart';
import 'package:stackduo/widgets/fade_stack.dart';

final ssss = StateProvider<IncompleteExchangeModel?>((_) => null);

final desktopExchangeModelProvider =
    ChangeNotifierProvider<IncompleteExchangeModel?>(
        (ref) => ref.watch(ssss.state).state);

class StepScaffold extends ConsumerStatefulWidget {
  const StepScaffold({
    Key? key,
    required this.initialStep,
  }) : super(key: key);

  final int initialStep;

  @override
  ConsumerState<StepScaffold> createState() => _StepScaffoldState();
}

class _StepScaffoldState extends ConsumerState<StepScaffold> {
  int currentStep = 1;
  bool enableNext = false;

  late final Duration duration;

  void updateEnableNext(bool enableNext) {
    if (enableNext != this.enableNext) {
      setState(() => this.enableNext = enableNext);
    }
  }

  Future<bool> createTrade() async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: Container(
            color: Theme.of(context)
                .extension<StackColors>()!
                .overlay
                .withOpacity(0.6),
            child: const CustomLoadingOverlay(
              message: "Creating a trade",
              eventBus: null,
            ),
          ),
        ),
      ),
    );

    final ExchangeResponse<Trade> response = await ref
        .read(efExchangeProvider)
        .createTrade(
          from: ref.read(desktopExchangeModelProvider)!.sendTicker,
          to: ref.read(desktopExchangeModelProvider)!.receiveTicker,
          fixedRate: ref.read(desktopExchangeModelProvider)!.rateType !=
              ExchangeRateType.estimated,
          amount: ref.read(desktopExchangeModelProvider)!.reversed
              ? ref.read(desktopExchangeModelProvider)!.receiveAmount
              : ref.read(desktopExchangeModelProvider)!.sendAmount,
          addressTo: ref.read(desktopExchangeModelProvider)!.recipientAddress!,
          extraId: null,
          addressRefund: ref.read(desktopExchangeModelProvider)!.refundAddress!,
          refundExtraId: "",
          estimate: ref.read(desktopExchangeModelProvider)!.estimate,
          reversed: ref.read(desktopExchangeModelProvider)!.reversed,
        );

    if (response.value == null) {
      if (mounted) {
        Navigator.of(context).pop();

        unawaited(
          showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => SimpleDesktopDialog(
                title: "Failed to create trade",
                message: response.exception?.toString() ?? ""),
          ),
        );
      }
      return false;
    }

    // save trade to hive
    await ref.read(tradesServiceProvider).add(
          trade: response.value!,
          shouldNotifyListeners: true,
        );

    String status = response.value!.status;

    ref.read(desktopExchangeModelProvider)!.trade = response.value!;

    // extra info if status is waiting
    if (status == "Waiting") {
      status += " for deposit";
    }

    if (mounted) {
      Navigator.of(context).pop();
    }

    unawaited(
      NotificationApi.showNotification(
        changeNowId: ref.read(desktopExchangeModelProvider)!.trade!.tradeId,
        title: status,
        body:
            "Trade ID ${ref.read(desktopExchangeModelProvider)!.trade!.tradeId}",
        walletId: "",
        iconAssetName: Assets.svg.arrowRotate,
        date: ref.read(desktopExchangeModelProvider)!.trade!.timestamp,
        shouldWatchForUpdates: true,
        coinName: "coinName",
      ),
    );

    return true;
    // if (mounted) {
    //   unawaited(
    //     showDialog<void>(
    //       context: context,
    //       barrierColor: Colors.transparent,
    //       barrierDismissible: false,
    //       builder: (context) {
    //         return DesktopDialog(
    //           maxWidth: 720,
    //           maxHeight: double.infinity,
    //           child: StepScaffold(
    //             initialStep: 4,
    //           ),
    //         );
    //       },
    //     ),
    //   );
    // }
  }

  void onBack() {
    if (currentStep > 1 && currentStep < 4) {
      setState(() => currentStep = currentStep - 1);
    } else if (currentStep == 1) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void sendFromStack() {
    final trade = ref.read(desktopExchangeModelProvider)!.trade!;
    final address = trade.payInAddress;
    final coin = coinFromTickerCaseInsensitive(trade.payInCurrency);
    final amount = Decimal.parse(trade.payInAmount).toAmount(
      fractionDigits: coin.decimals,
    );

    showDialog<void>(
      context: context,
      builder: (context) => Navigator(
        initialRoute: SendFromView.routeName,
        onGenerateRoute: RouteGenerator.generateRoute,
        onGenerateInitialRoutes: (_, __) {
          return [
            FadePageRoute(
              SendFromView(
                coin: coin,
                trade: trade,
                amount: amount,
                address: address,
                shouldPopRoot: true,
                fromDesktopStep4: true,
              ),
              const RouteSettings(
                name: SendFromView.routeName,
              ),
            ),
          ];
        },
      ),
    );
  }

  @override
  void initState() {
    duration = const Duration(milliseconds: 250);
    currentStep = widget.initialStep;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(desktopExchangeModelProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                currentStep != 4
                    ? AppBarBackButton(
                        isCompact: true,
                        iconSize: 23,
                        onPressed: onBack,
                      )
                    : const SizedBox(
                        width: 32,
                      ),
                Text(
                  "Exchange ${model?.sendTicker.toUpperCase()} to ${model?.receiveTicker.toUpperCase()}",
                  style: STextStyles.desktopH3(context),
                ),
              ],
            ),
            if (currentStep == 4)
              DesktopDialogCloseButton(
                onPressedOverride: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: DesktopExchangeStepsIndicator(
            currentStep: currentStep,
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: FadeStack(
            index: currentStep - 1,
            children: [
              const DesktopStep1(),
              DesktopStep2(
                enableNextChanged: updateEnableNext,
              ),
              const DesktopStep3(),
              const DesktopStep4(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 32,
            right: 32,
            bottom: 32,
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: currentStep == 4
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: SecondaryButton(
                    label: "Back",
                    buttonHeight: ButtonHeight.l,
                    onPressed: onBack,
                  ),
                  secondChild: SecondaryButton(
                    label: "Send from Stack Duo",
                    buttonHeight: ButtonHeight.l,
                    onPressed: sendFromStack,
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: currentStep == 4
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: currentStep == 3
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: PrimaryButton(
                      label: "Next",
                      enabled: currentStep != 2 ? true : enableNext,
                      buttonHeight: ButtonHeight.l,
                      onPressed: () async {
                        setState(() => currentStep = currentStep + 1);
                      },
                    ),
                    secondChild: PrimaryButton(
                      label: "Confirm",
                      enabled: currentStep != 2 ? true : enableNext,
                      buttonHeight: ButtonHeight.l,
                      onPressed: () async {
                        if (currentStep == 3) {
                          final success = await createTrade();
                          if (!success) {
                            return;
                          }
                        }
                        setState(() => currentStep = currentStep + 1);
                      },
                    ),
                  ),
                  secondChild: PrimaryButton(
                    label: "Show QR code",
                    enabled: currentStep != 2 ? true : enableNext,
                    buttonHeight: ButtonHeight.l,
                    onPressed: () {
                      showDialog<dynamic>(
                        context: context,
                        barrierColor: Colors.transparent,
                        barrierDismissible: true,
                        builder: (_) {
                          return DesktopDialog(
                            maxHeight: 720,
                            maxWidth: 720,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Send ${ref.watch(desktopExchangeModelProvider.select((value) => value!.sendAmount.toStringAsFixed(8)))} ${ref.watch(desktopExchangeModelProvider.select((value) => value!.sendTicker))} to this address",
                                  style: STextStyles.desktopH3(context),
                                ),
                                const SizedBox(
                                  height: 48,
                                ),
                                Center(
                                  child: QrImage(
                                    // TODO: grab coin uri scheme from somewhere
                                    // data: "${coin.uriScheme}:$receivingAddress",
                                    data: ref.watch(desktopExchangeModelProvider
                                        .select((value) =>
                                            value!.trade!.payInAddress)),
                                    size: 290,
                                    foregroundColor: Theme.of(context)
                                        .extension<StackColors>()!
                                        .accentColorDark,
                                  ),
                                ),
                                const SizedBox(
                                  height: 48,
                                ),
                                SecondaryButton(
                                  label: "Cancel",
                                  width: 310,
                                  buttonHeight: ButtonHeight.l,
                                  onPressed: Navigator.of(context).pop,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
