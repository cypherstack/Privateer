import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/pages_desktop_specific/desktop_home_view.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/desktop_wallet_view.dart';
import 'package:stackduo/providers/global/wallets_provider.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/widgets/rounded_container.dart';
import 'package:stackduo/widgets/wallet_info_row/wallet_info_row.dart';

class CoinWalletsTable extends ConsumerWidget {
  const CoinWalletsTable({
    Key? key,
    required this.coin,
  }) : super(key: key);

  final Coin coin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletIds = ref.watch(walletsChangeNotifierProvider
        .select((value) => value.getWalletIdsFor(coin: coin)));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).extension<StackColors>()!.popupBG,
        borderRadius: BorderRadius.circular(
          Constants.size.circularBorderRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          // horizontal: 20,
          // vertical: 16,
          horizontal: 6,
          vertical: 6,
        ),
        child: Column(
          children: [
            for (int i = 0; i < walletIds.length; i++)
              Column(
                key: Key("${coin.name}_$runtimeType${walletIds[i]}_key"),
                children: [
                  if (i != 0)
                    const SizedBox(
                      height: 8,
                    ),
                  Stack(
                    children: [
                      WalletInfoRow(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        walletId: walletIds[i],
                      ),
                      Positioned.fill(
                        child: WalletRowHoverOverlay(
                          onPressed: () async {
                            ref.read(currentWalletIdProvider.state).state =
                                walletIds[i];

                            final manager = ref
                                .read(walletsChangeNotifierProvider)
                                .getManager(walletIds[i]);
                            if (manager.coin == Coin.monero) {
                              await manager.initializeExisting();
                            }

                            await Navigator.of(context).pushNamed(
                              DesktopWalletView.routeName,
                              arguments: walletIds[i],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class WalletRowHoverOverlay extends StatefulWidget {
  const WalletRowHoverOverlay({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  State<WalletRowHoverOverlay> createState() => _WalletRowHoverOverlayState();
}

class _WalletRowHoverOverlayState extends State<WalletRowHoverOverlay> {
  late final VoidCallback onPressed;

  bool _hovering = false;

  @override
  void initState() {
    onPressed = widget.onPressed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _hovering ? 0.1 : 0,
          child: RoundedContainer(
            color:
                Theme.of(context).extension<StackColors>()!.buttonBackSecondary,
          ),
        ),
      ),
    );
  }
}
