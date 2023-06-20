import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:stackduo/db/isar/main_db.dart';
import 'package:stackduo/models/isar/models/contact_entry.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

class AddressBookService extends ChangeNotifier {
  ContactEntry getContactById(String id) {
    ContactEntry? contactEntry = MainDB.instance.getContactEntry(id: id);
    if (contactEntry == null) {
      throw Exception('Contact ID "$id" not found!');
    } else {
      return contactEntry;
    }
  }

  List<ContactEntry> get contacts => MainDB.instance.getContactEntries();

  /// search address book entries
  //TODO search using isar queries
  Future<List<ContactEntry>> search(String text) async {
    if (text.isEmpty) return contacts;
    var results = contacts.toList();

    results.retainWhere((contact) => matches(text, contact));

    return results;
  }

  bool matches(String term, ContactEntry contact) {
    if (term.isEmpty) {
      return true;
    }
    final text = term.toLowerCase();
    if (contact.name.toLowerCase().contains(text)) {
      return true;
    }
    for (int i = 0; i < contact.addresses.length; i++) {
      if (contact.addresses[i].label.toLowerCase().contains(text) ||
          contact.addresses[i].coin.name.toLowerCase().contains(text) ||
          contact.addresses[i].coin.prettyName.toLowerCase().contains(text) ||
          contact.addresses[i].coin.ticker.toLowerCase().contains(text) ||
          contact.addresses[i].address.toLowerCase().contains(text)) {
        return true;
      }
    }
    return false;
  }

  /// add contact
  ///
  /// returns false if it provided [contact]'s id already exists in the database
  /// other true if the [contact] was saved
  Future<bool> addContact(ContactEntry contact) async {
    if (await MainDB.instance.isContactEntryExists(id: contact.customId)) {
      return false;
    } else {
      await MainDB.instance.putContactEntry(contactEntry: contact);
      notifyListeners();
      return true;
    }
  }

  /// Edit contact
  Future<bool> editContact(ContactEntry editedContact) async {
    // over write the contact with edited version
    await MainDB.instance.putContactEntry(contactEntry: editedContact);
    notifyListeners();
    return true;
  }

  /// Remove address book contact entry from db if it exists
  Future<void> removeContact(String id) async {
    await MainDB.instance.deleteContactEntry(id: id);
    notifyListeners();
  }
}
