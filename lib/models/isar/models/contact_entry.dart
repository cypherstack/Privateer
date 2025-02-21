import 'package:isar/isar.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

part 'contact_entry.g.dart';

@collection
class ContactEntry {
  ContactEntry({
    this.emojiChar,
    required this.name,
    required this.addresses,
    required this.isFavorite,
    required this.customId,
  });

  Id id = Isar.autoIncrement;

  late final String? emojiChar;
  late final String name;
  late final List<ContactAddressEntry> addresses;
  late final bool isFavorite;

  @Index(unique: true, replace: true)
  late final String customId;

  ContactEntry copyWith({
    bool shouldCopyEmojiWithNull = false,
    String? emojiChar,
    String? name,
    List<ContactAddressEntry>? addresses,
    bool? isFavorite,
  }) {
    List<ContactAddressEntry> _addresses = [];
    if (addresses == null) {
      for (var e in this.addresses) {
        _addresses.add(e.copyWith());
      }
    } else {
      for (var e in addresses) {
        _addresses.add(e.copyWith());
      }
    }
    String? newEmoji;
    if (shouldCopyEmojiWithNull) {
      newEmoji = emojiChar;
    } else {
      newEmoji = emojiChar ?? this.emojiChar;
    }

    return ContactEntry(
      emojiChar: newEmoji,
      name: name ?? this.name,
      addresses: _addresses,
      isFavorite: isFavorite ?? this.isFavorite,
      customId: customId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "emoji": emojiChar,
      "name": name,
      "addresses": addresses.map((e) => e.toMap()).toList(),
      "id": customId,
      "isFavorite": isFavorite,
    };
  }
}

@embedded
class ContactAddressEntry {
  late final String coinName;
  late final String address;
  late final String label;
  late final String? other;

  @ignore
  Coin get coin => Coin.values.byName(coinName);

  ContactAddressEntry();

  ContactAddressEntry copyWith({
    Coin? coin,
    String? address,
    String? label,
    String? other,
  }) {
    return ContactAddressEntry()
      ..coinName = coin?.name ?? coinName
      ..address = address ?? this.address
      ..label = label ?? this.label
      ..other = other ?? this.other;
  }

  Map<String, String> toMap() {
    return {
      "label": label,
      "address": address,
      "coin": coin.name,
      "other": other ?? "",
    };
  }

  @override
  String toString() {
    return "AddressBookEntry: ${toMap()}";
  }
}
