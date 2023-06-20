import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/pages/add_wallet_views/create_or_restore_wallet_view/create_or_restore_wallet_view.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/text_styles.dart';

class AddWalletNextButton extends ConsumerWidget {
  const AddWalletNextButton({
    Key? key,
    required this.isDesktop,
  }) : super(key: key);

  final bool isDesktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("BUILD: NextButton");
    final selectedCoin =
        ref.watch(addWalletSelectedEntityStateProvider.state).state;

    final enabled = selectedCoin != null;

    return TextButton(
      onPressed: !enabled
          ? null
          : () {
              // if (selectedCoin is EthTokenEntity) {
              //   Navigator.of(context).pushNamed(
              //     SelectWalletForTokenView.routeName,
              //     arguments: selectedCoin,
              //   );
              // } else {
              Navigator.of(context).pushNamed(
                CreateOrRestoreWalletView.routeName,
                arguments: selectedCoin,
              );
              // }
            },
      style: enabled
          ? Theme.of(context)
              .extension<StackColors>()!
              .getPrimaryEnabledButtonStyle(context)
          : Theme.of(context)
              .extension<StackColors>()!
              .getPrimaryDisabledButtonStyle(context),
      child: Text(
        "Next",
        style: isDesktop
            ? enabled
                ? STextStyles.desktopButtonEnabled(context)
                : STextStyles.desktopButtonDisabled(context)
            : STextStyles.button(context),
      ),
    );
  }
}
