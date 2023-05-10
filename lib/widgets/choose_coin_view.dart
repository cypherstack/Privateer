import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/providers/global/node_service_provider.dart';
import 'package:stackduo/providers/global/prefs_provider.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'background.dart';
import 'custom_buttons/app_bar_icon_button.dart';

class ChooseCoinView extends ConsumerStatefulWidget {
  const ChooseCoinView({
    Key? key,
    required this.title,
    required this.coinAdditional,
    required this.nextRouteName,
  }) : super(key: key);

  static const String routeName = "/chooseCoin";

  final String title;
  final String coinAdditional;
  final String nextRouteName;

  @override
  ConsumerState<ChooseCoinView> createState() => _ChooseCoinViewState();
}

class _ChooseCoinViewState extends ConsumerState<ChooseCoinView> {
  List<Coin> _coins = [...Coin.values];

  @override
  void initState() {
    _coins = _coins.toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showTestNet = ref.watch(
      prefsChangeNotifierProvider.select((value) => value.showTestNetCoins),
    );

    List<Coin> coins = showTestNet
        ? _coins
        : _coins.sublist(0, _coins.length - kTestNetCoinCount);

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
            widget.title ?? "Choose Coin",
            style: STextStyles.navBarTitle(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            top: 12,
            left: 12,
            right: 12,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...coins.map(
                      (coin) {
                    final count = ref
                        .watch(nodeServiceChangeNotifierProvider
                        .select((value) => value.getNodesFor(coin)))
                        .length;

                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: RoundedWhiteContainer(
                        padding: const EdgeInsets.all(0),
                        child: RawMaterialButton(
                          // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Constants.size.circularBorderRadius,
                            ),
                          ),
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              widget.nextRouteName,
                              arguments: coin,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  Assets.svg.iconFor(coin: coin),
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${coin.prettyName} ${widget.coinAdditional ?? ""}",
                                      style: STextStyles.titleBold12(context),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}