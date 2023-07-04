import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stackduo/models/isar/models/contact_entry.dart';
import 'package:stackduo/pages/address_book_views/subviews/contact_popup.dart';
import 'package:stackduo/providers/global/address_book_service_provider.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/utilities/assets.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/util.dart';
import 'package:stackduo/widgets/conditional_parent.dart';
import 'package:stackduo/widgets/expandable.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';

class AddressBookCard extends ConsumerStatefulWidget {
  const AddressBookCard({
    Key? key,
    required this.contactId,
    this.indicatorDown,
    this.desktopSendFrom = true,
  }) : super(key: key);

  final String contactId;
  final ExpandableState? indicatorDown;
  final bool desktopSendFrom;

  @override
  ConsumerState<AddressBookCard> createState() => _AddressBookCardState();
}

class _AddressBookCardState extends ConsumerState<AddressBookCard> {
  late final String contactId;
  late final bool isDesktop;
  late final bool desktopSendFrom;

  @override
  void initState() {
    contactId = widget.contactId;
    desktopSendFrom = widget.desktopSendFrom;
    isDesktop = Util.isDesktop;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // provider hack to prevent trying to update widget with deleted contact
    ContactEntry? _contact;
    try {
      _contact = ref.watch(addressBookServiceProvider
          .select((value) => value.getContactById(contactId)));
    } catch (_) {
      return Container();
    }

    final contact = _contact!;

    final List<Coin> coins = [];

    for (final coin in Coin.values) {
      if (contact.addresses.where((e) => e.coin == coin).isNotEmpty) {
        coins.add(coin);
      }
    }

    String coinsString = "";
    if (coins.isNotEmpty) {
      coinsString = coins[0].ticker;
      for (int i = 1; i < coins.length; i++) {
        coinsString += ", ${coins[i].ticker}";
      }
    }

    return ConditionalParent(
      condition: !isDesktop,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: contact.customId == "default"
                  ? Theme.of(context)
                      .extension<StackColors>()!
                      .myStackContactIconBG
                  : Theme.of(context)
                      .extension<StackColors>()!
                      .textFieldDefaultBG,
              borderRadius: BorderRadius.circular(32),
            ),
            child: contact.customId == "default"
                ? Center(
                    child: SvgPicture.asset(
                      Assets.svg.appIconForBrightness(
                        MediaQuery.of(context).platformBrightness,
                      ),
                      width: 20,
                    ),
                  )
                : contact.emojiChar != null
                    ? Center(
                        child: Text(contact.emojiChar!),
                      )
                    : Center(
                        child: SvgPicture.asset(
                          Assets.svg.user,
                          width: 18,
                        ),
                      ),
          ),
          const SizedBox(
            width: 12,
          ),
          if (isDesktop)
            Text(
              contact.name,
              style: STextStyles.itemSubtitle12(context),
            ),
          if (isDesktop)
            const SizedBox(
              width: 16,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: isDesktop && !desktopSendFrom
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isDesktop)
                  Text(
                    contact.name,
                    style: STextStyles.itemSubtitle12(context),
                  ),
                if (!isDesktop)
                  const SizedBox(
                    height: 4,
                  ),
                Text(
                  coinsString,
                  style: STextStyles.label(context),
                  textAlign: isDesktop && !desktopSendFrom
                      ? TextAlign.right
                      : TextAlign.left,
                ),
              ],
            ),
          ),
          if (isDesktop && desktopSendFrom) const Spacer(),
          if (isDesktop && desktopSendFrom)
            SvgPicture.asset(
              widget.indicatorDown == ExpandableState.collapsed
                  ? Assets.svg.chevronDown
                  : Assets.svg.chevronUp,
              width: 10,
              height: 5,
              color: Theme.of(context).extension<StackColors>()!.textSubtitle2,
            ),
        ],
      ),
      builder: (child) => RoundedWhiteContainer(
        padding: const EdgeInsets.all(4),
        child: RawMaterialButton(
          // splashColor: Theme.of(context).extension<StackColors>()!.highlight,
          padding: const EdgeInsets.all(0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Constants.size.circularBorderRadius,
            ),
          ),
          onPressed: () {
            showDialog<void>(
              context: context,
              useSafeArea: true,
              barrierDismissible: true,
              builder: (_) => ContactPopUp(
                contactId: contact.customId,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
