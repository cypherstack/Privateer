import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/pages/wallet_view/sub_widgets/transactions_list.dart';
import 'package:stackduo/pages/wallet_view/transaction_views/all_transactions_view.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/desktop_wallet_features.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/desktop_wallet_summary.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/my_wallet.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/network_info_button.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/wallet_keys_button.dart';
import 'package:stackduo/pages_desktop_specific/my_stack_view/wallet_view/sub_widgets/wallet_options_button.dart';
import 'package:stackduo/providers/global/auto_swb_service_provider.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/providers/ui/transaction_filter_provider.dart';
import 'package:stackduo/services/event_bus/events/global/wallet_sync_status_changed_event.dart';
import 'package:stackduo/services/event_bus/global_event_bus.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/backup_frequency_type.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/widgets/background.dart';
import 'package:stackduo/widgets/conditional_parent.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/custom_buttons/blue_text_button.dart';
import 'package:stackduo/widgets/custom_loading_overlay.dart';
import 'package:stackduo/widgets/desktop/desktop_app_bar.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog_close_button.dart';
import 'package:stackduo/widgets/desktop/desktop_scaffold.dart';
import 'package:stackduo/widgets/desktop/primary_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/hover_text_field.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';

/// [eventBus] should only be set during testing
class DesktopWalletView extends ConsumerStatefulWidget {
  const DesktopWalletView({
    Key? key,
    required this.walletId,
    this.eventBus,
  }) : super(key: key);

  static const String routeName = "/desktopWalletView";

  final String walletId;
  final EventBus? eventBus;

  @override
  ConsumerState<DesktopWalletView> createState() => _DesktopWalletViewState();
}

class _DesktopWalletViewState extends ConsumerState<DesktopWalletView> {
  static const double sendReceiveColumnWidth = 460;

  late final TextEditingController controller;
  late final EventBus eventBus;

  late final bool _shouldDisableAutoSyncOnLogOut;
  bool _rescanningOnOpen = false;

  Future<void> onBackPressed() async {
    await _logout();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _logout() async {
    final managerProvider = ref
        .read(walletsChangeNotifierProvider)
        .getManagerProvider(widget.walletId);
    if (_shouldDisableAutoSyncOnLogOut) {
      // disable auto sync if it was enabled only when loading wallet
      ref.read(managerProvider).shouldAutoSync = false;
    }
    ref.read(transactionFilterProvider.state).state = null;
    if (ref.read(prefsChangeNotifierProvider).isAutoBackupEnabled &&
        ref.read(prefsChangeNotifierProvider).backupFrequencyType ==
            BackupFrequencyType.afterClosingAWallet) {
      unawaited(ref.read(autoSWBServiceProvider).doBackup());
    }
    ref.read(managerProvider.notifier).isActiveWallet = false;
  }

  @override
  void initState() {
    controller = TextEditingController();
    final managerProvider = ref
        .read(walletsChangeNotifierProvider)
        .getManagerProvider(widget.walletId);

    controller.text = ref.read(managerProvider).walletName;

    eventBus =
        widget.eventBus != null ? widget.eventBus! : GlobalEventBus.instance;

    ref.read(managerProvider).isActiveWallet = true;
    if (!ref.read(managerProvider).shouldAutoSync) {
      // enable auto sync if it wasn't enabled when loading wallet
      ref.read(managerProvider).shouldAutoSync = true;
      _shouldDisableAutoSyncOnLogOut = true;
    } else {
      _shouldDisableAutoSyncOnLogOut = false;
    }

    if (ref.read(managerProvider).rescanOnOpenVersion == Constants.rescanV1) {
      _rescanningOnOpen = true;
      ref.read(managerProvider).fullRescan(20, 1000).then(
            (_) => ref.read(managerProvider).resetRescanOnOpen().then(
                  (_) => WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => _rescanningOnOpen = false),
                  ),
                ),
          );
    } else {
      ref.read(managerProvider).refresh();
    }

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(walletsChangeNotifierProvider
        .select((value) => value.getManager(widget.walletId)));
    final coin = manager.coin;
    final managerProvider = ref.watch(walletsChangeNotifierProvider
        .select((value) => value.getManagerProvider(widget.walletId)));

    return ConditionalParent(
      condition: _rescanningOnOpen,
      builder: (child) {
        return Stack(
          children: [
            child,
            Background(
              child: CustomLoadingOverlay(
                message:
                    "Migration in progress\nThis could take a while\nPlease don't leave this screen",
                subMessage: "This only needs to run once per wallet",
                eventBus: null,
                textColor: Theme.of(context).extension<StackColors>()!.textDark,
                actionButton: SecondaryButton(
                  label: "Skip",
                  buttonHeight: ButtonHeight.l,
                  onPressed: () async {
                    await showDialog<void>(
                      context: context,
                      builder: (context) => DesktopDialog(
                        maxWidth: 500,
                        maxHeight: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Warning!",
                                    style: STextStyles.desktopH3(context),
                                  ),
                                  const DesktopDialogCloseButton(),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                "Skipping this process can completely"
                                " break your wallet. It is only meant to be done in"
                                " emergency situations where the migration fails"
                                " and will not let you continue. Still skip?",
                                style: STextStyles.desktopTextSmall(context),
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SecondaryButton(
                                      label: "Cancel",
                                      buttonHeight: ButtonHeight.l,
                                      onPressed: Navigator.of(context,
                                              rootNavigator: true)
                                          .pop,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: PrimaryButton(
                                      label: "Ok",
                                      buttonHeight: ButtonHeight.l,
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        setState(
                                            () => _rescanningOnOpen = false);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        );
      },
      child: DesktopScaffold(
        appBar: DesktopAppBar(
          background: Theme.of(context).extension<StackColors>()!.popupBG,
          leading: Expanded(
            child: Row(
              children: [
                const SizedBox(
                  width: 32,
                ),
                AppBarIconButton(
                  size: 32,
                  color: Theme.of(context)
                      .extension<StackColors>()!
                      .textFieldDefaultBG,
                  shadows: const [],
                  icon: SvgPicture.asset(
                    Assets.svg.arrowLeft,
                    width: 18,
                    height: 18,
                    color: Theme.of(context)
                        .extension<StackColors>()!
                        .topNavIconPrimary,
                  ),
                  onPressed: onBackPressed,
                ),
                const SizedBox(
                  width: 15,
                ),
                SvgPicture.asset(
                  Assets.svg.iconFor(coin: coin),
                  width: 32,
                  height: 32,
                ),
                const SizedBox(
                  width: 12,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                  ),
                  child: IntrinsicWidth(
                    child: DesktopWalletNameField(
                      walletId: widget.walletId,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    NetworkInfoButton(
                      walletId: widget.walletId,
                      eventBus: eventBus,
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    WalletKeysButton(
                      walletId: widget.walletId,
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    WalletOptionsButton(
                      walletId: widget.walletId,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
          useSpacers: false,
          isCompactHeight: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              RoundedWhiteContainer(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      Assets.svg.iconFor(coin: coin),
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    DesktopWalletSummary(
                      walletId: widget.walletId,
                      initialSyncStatus: ref.watch(managerProvider
                              .select((value) => value.isRefreshing))
                          ? WalletSyncStatus.syncing
                          : WalletSyncStatus.synced,
                    ),
                    const Spacer(),
                    DesktopWalletFeatures(
                      walletId: widget.walletId,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  SizedBox(
                    width: sendReceiveColumnWidth,
                    child: Text(
                      "My wallet",
                      style:
                          STextStyles.desktopTextExtraSmall(context).copyWith(
                        color: Theme.of(context)
                            .extension<StackColors>()!
                            .textFieldActiveSearchIconLeft,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent transactions",
                          style: STextStyles.desktopTextExtraSmall(context)
                              .copyWith(
                            color: Theme.of(context)
                                .extension<StackColors>()!
                                .textFieldActiveSearchIconLeft,
                          ),
                        ),
                        CustomTextButton(
                          text: "See all",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AllTransactionsView.routeName,
                              arguments: widget.walletId,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: sendReceiveColumnWidth,
                      child: MyWallet(
                        walletId: widget.walletId,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: TransactionsList(
                        managerProvider: ref.watch(
                            walletsChangeNotifierProvider.select((value) =>
                                value.getManagerProvider(widget.walletId))),
                        walletId: widget.walletId,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
