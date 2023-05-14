import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/block_explorers.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/widgets/background.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';

class ManageExplorerView extends ConsumerStatefulWidget {
  const ManageExplorerView({
    Key? key,
    required this.coin,
  }) : super(key: key);

  static const String routeName = "/manageExplorer";

  final Coin coin;

  @override
  ConsumerState<ManageExplorerView> createState() => _ManageExplorerViewState();
}

class _ManageExplorerViewState extends ConsumerState<ManageExplorerView> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(
        text:
            getBlockExplorerTransactionUrlFor(coin: widget.coin, txid: "[TXID]")
                .toString()
                .replaceAll("%5BTXID%5D", "[TXID]"));
  }

  @override
  Widget build(BuildContext context) {
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
            "${widget.coin.prettyName} block explorer",
            style: STextStyles.navBarTitle(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                  child: Column(
                children: [
                  TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  RoundedWhiteContainer(
                    child: Center(
                      child: Text(
                        "Edit your block explorer above. Keep in mind that "
                        "every block explorer has a slightly different URL "
                        "scheme.\n\nPaste in your block explorer of choice,"
                        " then edit in [TXID] where the transaction ID "
                        "should go, and Stack Duo will auto fill the "
                        "transaction ID in that place of URL.",
                        style: STextStyles.itemSubtitle(context),
                      ),
                    ),
                  ),
                ],
              )),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 480,
                    minHeight: 70,
                  ),
                  child: TextButton(
                    style: Theme.of(context)
                        .extension<StackColors>()!
                        .getPrimaryEnabledButtonStyle(context),
                    onPressed: () {
                      textEditingController.text =
                          textEditingController.text.trim();
                      setBlockExplorerForCoin(
                              coin: widget.coin,
                              url: Uri.parse(textEditingController.text))
                          .then((value) => Navigator.of(context).pop());
                    },
                    child: Text(
                      "Save",
                      style: STextStyles.button(context),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
