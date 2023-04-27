import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/services/coins/manager.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/background.dart';
import 'package:stackduo/widgets/conditional_parent.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/icon_widgets/x_icon.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';
import 'package:stackduo/widgets/stack_text_field.dart';
import 'package:stackduo/widgets/textfield_icon_button.dart';
import 'package:stackduo/widgets/wallet_card.dart';
import 'package:tuple/tuple.dart';

class WalletsOverview extends ConsumerStatefulWidget {
  const WalletsOverview({
    Key? key,
    required this.coin,
    this.navigatorState,
  }) : super(key: key);

  final Coin coin;
  final NavigatorState? navigatorState;

  static const routeName = "/walletsOverview";

  @override
  ConsumerState<WalletsOverview> createState() => _EthWalletsOverviewState();
}

class _EthWalletsOverviewState extends ConsumerState<WalletsOverview> {
  final isDesktop = Util.isDesktop;

  late final TextEditingController _searchController;
  late final FocusNode searchFieldFocusNode;

  String _searchString = "";

  final List<Tuple2<Manager, List<dynamic>>> wallets = [];

  List<Tuple2<Manager, List<dynamic>>> _filter(String searchTerm) {
    if (searchTerm.isEmpty) {
      return wallets;
    }

    final List<Tuple2<Manager, List<dynamic>>> results = [];
    final term = searchTerm.toLowerCase();

    for (final tuple in wallets) {
      bool includeManager = false;
      // search wallet name and total balance
      includeManager |= _elementContains(tuple.item1.walletName, term);
      includeManager |= _elementContains(
        tuple.item1.balance.total.decimal.toString(),
        term,
      );

      if (includeManager) {
        results.add(Tuple2(tuple.item1, []));
      }
    }

    return results;
  }

  bool _elementContains(String element, String term) {
    return element.toLowerCase().contains(term);
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    searchFieldFocusNode = FocusNode();

    final walletsData =
        ref.read(walletsServiceChangeNotifierProvider).fetchWalletsData();
    walletsData.removeWhere((key, value) => value.coin != widget.coin);

    // if (widget.coin == Coin.ethereum) {
    //   for (final data in walletsData.values) {
    //     final List<EthContract> contracts = [];
    //     final manager =
    //         ref.read(walletsChangeNotifierProvider).getManager(data.walletId);
    //     final contractAddresses = (manager.wallet as EthereumWallet)
    //         .getWalletTokenContractAddresses();
    //
    //     // fetch each contract
    //     for (final contractAddress in contractAddresses) {
    //       final contract = ref
    //           .read(
    //             mainDBProvider,
    //           )
    //           .getEthContractSync(
    //             contractAddress,
    //           );
    //
    //       // add it to list if it exists in DB
    //       if (contract != null) {
    //         contracts.add(contract);
    //       }
    //     }
    //
    //     // add tuple to list
    //     wallets.add(
    //       Tuple2(
    //         ref.read(walletsChangeNotifierProvider).getManager(
    //               data.walletId,
    //             ),
    //         contracts,
    //       ),
    //     );
    //   }
    // } else {
    // add non token wallet tuple to list
    for (final data in walletsData.values) {
      wallets.add(
        Tuple2(
          ref.read(walletsChangeNotifierProvider).getManager(
                data.walletId,
              ),
          [],
        ),
      );
    }

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
    return ConditionalParent(
      condition: !isDesktop,
      builder: (child) => Background(
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<StackColors>()!.background,
          appBar: AppBar(
            leading: const AppBarBackButton(),
            title: Text(
              "${widget.coin.prettyName} (${widget.coin.ticker}) wallets",
              style: STextStyles.navBarTitle(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              Constants.size.circularBorderRadius,
            ),
            child: TextField(
              autocorrect: !isDesktop,
              enableSuggestions: !isDesktop,
              controller: _searchController,
              focusNode: searchFieldFocusNode,
              onChanged: (value) {
                setState(() {
                  _searchString = value;
                });
              },
              style: isDesktop
                  ? STextStyles.desktopTextExtraSmall(context).copyWith(
                      color: Theme.of(context)
                          .extension<StackColors>()!
                          .textFieldActiveText,
                      height: 1.8,
                    )
                  : STextStyles.field(context),
              decoration: standardInputDecoration(
                "Search...",
                searchFieldFocusNode,
                context,
                desktopMed: isDesktop,
              ).copyWith(
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 12 : 10,
                    vertical: isDesktop ? 18 : 16,
                  ),
                  child: SvgPicture.asset(
                    Assets.svg.search,
                    width: isDesktop ? 20 : 16,
                    height: isDesktop ? 20 : 16,
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
                                    _searchString = "";
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
          Expanded(
            child: Builder(
              builder: (context) {
                final data = _filter(_searchString);
                return ListView.separated(
                  itemBuilder: (_, index) {
                    final element = data[index];

                    // if (element.item1.hasTokenSupport) {
                    //   if (isDesktop) {
                    //     return DesktopExpandingWalletCard(
                    //       key: Key(
                    //           "${element.item1.walletName}_${element.item2.map((e) => e.address).join()}"),
                    //       data: element,
                    //       navigatorState: widget.navigatorState!,
                    //     );
                    //   } else {
                    //     return MasterWalletCard(
                    //       walletId: element.item1.walletId,
                    //     );
                    //   }
                    // } else {
                    return ConditionalParent(
                      condition: isDesktop,
                      builder: (child) => RoundedWhiteContainer(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        borderColor: Theme.of(context)
                            .extension<StackColors>()!
                            .backgroundAppBar,
                        child: child,
                      ),
                      child: SimpleWalletCard(
                        walletId: element.item1.walletId,
                        popPrevious: isDesktop,
                        desktopNavigatorState:
                            isDesktop ? widget.navigatorState : null,
                      ),
                    );
                    // }
                  },
                  separatorBuilder: (_, __) => SizedBox(
                    height: isDesktop ? 10 : 8,
                  ),
                  itemCount: data.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
