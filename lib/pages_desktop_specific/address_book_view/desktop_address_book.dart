import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/models/contact_address_entry.dart';
import 'package:stackduo/pages/address_book_views/subviews/add_address_book_entry_view.dart';
import 'package:stackduo/pages/address_book_views/subviews/address_book_filter_view.dart';
import 'package:stackduo/pages_desktop_specific/address_book_view/subwidgets/desktop_address_book_scaffold.dart';
import 'package:stackduo/pages_desktop_specific/address_book_view/subwidgets/desktop_contact_details.dart';
import 'package:stackduo/providers/global/address_book_service_provider.dart';
import 'package:stackduo/providers/providers.dart';
import 'package:stackduo/providers/ui/address_book_providers/address_book_filter_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/address_book_card.dart';
import 'package:stackduo/widgets/desktop/desktop_app_bar.dart';
import 'package:stackduo/widgets/desktop/desktop_dialog.dart';
import 'package:stackduo/widgets/desktop/desktop_scaffold.dart';
import 'package:stackduo/widgets/desktop/primary_button.dart';
import 'package:stackduo/widgets/desktop/secondary_button.dart';
import 'package:stackduo/widgets/icon_widgets/x_icon.dart';
import 'package:stackduo/widgets/rounded_container.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';
import 'package:stackduo/widgets/stack_text_field.dart';
import 'package:stackduo/widgets/textfield_icon_button.dart';

class DesktopAddressBook extends ConsumerStatefulWidget {
  const DesktopAddressBook({Key? key}) : super(key: key);

  static const String routeName = "/desktopAddressBook";

  @override
  ConsumerState<DesktopAddressBook> createState() => _DesktopAddressBook();
}

class _DesktopAddressBook extends ConsumerState<DesktopAddressBook> {
  late final TextEditingController _searchController;

  late final FocusNode _searchFocusNode;

  String _searchTerm = "";

  String? currentContactId;

  Future<void> selectCryptocurrency() async {
    await showDialog<dynamic>(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (context) {
        return const DesktopDialog(
          maxHeight: 609,
          maxWidth: 576,
          child: AddressBookFilterView(),
        );
      },
    );
  }

  Future<void> newContact() async {
    await showDialog<dynamic>(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (context) {
        return const DesktopDialog(
          maxHeight: 609,
          maxWidth: 576,
          child: AddAddressBookEntryView(),
        );
      },
    );
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    ref.refresh(addressBookFilterProvider);

    // if (widget.coin == null) {
    List<Coin> coins = Coin.values.toList();

    bool showTestNet = ref.read(prefsChangeNotifierProvider).showTestNetCoins;

    if (showTestNet) {
      ref.read(addressBookFilterProvider).addAll(coins, false);
    } else {
      ref
          .read(addressBookFilterProvider)
          .addAll(coins.getRange(0, coins.length - kTestNetCoinCount), false);
    }
    // } else {
    //   ref.read(addressBookFilterProvider).add(widget.coin!, false);
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<ContactAddressEntry> addresses = [];
      final managers = ref.read(walletsChangeNotifierProvider).managers;
      for (final manager in managers) {
        addresses.add(
          ContactAddressEntry()
            ..coinName = manager.coin.name
            ..address = await manager.currentReceivingAddress
            ..label = "Current Receiving"
            ..other = manager.walletName,
        );
      }
      final self = ContactEntry(
        name: "My Stack",
        addresses: addresses,
        isFavorite: true,
        customId: "default",
      );
      await ref.read(addressBookServiceProvider).editContact(self);
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD: $runtimeType");
    final contacts =
        ref.watch(addressBookServiceProvider.select((value) => value.contacts));

    final allContacts = contacts
        .where((element) =>
            element.addresses.isEmpty ||
            element.addresses
                .where((e) => ref.watch(addressBookFilterProvider
                    .select((value) => value.coins.contains(e.coin))))
                .isNotEmpty)
        .where(
            (e) => ref.read(addressBookServiceProvider).matches(_searchTerm, e))
        .toList();

    final favorites = contacts
        .where((element) =>
            element.addresses.isEmpty ||
            element.addresses
                .where((e) => ref.watch(addressBookFilterProvider
                    .select((value) => value.coins.contains(e.coin))))
                .isNotEmpty)
        .where((e) =>
            e.isFavorite &&
            ref.read(addressBookServiceProvider).matches(_searchTerm, e))
        .where((element) => element.isFavorite)
        .toList();

    return DesktopScaffold(
      appBar: DesktopAppBar(
        isCompactHeight: true,
        leading: Row(
          children: [
            const SizedBox(
              width: 24,
            ),
            Text(
              "Address Book",
              style: STextStyles.desktopH3(context),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 24,
        ),
        child: DesktopAddressBookScaffold(
          controlsLeft: ClipRRect(
            borderRadius: BorderRadius.circular(
              Constants.size.circularBorderRadius,
            ),
            child: TextField(
              autocorrect: Util.isDesktop ? false : true,
              enableSuggestions: Util.isDesktop ? false : true,
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
              style: STextStyles.field(context),
              decoration: standardInputDecoration(
                "Search",
                _searchFocusNode,
                context,
              ).copyWith(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  child: SvgPicture.asset(
                    Assets.svg.search,
                    width: 16,
                    height: 16,
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
          controlsRight: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SecondaryButton(
                width: 184,
                label: "Filter",
                buttonHeight: ButtonHeight.l,
                icon: SvgPicture.asset(
                  Assets.svg.filter,
                  color: Theme.of(context)
                      .extension<StackColors>()!
                      .buttonTextSecondary,
                ),
                onPressed: selectCryptocurrency,
              ),
              const SizedBox(
                width: 20,
              ),
              PrimaryButton(
                width: 184,
                label: "Add new",
                buttonHeight: ButtonHeight.l,
                icon: SvgPicture.asset(
                  Assets.svg.circlePlus,
                  color: Theme.of(context)
                      .extension<StackColors>()!
                      .buttonTextPrimary,
                ),
                onPressed: newContact,
              ),
            ],
          ),
          filterItems: Container(),
          upperLabel: favorites.isEmpty && allContacts.isEmpty
              ? null
              : Text(
                  favorites.isEmpty ? "All contacts" : "Favorites",
                  style: STextStyles.smallMed12(context),
                ),
          lowerLabel: favorites.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 12,
                  ),
                  child: Text(
                    "All contacts",
                    style: STextStyles.smallMed12(context),
                  ),
                ),
          favorites: favorites.isEmpty
              ? contacts.isNotEmpty
                  ? null
                  : RoundedWhiteContainer(
                      child: Center(
                        child: Text(
                          "Your favorite contacts will appear here",
                          style: STextStyles.itemSubtitle(context),
                        ),
                      ),
                    )
              : RoundedWhiteContainer(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      for (int i = 0; i < favorites.length; i++)
                        Column(
                          children: [
                            if (i > 0)
                              Container(
                                color: Theme.of(context)
                                    .extension<StackColors>()!
                                    .background,
                                height: 1,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: RoundedContainer(
                                padding: const EdgeInsets.all(0),
                                color: Theme.of(context)
                                    .extension<StackColors>()!
                                    .accentColorDark
                                    .withOpacity(
                                      currentContactId == favorites[i].customId
                                          ? 0.08
                                          : 0,
                                    ),
                                child: RawMaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      currentContactId = favorites[i].customId;
                                    });
                                  },
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      Constants.size.circularBorderRadius,
                                    ),
                                  ),
                                  child: AddressBookCard(
                                    key: Key(
                                        "favContactCard_${favorites[i].customId}_key"),
                                    contactId: favorites[i].customId,
                                    desktopSendFrom: false,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
          all: allContacts.isEmpty
              ? contacts.isNotEmpty
                  ? null
                  : RoundedWhiteContainer(
                      child: Center(
                        child: Text(
                          "Your contacts will appear here",
                          style: STextStyles.itemSubtitle(context),
                        ),
                      ),
                    )
              : Column(
                  children: [
                    RoundedWhiteContainer(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          for (int i = 0; i < allContacts.length; i++)
                            Column(
                              children: [
                                if (i > 0)
                                  Container(
                                    color: Theme.of(context)
                                        .extension<StackColors>()!
                                        .background,
                                    height: 1,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: RoundedContainer(
                                    padding: const EdgeInsets.all(0),
                                    color: Theme.of(context)
                                        .extension<StackColors>()!
                                        .accentColorDark
                                        .withOpacity(
                                          currentContactId ==
                                                  allContacts[i].customId
                                              ? 0.08
                                              : 0,
                                        ),
                                    child: RawMaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          currentContactId =
                                              allContacts[i].customId;
                                        });
                                      },
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          Constants.size.circularBorderRadius,
                                        ),
                                      ),
                                      child: AddressBookCard(
                                        key: Key(
                                            "favContactCard_${allContacts[i].customId}_key"),
                                        contactId: allContacts[i].customId,
                                        desktopSendFrom: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
          details: currentContactId == null
              ? Container()
              : DesktopContactDetails(
                  contactId: currentContactId!,
                ),
        ),
      ),
    );
  }
}
