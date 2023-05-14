import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/exchange_rate_type_enum.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/toggle.dart';

class RateTypeToggle extends ConsumerWidget {
  const RateTypeToggle({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  final void Function(ExchangeRateType)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("BUILD: $runtimeType");
    final isDesktop = Util.isDesktop;

    return Toggle(
      onValueChanged: (value) {
        if (value) {
          onChanged?.call(ExchangeRateType.fixed);
        } else {
          onChanged?.call(ExchangeRateType.estimated);
        }
      },
      isOn: ref.watch(efRateTypeProvider) == ExchangeRateType.fixed,
      onColor: isDesktop
          ? Theme.of(context)
              .extension<StackColors>()!
              .rateTypeToggleDesktopColorOn
          : Theme.of(context).extension<StackColors>()!.rateTypeToggleColorOn,
      offColor: isDesktop
          ? Theme.of(context)
              .extension<StackColors>()!
              .rateTypeToggleDesktopColorOff
          : Theme.of(context).extension<StackColors>()!.rateTypeToggleColorOff,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          Constants.size.circularBorderRadius,
        ),
      ),
      onIcon: Assets.svg.lockOpen,
      onText: "Estimate rate",
      offIcon: Assets.svg.lock,
      offText: "Fixed rate",
    );
  }
}
