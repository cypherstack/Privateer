import 'package:flutter/material.dart';
import 'package:stackduo/pages/wallet_view/sub_widgets/wallet_summary_info.dart';
import 'package:stackduo/services/event_bus/events/global/wallet_sync_status_changed_event.dart';
import 'package:stackduo/widgets/coin_card.dart';

class WalletSummary extends StatelessWidget {
  const WalletSummary({
    Key? key,
    required this.walletId,
    required this.initialSyncStatus,
    this.aspectRatio = 2.0,
    this.minHeight = 100.0,
    this.minWidth = 200.0,
    this.maxHeight = 250.0,
    this.maxWidth = 400.0,
  }) : super(key: key);

  final String walletId;
  final WalletSyncStatus initialSyncStatus;

  final double aspectRatio;
  final double minHeight;
  final double minWidth;
  final double maxHeight;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight,
          minWidth: minWidth,
          maxHeight: maxHeight,
          maxWidth: minWidth,
        ),
        child: LayoutBuilder(
          builder: (_, constraints) => Stack(
            children: [
              CoinCard(
                walletId: walletId,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WalletSummaryInfo(
                    walletId: walletId,
                    initialSyncStatus: initialSyncStatus,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
