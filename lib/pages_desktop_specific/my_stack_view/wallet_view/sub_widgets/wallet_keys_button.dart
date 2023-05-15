import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/unlock_wallet_keys_desktop.dart';
import 'package:stackduo/route_generator.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';

class WalletKeysButton extends StatelessWidget {
  const WalletKeysButton({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  final String walletId;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1000),
      ),
      onPressed: () {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => Navigator(
            initialRoute: UnlockWalletKeysDesktop.routeName,
            onGenerateRoute: RouteGenerator.generateRoute,
            onGenerateInitialRoutes: (_, __) {
              return [
                RouteGenerator.generateRoute(
                  RouteSettings(
                    name: UnlockWalletKeysDesktop.routeName,
                    arguments: walletId,
                  ),
                )
              ];
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 19,
          horizontal: 32,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.svg.key,
              width: 20,
              height: 20,
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .buttonTextSecondary,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              "Wallet keys",
              style: STextStyles.desktopMenuItemSelected(context),
            )
          ],
        ),
      ),
    );
  }
}
