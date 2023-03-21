import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/models/exchange/change_now/exchange_transaction_status.dart';
import 'package:stackduo/models/exchange/response_objects/trade.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/format.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/conditional_parent.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';

class TradeCard extends ConsumerWidget {
  const TradeCard({
    Key? key,
    required this.trade,
    required this.onTap,
  }) : super(key: key);

  final Trade trade;
  final VoidCallback onTap;

  String _fetchIconAssetForStatus(String statusString, BuildContext context) {
    ChangeNowTransactionStatus? status;
    try {
      if (statusString.toLowerCase().startsWith("waiting")) {
        statusString = "Waiting";
      }
      status = changeNowTransactionStatusFromStringIgnoreCase(statusString);
    } on ArgumentError catch (_) {
      switch (statusString.toLowerCase()) {
        case "funds confirming":
        case "processing payment":
          return Assets.svg.txExchangePending(context);

        case "completed":
          return Assets.svg.txExchange(context);

        default:
          status = ChangeNowTransactionStatus.Failed;
      }
    }

    switch (status) {
      case ChangeNowTransactionStatus.New:
      case ChangeNowTransactionStatus.Waiting:
      case ChangeNowTransactionStatus.Confirming:
      case ChangeNowTransactionStatus.Exchanging:
      case ChangeNowTransactionStatus.Sending:
      case ChangeNowTransactionStatus.Refunded:
      case ChangeNowTransactionStatus.Verifying:
        return Assets.svg.txExchangePending(context);
      case ChangeNowTransactionStatus.Finished:
        return Assets.svg.txExchange(context);
      case ChangeNowTransactionStatus.Failed:
        return Assets.svg.txExchangeFailed(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Util.isDesktop;

    return ConditionalParent(
      condition: isDesktop,
      builder: (child) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: child,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: RoundedWhiteContainer(
          padding:
              isDesktop ? const EdgeInsets.all(16) : const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    _fetchIconAssetForStatus(
                      trade.status,
                      context,
                    ),
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${trade.payInCurrency.toUpperCase()} → ${trade.payOutCurrency.toUpperCase()}",
                          style: STextStyles.itemSubtitle12(context),
                        ),
                        Text(
                          "${isDesktop ? "-" : ""}${Decimal.tryParse(trade.payInAmount) ?? "..."} ${trade.payInCurrency.toUpperCase()}",
                          style: STextStyles.itemSubtitle12(context),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isDesktop)
                          Text(
                            trade.exchangeName,
                            style: STextStyles.label(context),
                          ),
                        Text(
                          Format.extractDateFrom(
                              trade.timestamp.millisecondsSinceEpoch ~/ 1000),
                          style: STextStyles.label(context),
                        ),
                        if (isDesktop)
                          Text(
                            trade.exchangeName,
                            style: STextStyles.label(context),
                          ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
