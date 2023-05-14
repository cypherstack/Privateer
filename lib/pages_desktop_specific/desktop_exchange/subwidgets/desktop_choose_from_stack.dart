import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/widgets/custom_buttons/blue_text_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/icon_widgets/x_icon.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';
import 'package:stackduo/widgets/stack_text_field.dart';
import 'package:stackduo/widgets/textfield_icon_button.dart';
import 'package:stackduo/widgets/wallet_info_row/sub_widgets/wallet_info_row_coin_icon.dart';
import 'package:tuple/tuple.dart';

class DesktopChooseFromStack extends ConsumerStatefulWidget {
  const DesktopChooseFromStack({
    Key? key,
    required this.coin,
  }) : super(key: key);

  final Coin coin;

  @override
  ConsumerState<DesktopChooseFromStack> createState() =>
      _DesktopChooseFromStackState();
}

class _DesktopChooseFromStackState
    extends ConsumerState<DesktopChooseFromStack> {
  late final TextEditingController _searchController;
  late final FocusNode searchFieldFocusNode;

  String _searchTerm = "";

  List<String> filter(List<String> walletIds, String searchTerm) {
    if (searchTerm.isEmpty) {
      return walletIds;
    }

    final List<String> result = [];
    for (final walletId in walletIds) {
      final manager =
          ref.read(walletsChangeNotifierProvider).getManager(walletId);

      if (manager.walletName.toLowerCase().contains(searchTerm.toLowerCase())) {
        result.add(walletId);
      }
    }

    return result;
  }

  @override
  void initState() {
    searchFieldFocusNode = FocusNode();
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    searchFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose from Stack",
          style: STextStyles.desktopH3(context),
        ),
        const SizedBox(
          height: 28,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(
            Constants.size.circularBorderRadius,
          ),
          child: TextField(
            autocorrect: false,
            enableSuggestions: false,
            controller: _searchController,
            focusNode: searchFieldFocusNode,
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
            style: STextStyles.desktopTextExtraSmall(context).copyWith(
              color: Theme.of(context)
                  .extension<StackColors>()!
                  .textFieldActiveText,
              height: 1.8,
            ),
            decoration: standardInputDecoration(
              "Search",
              searchFieldFocusNode,
              context,
              desktopMed: true,
            ).copyWith(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
                child: SvgPicture.asset(
                  Assets.svg.search,
                  width: 20,
                  height: 20,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: UnconstrainedBox(
                        child: Row(
                          children: [
                            TextFieldIconButton(
                              child: const XIcon(),
                              onTap: () async {
                                setState(() {
                                  _searchController.text = "";
                                  _searchTerm = "";
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Flexible(
          child: Builder(
            builder: (context) {
              List<String> walletIds = ref.watch(
                walletsChangeNotifierProvider.select(
                  (value) => value.getWalletIdsFor(coin: widget.coin),
                ),
              );

              if (walletIds.isEmpty) {
                return Column(
                  children: [
                    RoundedWhiteContainer(
                      borderColor: Theme.of(context)
                          .extension<StackColors>()!
                          .background,
                      child: Center(
                        child: Text(
                          "No ${widget.coin.ticker.toUpperCase()} wallets",
                          style:
                              STextStyles.desktopTextExtraExtraSmall(context),
                        ),
                      ),
                    ),
                  ],
                );
              }

              walletIds = filter(walletIds, _searchTerm);

              return ListView.separated(
                primary: false,
                itemCount: walletIds.length,
                separatorBuilder: (_, __) => const SizedBox(
                  height: 5,
                ),
                itemBuilder: (context, index) {
                  final manager = ref.watch(walletsChangeNotifierProvider
                      .select((value) => value.getManager(walletIds[index])));

                  return RoundedWhiteContainer(
                    borderColor:
                        Theme.of(context).extension<StackColors>()!.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            WalletInfoCoinIcon(coin: widget.coin),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              manager.walletName,
                              style: STextStyles.desktopTextExtraExtraSmall(
                                      context)
                                  .copyWith(
                                color: Theme.of(context)
                                    .extension<StackColors>()!
                                    .textDark,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _BalanceDisplay(
                          walletId: walletIds[index],
                        ),
                        const SizedBox(
                          width: 80,
                        ),
                        CustomTextButton(
                          text: "Select wallet",
                          onTap: () async {
                            final address =
                                await manager.currentReceivingAddress;

                            if (mounted) {
                              Navigator.of(context).pop(
                                Tuple2(
                                  manager.walletName,
                                  address,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const Spacer(),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: SecondaryButton(
                label: "Cancel",
                buttonHeight: ButtonHeight.l,
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _BalanceDisplay extends ConsumerWidget {
  const _BalanceDisplay({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(walletsChangeNotifierProvider
        .select((value) => value.getManager(walletId)));
    final locale = ref.watch(
        localeServiceChangeNotifierProvider.select((value) => value.locale));

    final Amount total = manager.balance.total;

    return Text(
      "${total.localizedStringAsFixed(locale: locale)} "
      "${manager.coin.ticker}",
      style: STextStyles.desktopTextExtraSmall(context).copyWith(
        color: Theme.of(context).extension<StackColors>()!.textSubtitle1,
      ),
      textAlign: TextAlign.right,
    );
  }
}
