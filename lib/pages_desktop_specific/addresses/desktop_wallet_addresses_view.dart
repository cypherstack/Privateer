import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:isar/isar.dart';
import 'package:stackduo/models/isar/models/isar_models.dart';
import 'package:stackduo/pages/receive_view/addresses/address_details_view.dart';
import 'package:stackduo/pages_desktop_specific/addresses/sub_widgets/desktop_address_list.dart';
import 'package:stackduo/providers/db/main_db_provider.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/desktop/desktop_app_bar.dart';
import 'package:stackduo/widgets/desktop/desktop_scaffold.dart';

final desktopSelectedAddressId = StateProvider.autoDispose<Id?>((ref) => null);

class DesktopWalletAddressesView extends ConsumerStatefulWidget {
  const DesktopWalletAddressesView({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  static const String routeName = "/desktopWalletAddressesView";

  final String walletId;

  @override
  ConsumerState<DesktopWalletAddressesView> createState() =>
      _DesktopWalletAddressesViewState();
}

class _DesktopWalletAddressesViewState
    extends ConsumerState<DesktopWalletAddressesView> {
  static const _headerHeight = 70.0;
  static const _columnWidth0 = 489.0;

  Stream<void>? addressCollectionWatcher;

  void _onAddressCollectionWatcherEvent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    addressCollectionWatcher = ref
        .read(mainDBProvider)
        .isar
        .addresses
        .watchLazy(fireImmediately: true);
    addressCollectionWatcher!.listen((_) => _onAddressCollectionWatcherEvent());

    super.initState();
  }

  @override
  void dispose() {
    addressCollectionWatcher = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
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
                onPressed: Navigator.of(context).pop,
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                "Address list",
                style: STextStyles.desktopH3(context),
              ),
              const Spacer(),
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
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: _columnWidth0,
                    child: DesktopAddressList(
                      searchHeight: _headerHeight,
                      walletId: widget.walletId,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: _headerHeight,
                        ),
                        if (ref.watch(desktopSelectedAddressId.state).state !=
                            null)
                          Expanded(
                            child: SingleChildScrollView(
                              child: AddressDetailsView(
                                key: Key(
                                    "currentDesktopAddressDetails_key_${ref.watch(desktopSelectedAddressId.state).state}"),
                                walletId: widget.walletId,
                                addressId: ref
                                    .watch(desktopSelectedAddressId.state)
                                    .state!,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
