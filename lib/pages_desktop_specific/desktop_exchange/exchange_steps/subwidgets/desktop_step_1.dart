import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/pages_desktop_specific/desktop_exchange/exchange_steps/step_scaffold.dart';
import 'package:stackduo/pages_desktop_specific/desktop_exchange/exchange_steps/subwidgets/desktop_step_item.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/utilities/enums/exchange_rate_type_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';

class DesktopStep1 extends ConsumerWidget {
  const DesktopStep1({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(
          "Confirm amount",
          style: STextStyles.desktopTextMedium(context),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          "Network fees and other exchange charges are included in the rate.",
          style: STextStyles.desktopTextExtraExtraSmall(context),
        ),
        const SizedBox(
          height: 20,
        ),
        RoundedWhiteContainer(
          borderColor: Theme.of(context).extension<StackColors>()!.background,
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              DesktopStepItem(
                label: "Swap",
                value: ref.watch(exchangeFormStateProvider
                    .select((value) => value.exchange.name)),
              ),
              Container(
                height: 1,
                color: Theme.of(context).extension<StackColors>()!.background,
              ),
              DesktopStepItem(
                label: "You send",
                value:
                    "${ref.watch(desktopExchangeModelProvider.select((value) => value!.sendAmount.toStringAsFixed(8)))} ${ref.watch(desktopExchangeModelProvider.select((value) => value!.sendTicker.toUpperCase()))}",
              ),
              Container(
                height: 1,
                color: Theme.of(context).extension<StackColors>()!.background,
              ),
              DesktopStepItem(
                label: "You receive",
                value:
                    "~${ref.watch(desktopExchangeModelProvider.select((value) => value!.receiveAmount.toStringAsFixed(8)))} ${ref.watch(desktopExchangeModelProvider.select((value) => value!.receiveTicker.toUpperCase()))}",
              ),
              Container(
                height: 1,
                color: Theme.of(context).extension<StackColors>()!.background,
              ),
              DesktopStepItem(
                label: ref.watch(desktopExchangeModelProvider
                            .select((value) => value!.rateType)) ==
                        ExchangeRateType.estimated
                    ? "Estimated rate"
                    : "Fixed rate",
                value: ref.watch(desktopExchangeModelProvider
                    .select((value) => value!.rateInfo)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
