import 'package:stackwallet/electrumx_rpc/cached_electrumx.dart';
import 'package:stackwallet/electrumx_rpc/electrumx.dart';
import 'package:stackwallet/models/balance.dart';
import 'package:stackwallet/models/isar/models/isar_models.dart' as isar_models;
import 'package:stackwallet/models/node_model.dart';
import 'package:stackwallet/models/paymint/fee_object_model.dart';
import 'package:stackwallet/services/coins/bitcoin/bitcoin_wallet.dart';
import 'package:stackwallet/services/coins/monero/monero_wallet.dart';
import 'package:stackwallet/services/transaction_notification_tracker.dart';
import 'package:stackwallet/utilities/enums/coin_enum.dart';
import 'package:stackwallet/utilities/flutter_secure_storage_interface.dart';
import 'package:stackwallet/utilities/prefs.dart';

abstract class CoinServiceAPI {
  CoinServiceAPI();

  factory CoinServiceAPI.from(
    Coin coin,
    String walletId,
    String walletName,
    SecureStorageInterface secureStorageInterface,
    NodeModel node,
    TransactionNotificationTracker tracker,
    Prefs prefs,
    List<NodeModel> failovers,
  ) {
    final electrumxNode = ElectrumXNode(
      address: node.host,
      port: node.port,
      name: node.name,
      id: node.id,
      useSSL: node.useSSL,
    );
    final client = ElectrumX.from(
      node: electrumxNode,
      failovers: failovers
          .map((e) => ElectrumXNode(
                address: e.host,
                port: e.port,
                name: e.name,
                id: e.id,
                useSSL: e.useSSL,
              ))
          .toList(),
      prefs: prefs,
    );
    final cachedClient = CachedElectrumX.from(
      node: electrumxNode,
      failovers: failovers
          .map((e) => ElectrumXNode(
                address: e.host,
                port: e.port,
                name: e.name,
                id: e.id,
                useSSL: e.useSSL,
              ))
          .toList(),
      prefs: prefs,
    );
    switch (coin) {
      case Coin.bitcoin:
        return BitcoinWallet(
          walletId: walletId,
          walletName: walletName,
          coin: coin,
          secureStore: secureStorageInterface,
          client: client,
          cachedClient: cachedClient,
          tracker: tracker,
        );

      case Coin.bitcoinTestNet:
        return BitcoinWallet(
          walletId: walletId,
          walletName: walletName,
          coin: coin,
          secureStore: secureStorageInterface,
          client: client,
          cachedClient: cachedClient,
          tracker: tracker,
        );

      case Coin.monero:
        return MoneroWallet(
          walletId: walletId,
          walletName: walletName,
          coin: coin,
          secureStorage: secureStorageInterface,
          // tracker: tracker,
        );
    }
  }

  Coin get coin;
  bool get isRefreshing;
  bool get shouldAutoSync;
  set shouldAutoSync(bool shouldAutoSync);
  bool get isFavorite;
  set isFavorite(bool markFavorite);

  Future<Map<String, dynamic>> prepareSend({
    required String address,
    required int satoshiAmount,
    Map<String, dynamic>? args,
  });

  Future<String> confirmSend({required Map<String, dynamic> txData});

  Future<FeeObject> get fees;
  Future<int> get maxFee;

  Future<String> get currentReceivingAddress;

  Balance get balance;

  Future<List<isar_models.Transaction>> get transactions;
  Future<List<isar_models.UTXO>> get utxos;

  Future<void> refresh();

  Future<void> updateNode(bool shouldRefresh);

  // setter for updating on rename
  set walletName(String newName);

  String get walletName;
  String get walletId;

  bool validateAddress(String address);

  Future<List<String>> get mnemonic;
  Future<String?> get mnemonicString;
  Future<String?> get mnemonicPassphrase;

  Future<bool> testNetworkConnection();

  Future<void> recoverFromMnemonic({
    required String mnemonic,
    String? mnemonicPassphrase,
    required int maxUnusedAddressGap,
    required int maxNumberOfIndexesToCheck,
    required int height,
  });

  Future<void> initializeNew();
  Future<void> initializeExisting();

  Future<void> exit();
  bool get hasCalledExit;

  Future<void> fullRescan(
      int maxUnusedAddressGap, int maxNumberOfIndexesToCheck);

  void Function(bool isActive)? onIsActiveWalletChanged;

  bool get isConnected;

  Future<int> estimateFeeFor(int satoshiAmount, int feeRate);

  Future<bool> generateNewAddress();

  // used for electrumx coins
  Future<void> updateSentCachedTxData(Map<String, dynamic> txData);

  int get storedChainHeight;

  // Certain outputs return address as an array/list of strings like List<String> ["addresses"][0], some return it as a string like String ["address"]
  String? getAddress(dynamic output) {
    // Julian's code from https://github.com/cypherstack/stack_wallet/blob/35a8172d35f1b5cdbd22f0d56c4db02f795fd032/lib/services/coins/coin_paynym_extension.dart#L170 wins codegolf for this, I'd love to commit it now but need to retest this section ... should make unit tests for this case
    // final String? address = output["scriptPubKey"]?["addresses"]?[0] as String? ?? output["scriptPubKey"]?["address"] as String?;
    String? address;
    if (output.containsKey('scriptPubKey') as bool) {
      // Make sure the key exists before using it
      if (output["scriptPubKey"].containsKey('address') as bool) {
        address = output["scriptPubKey"]["address"] as String?;
      } else if (output["scriptPubKey"].containsKey('addresses') as bool) {
        address = output["scriptPubKey"]["addresses"][0] as String?;
        // TODO determine cases in which there are multiple addresses in the array
      }
    } /*else {
      // TODO detect cases in which no scriptPubKey exists
      Logging.instance.log("output type not detected; output: ${output}",
          level: LogLevel.Info);
    }*/

    return address;
  }

  // Firo wants an array/list of address strings like List<String>
  List? getAddresses(dynamic output) {
    // Inspired by Julian's code as referenced above, need to test before committing
    // final List? addresses = output["scriptPubKey"]?["addresses"] as List? ?? [output["scriptPubKey"]?["address"]] as List?;
    List? addresses;
    if (output.containsKey('scriptPubKey') as bool) {
      if (output["scriptPubKey"].containsKey('addresses') as bool) {
        addresses = output["scriptPubKey"]["addresses"] as List?;
      } else if (output["scriptPubKey"].containsKey('address') as bool) {
        addresses = [output["scriptPubKey"]["address"]];
      }
    } /*else {
      // TODO detect cases in which no scriptPubKey exists
      Logging.instance.log("output type not detected; output: ${output}",
          level: LogLevel.Info);
    }*/

    return addresses;
  }
}
