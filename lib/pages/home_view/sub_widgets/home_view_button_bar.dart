import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';

class HomeViewButtonBar extends ConsumerStatefulWidget {
  const HomeViewButtonBar({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeViewButtonBar> createState() => _HomeViewButtonBarState();
}

class _HomeViewButtonBarState extends ConsumerState<HomeViewButtonBar> {
  // final DateTime _lastRefreshed = DateTime.now();
  // final Duration _refreshInterval = const Duration(hours: 1);

  @override
  void initState() {
    // ref.read(exchangeFormStateProvider).setOnError(
    //       onError: (String message) => showDialog<dynamic>(
    //         context: context,
    //         barrierDismissible: true,
    //         builder: (_) => StackDialog(
    //           title: "Exchange API Call Failed",
    //           message: message,
    //         ),
    //       ),
    //     );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //todo: check if print needed
    // debugPrint("BUILD: HomeViewButtonBar");
    final selectedIndex = ref.watch(homeViewPageIndexStateProvider.state).state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextButton(
            style: selectedIndex == 0
                ? Theme.of(context)
                    .extension<StackColors>()!
                    .getPrimaryEnabledButtonStyle(context)!
                    .copyWith(
                      minimumSize:
                          MaterialStateProperty.all<Size>(const Size(46, 36)),
                    )
                : Theme.of(context)
                    .extension<StackColors>()!
                    .getSecondaryEnabledButtonStyle(context)!
                    .copyWith(
                      minimumSize:
                          MaterialStateProperty.all<Size>(const Size(46, 36)),
                    ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              if (selectedIndex != 0) {
                ref.read(homeViewPageIndexStateProvider.state).state = 0;
              }
            },
            child: Text(
              "Wallets",
              style: STextStyles.button(context).copyWith(
                fontSize: 14,
                color: selectedIndex == 0
                    ? Theme.of(context)
                        .extension<StackColors>()!
                        .buttonTextPrimary
                    : Theme.of(context)
                        .extension<StackColors>()!
                        .buttonTextSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: TextButton(
            style: selectedIndex == 1
                ? Theme.of(context)
                    .extension<StackColors>()!
                    .getPrimaryEnabledButtonStyle(context)!
                    .copyWith(
                      minimumSize:
                          MaterialStateProperty.all<Size>(const Size(46, 36)),
                    )
                : Theme.of(context)
                    .extension<StackColors>()!
                    .getSecondaryEnabledButtonStyle(context)!
                    .copyWith(
                      minimumSize:
                          MaterialStateProperty.all<Size>(const Size(46, 36)),
                    ),
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (selectedIndex != 1) {
                ref.read(homeViewPageIndexStateProvider.state).state = 1;
              }
              // DateTime now = DateTime.now();
              // if (ref.read(prefsChangeNotifierProvider).externalCalls) {
              //   print("loading?");
              // await ExchangeDataLoadingService().loadAll(ref);
              // }
              // if (now.difference(_lastRefreshed) > _refreshInterval) {
              //   await ExchangeDataLoadingService().loadAll(ref);
              // }
            },
            child: Text(
              "Swap",
              style: STextStyles.button(context).copyWith(
                fontSize: 14,
                color: selectedIndex == 1
                    ? Theme.of(context)
                        .extension<StackColors>()!
                        .buttonTextPrimary
                    : Theme.of(context)
                        .extension<StackColors>()!
                        .buttonTextSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
