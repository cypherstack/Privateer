import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/providers/global/wallets_provider.dart';
import 'package:stackduo/services/event_bus/events/global/wallet_sync_status_changed_event.dart';
import 'package:stackduo/services/event_bus/global_event_bus.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/animated_widgets/rotating_arrows.dart';

/// [eventBus] should only be set during testing
class WalletRefreshButton extends ConsumerStatefulWidget {
  const WalletRefreshButton({
    Key? key,
    required this.walletId,
    required this.initialSyncStatus,
    this.onPressed,
    this.eventBus,
    this.overrideIconColor,
  }) : super(key: key);

  final String walletId;
  final WalletSyncStatus initialSyncStatus;
  final VoidCallback? onPressed;
  final EventBus? eventBus;
  final Color? overrideIconColor;

  @override
  ConsumerState<WalletRefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<WalletRefreshButton> {
  late final EventBus eventBus;

  late RotatingArrowsController _spinController;

  late StreamSubscription<dynamic> _syncStatusSubscription;

  @override
  void initState() {
    _spinController = RotatingArrowsController();

    eventBus =
        widget.eventBus != null ? widget.eventBus! : GlobalEventBus.instance;

    _syncStatusSubscription =
        eventBus.on<WalletSyncStatusChangedEvent>().listen(
      (event) async {
        if (event.walletId == widget.walletId) {
          switch (event.newStatus) {
            case WalletSyncStatus.unableToSync:
              _spinController.stop?.call();
              break;
            case WalletSyncStatus.synced:
              _spinController.stop?.call();
              break;
            case WalletSyncStatus.syncing:
              _spinController.repeat?.call();
              break;
          }
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _syncStatusSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Util.isDesktop;

    return SizedBox(
      height: isDesktop ? 22 : 36,
      width: isDesktop ? 22 : 36,
      child: MaterialButton(
        color: isDesktop
            ? Theme.of(context).extension<StackColors>()!.buttonBackSecondary
            : null,
        splashColor: Theme.of(context).extension<StackColors>()!.highlight,
        onPressed: () {
          final managerProvider = ref
              .read(walletsChangeNotifierProvider)
              .getManagerProvider(widget.walletId);
          final isRefreshing = ref.read(managerProvider).isRefreshing;
          if (!isRefreshing) {
            _spinController.repeat?.call();
            ref
                .read(managerProvider)
                .refresh()
                .then((_) => _spinController.stop?.call());
          }
        },
        elevation: 0,
        highlightElevation: 0,
        hoverElevation: 0,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Constants.size.circularBorderRadius,
          ),
        ),
        child: RotatingArrows(
          spinByDefault: widget.initialSyncStatus == WalletSyncStatus.syncing,
          width: isDesktop ? 12 : 24,
          height: isDesktop ? 12 : 24,
          controller: _spinController,
          color: widget.overrideIconColor != null
              ? widget.overrideIconColor!
              : isDesktop
                  ? Theme.of(context)
                      .extension<StackColors>()!
                      .textFieldDefaultSearchIconRight
                  : Theme.of(context)
                      .extension<StackColors>()!
                      .textFavoriteCard,
        ),
      ),
    );
  }
}
