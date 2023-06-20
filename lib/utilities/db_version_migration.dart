import 'package:hive/hive.dart';
import 'package:isar/isar.dart';
import 'package:stackduo/db/isar/main_db.dart';
import 'package:stackduo/db/hive/db.dart';
import 'package:stackduo/models/contact.dart';
import 'package:stackduo/models/exchange/change_now/exchange_transaction.dart';
import 'package:stackduo/models/exchange/response_objects/trade.dart';
import 'package:stackduo/models/isar/models/contact_entry.dart' as isar_contact;
import 'package:stackduo/models/isar/models/isar_models.dart' as isar_models;
import 'package:stackduo/models/isar/models/isar_models.dart';
import 'package:stackduo/services/mixins/wallet_db.dart';
import 'package:stackduo/services/wallets_service.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/flutter_secure_storage_interface.dart';
import 'package:stackduo/utilities/logger.dart';
import 'package:stackduo/utilities/prefs.dart';
import 'package:tuple/tuple.dart';

class DbVersionMigrator with WalletDB {
  Future<void> migrate(
    int fromVersion, {
    required SecureStorageInterface secureStore,
  }) async {
    Logging.instance.log(
      "Running migrate fromVersion $fromVersion",
      level: LogLevel.Warning,
    );
    switch (fromVersion) {
      case 0:
        await Hive.openBox<dynamic>(DB.boxNameAllWalletsData);
        await Hive.openBox<dynamic>(DB.boxNamePrefs);
        final prefs = Prefs.instance;
        await prefs.init();

        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 1);

        // try to continue migrating
        return await migrate(1, secureStore: secureStore);

      case 1:
        await Hive.openBox<ExchangeTransaction>(DB.boxNameTrades);
        await Hive.openBox<Trade>(DB.boxNameTradesV2);
        final trades =
            DB.instance.values<ExchangeTransaction>(boxName: DB.boxNameTrades);

        for (final old in trades) {
          if (old.statusObject != null) {
            final trade = Trade.fromExchangeTransaction(old, false);
            await DB.instance.put<Trade>(
              boxName: DB.boxNameTradesV2,
              key: trade.uuid,
              value: trade,
            );
          }
        }

        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 2);

        // try to continue migrating
        return await migrate(2, secureStore: secureStore);

      case 2:
        await Hive.openBox<dynamic>(DB.boxNamePrefs);
        final prefs = Prefs.instance;
        await prefs.init();
        if (!(await prefs.isExternalCallsSet())) {
          prefs.externalCalls = true;
        }

        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 3);
        return await migrate(3, secureStore: secureStore);

      case 3:
        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 4);

        // try to continue migrating
        return await migrate(4, secureStore: secureStore);

      case 4:
        // migrate
        await _v4(secureStore);

        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 5);

        // try to continue migrating
        return await migrate(5, secureStore: secureStore);

      case 5:
        // migrate
        await Hive.openBox<dynamic>("theme");
        await Hive.openBox<dynamic>(DB.boxNamePrefs);

        final themeName =
            DB.instance.get<dynamic>(boxName: "theme", key: "colorScheme")
                    as String? ??
                "light";

        await DB.instance.put<dynamic>(
            boxName: DB.boxNamePrefs, key: "theme", value: themeName);

        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 6);

        // try to continue migrating
        return await migrate(6, secureStore: secureStore);

      case 6:
        // migrate
        await MainDB.instance.initMainDB();
        final count = await MainDB.instance.isar.addresses.count();
        // add change/receiving tags to address labels
        for (var i = 0; i < count; i += 50) {
          final addresses = await MainDB.instance.isar.addresses
              .where()
              .offset(i)
              .limit(50)
              .findAll();

          final List<isar_models.AddressLabel> labels = [];
          for (final address in addresses) {
            List<String>? tags;
            switch (address.subType) {
              case AddressSubType.receiving:
                tags = ["receiving"];
                break;
              case AddressSubType.change:
                tags = ["change"];
                break;
              case AddressSubType.paynymNotification:
                tags = ["paynym notification"];
                break;
              case AddressSubType.paynymSend:
                break;
              case AddressSubType.paynymReceive:
                tags = ["paynym receiving"];
                break;
              case AddressSubType.unknown:
                break;
              case AddressSubType.nonWallet:
                break;
            }

            // update/create label if tags is not empty
            if (tags != null) {
              isar_models.AddressLabel? label = await MainDB
                  .instance.isar.addressLabels
                  .where()
                  .addressStringWalletIdEqualTo(address.value, address.walletId)
                  .findFirst();
              if (label == null) {
                label = isar_models.AddressLabel(
                  walletId: address.walletId,
                  value: "",
                  addressString: address.value,
                  tags: tags,
                );
              } else if (label.tags == null) {
                label = label.copyWith(tags: tags);
              }
              labels.add(label);
            }
          }

          if (labels.isNotEmpty) {
            await MainDB.instance.isar.writeTxn(() async {
              await MainDB.instance.isar.addressLabels.putAll(labels);
            });
          }
        }

        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 7);

        // try to continue migrating
        return await migrate(7, secureStore: secureStore);

      case 7:
        // migrate
        await _v7(secureStore);

        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 8);

        // try to continue migrating
        return await migrate(8, secureStore: secureStore);

      case 8:
        // migrate
        await _v8();

        // update version
        await DB.instance.put<dynamic>(
            boxName: DB.boxNameDBInfo, key: "hive_data_version", value: 9);

        // try to continue migrating
        return await migrate(9, secureStore: secureStore);

      default:
        // finally return
        return;
    }
  }

  Future<void> _v4(SecureStorageInterface secureStore) async {
    await Hive.openBox<dynamic>(DB.boxNameAllWalletsData);
    await Hive.openBox<dynamic>(DB.boxNamePrefs);
    final walletsService = WalletsService(secureStorageInterface: secureStore);
    final prefs = Prefs.instance;
    final walletInfoList = await walletsService.walletNames;
    await prefs.init();
    await MainDB.instance.initMainDB();

    for (final walletId in walletInfoList.keys) {
      final info = walletInfoList[walletId]!;
      assert(info.walletId == walletId);

      final walletBox = await Hive.openBox<dynamic>(info.walletId);

      const receiveAddressesPrefix = "receivingAddresses";
      const changeAddressesPrefix = "changeAddresses";

      // delete data from hive
      await walletBox.delete(receiveAddressesPrefix);
      await walletBox.delete("${receiveAddressesPrefix}P2PKH");
      await walletBox.delete("${receiveAddressesPrefix}P2SH");
      await walletBox.delete("${receiveAddressesPrefix}P2WPKH");
      await walletBox.delete(changeAddressesPrefix);
      await walletBox.delete("${changeAddressesPrefix}P2PKH");
      await walletBox.delete("${changeAddressesPrefix}P2SH");
      await walletBox.delete("${changeAddressesPrefix}P2WPKH");
      await walletBox.delete("latest_tx_model");
      await walletBox.delete("latest_lelantus_tx_model");

      // set empty mnemonic passphrase as we used that by default before
      if ((await secureStore.read(key: '${walletId}_mnemonicPassphrase')) ==
          null) {
        await secureStore.write(
            key: '${walletId}_mnemonicPassphrase', value: "");
      }

      // set flag to initiate full rescan on opening wallet
      await DB.instance.put<dynamic>(
        boxName: DB.boxNameDBInfo,
        key: "rescan_on_open_$walletId",
        value: Constants.rescanV1,
      );
    }
  }

  Future<void> _v7(SecureStorageInterface secureStore) async {
    await Hive.openBox<dynamic>(DB.boxNameAllWalletsData);
    final walletsService = WalletsService(secureStorageInterface: secureStore);
    final walletInfoList = await walletsService.walletNames;
    await MainDB.instance.initMainDB();

    for (final walletId in walletInfoList.keys) {
      final info = walletInfoList[walletId]!;
      assert(info.walletId == walletId);

      final count = await MainDB.instance.getTransactions(walletId).count();

      for (var i = 0; i < count; i += 50) {
        final txns = await MainDB.instance
            .getTransactions(walletId)
            .offset(i)
            .limit(50)
            .findAll();

        // migrate amount to serialized amount string
        final txnsData = txns
            .map(
              (tx) => Tuple2(
                tx
                  ..amountString = Amount(
                    rawValue: BigInt.from(tx.amount),
                    fractionDigits: info.coin.decimals,
                  ).toJsonString(),
                tx.address.value,
              ),
            )
            .toList();

        // update db records
        await MainDB.instance.addNewTransactionData(txnsData, walletId);
      }
    }
  }

  // this is actually v9 in sw
  Future<void> _v8() async {
    final addressBookBox = await Hive.openBox<dynamic>(DB.boxNameAddressBook);
    await MainDB.instance.initMainDB();

    final keys = List<String>.from(addressBookBox.keys);
    final contacts = keys
        .map((id) => Contact.fromJson(
              Map<String, dynamic>.from(
                addressBookBox.get(id) as Map,
              ),
            ))
        .toList(growable: false);

    final List<isar_contact.ContactEntry> newContacts = [];

    for (final contact in contacts) {
      final List<isar_contact.ContactAddressEntry> newContactAddressEntries =
          [];

      for (final entry in contact.addresses) {
        newContactAddressEntries.add(
          isar_contact.ContactAddressEntry()
            ..coinName = entry.coin.name
            ..address = entry.address
            ..label = entry.label
            ..other = entry.other,
        );
      }

      final newContact = isar_contact.ContactEntry(
        name: contact.name,
        addresses: newContactAddressEntries,
        isFavorite: contact.isFavorite,
        customId: contact.id,
      );

      newContacts.add(newContact);
    }

    await MainDB.instance.isar.writeTxn(() async {
      await MainDB.instance.isar.contactEntrys.putAll(newContacts);
    });

    await addressBookBox.deleteFromDisk();
  }
}
