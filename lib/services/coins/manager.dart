import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:stackduo/hive/db.dart';
import 'package:stackduo/models/balance.dart';
import 'package:stackduo/models/isar/models/isar_models.dart' as isar_models;
import 'package:stackduo/models/models.dart';
import 'package:stackduo/services/coins/coin_service.dart';
import 'package:stackduo/services/event_bus/events/global/node_connection_status_changed_event.dart';
import 'package:stackduo/services/event_bus/events/global/updated_in_background_event.dart';
import 'package:stackduo/services/event_bus/global_event_bus.dart';
import 'package:stackduo/services/mixins/coin_control_interface.dart';
import 'package:stackduo/services/mixins/paynym_wallet_interface.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/logger.dart';

class Manager with ChangeNotifier {
  final CoinServiceAPI _currentWallet;
  StreamSubscription<dynamic>? _backgroundRefreshListener;
  StreamSubscription<dynamic>? _nodeStatusListener;

  /// optional eventbus parameter for testing only
  Manager(this._currentWallet, [EventBus? globalEventBusForTesting]) {
    final bus = globalEventBusForTesting ?? GlobalEventBus.instance;
    _backgroundRefreshListener = bus.on<UpdatedInBackgroundEvent>().listen(
      (event) async {
        if (event.walletId == walletId) {
          notifyListeners();
          Logging.instance.log(
              "UpdatedInBackgroundEvent activated notifyListeners() in Manager instance $hashCode $walletName with: ${event.message}",
              level: LogLevel.Info);
        }
      },
    );

    _nodeStatusListener = bus.on<NodeConnectionStatusChangedEvent>().listen(
      (event) async {
        if (event.walletId == walletId) {
          notifyListeners();
          Logging.instance.log(
              "NodeConnectionStatusChangedEvent activated notifyListeners() in Manager instance $hashCode $walletName with: ${event.newStatus}",
              level: LogLevel.Info);
        }
      },
    );
  }

  bool _isActiveWallet = false;
  bool get isActiveWallet => _isActiveWallet;
  set isActiveWallet(bool isActive) {
    if (_isActiveWallet != isActive) {
      _isActiveWallet = isActive;
      _currentWallet.onIsActiveWalletChanged?.call(isActive);
      //todo: check if print needed
      debugPrint(
          "wallet ID: ${_currentWallet.walletId} is active set to: $isActive");
    } else {
      debugPrint("wallet ID: ${_currentWallet.walletId} is still: $isActive");
    }
  }

  Future<void> updateNode(bool shouldRefresh) async {
    await _currentWallet.updateNode(shouldRefresh);
  }

  CoinServiceAPI get wallet => _currentWallet;

  bool get hasBackgroundRefreshListener => _backgroundRefreshListener != null;

  Coin get coin => _currentWallet.coin;

  bool get isRefreshing => _currentWallet.isRefreshing;

  bool get shouldAutoSync => _currentWallet.shouldAutoSync;
  set shouldAutoSync(bool shouldAutoSync) =>
      _currentWallet.shouldAutoSync = shouldAutoSync;

  bool get isFavorite => _currentWallet.isFavorite;

  set isFavorite(bool markFavorite) {
    _currentWallet.isFavorite = markFavorite;
    notifyListeners();
  }

  @override
  dispose() async {
    await exitCurrentWallet();
    super.dispose();
  }

  Future<Map<String, dynamic>> prepareSend({
    required String address,
    required int satoshiAmount,
    Map<String, dynamic>? args,
  }) async {
    try {
      final txInfo = await _currentWallet.prepareSend(
        address: address,
        satoshiAmount: satoshiAmount,
        args: args,
      );
      // notifyListeners();
      return txInfo;
    } catch (e) {
      // rethrow to pass error in alert
      rethrow;
    }
  }

  Future<String> confirmSend({required Map<String, dynamic> txData}) async {
    try {
      final txid = await _currentWallet.confirmSend(txData: txData);

      try {
        txData["txid"] = txid;
        await _currentWallet.updateSentCachedTxData(txData);
      } catch (e, s) {
        // do not rethrow as that would get handled as a send failure further up
        // also this is not critical code and transaction should show up on \
        // refresh regardless
        Logging.instance.log("$e\n$s", level: LogLevel.Warning);
      }

      notifyListeners();
      return txid;
    } catch (e) {
      // rethrow to pass error in alert
      rethrow;
    }
  }

  Future<FeeObject> get fees => _currentWallet.fees;
  Future<int> get maxFee => _currentWallet.maxFee;

  Future<String> get currentReceivingAddress =>
      _currentWallet.currentReceivingAddress;

  Balance get balance => _currentWallet.balance;

  Future<List<isar_models.Transaction>> get transactions =>
      _currentWallet.transactions;
  Future<List<isar_models.UTXO>> get utxos => _currentWallet.utxos;

  Future<void> refresh() async {
    await _currentWallet.refresh();
    notifyListeners();
  }

  // setter for updating on rename
  set walletName(String newName) {
    if (newName != _currentWallet.walletName) {
      _currentWallet.walletName = newName;
      notifyListeners();
    }
  }

  String get walletName => _currentWallet.walletName;
  String get walletId => _currentWallet.walletId;

  bool validateAddress(String address) =>
      _currentWallet.validateAddress(address);

  Future<List<String>> get mnemonic => _currentWallet.mnemonic;
  Future<String?> get mnemonicPassphrase => _currentWallet.mnemonicPassphrase;

  Future<bool> testNetworkConnection() =>
      _currentWallet.testNetworkConnection();

  Future<void> initializeNew() => _currentWallet.initializeNew();
  Future<void> initializeExisting() => _currentWallet.initializeExisting();
  Future<void> recoverFromMnemonic({
    required String mnemonic,
    String? mnemonicPassphrase,
    required int maxUnusedAddressGap,
    required int maxNumberOfIndexesToCheck,
    required int height,
  }) async {
    try {
      await _currentWallet.recoverFromMnemonic(
        mnemonic: mnemonic,
        mnemonicPassphrase: mnemonicPassphrase,
        maxUnusedAddressGap: maxUnusedAddressGap,
        maxNumberOfIndexesToCheck: maxNumberOfIndexesToCheck,
        height: height,
      );
    } catch (e, s) {
      Logging.instance.log("e: $e, S: $s", level: LogLevel.Error);
      rethrow;
    }
  }

  Future<void> exitCurrentWallet() async {
    final name = _currentWallet.walletName;
    final id = _currentWallet.walletId;
    await _backgroundRefreshListener?.cancel();
    _backgroundRefreshListener = null;
    await _nodeStatusListener?.cancel();
    _nodeStatusListener = null;
    await _currentWallet.exit();
    Logging.instance.log("manager.exitCurrentWallet completed for $id $name",
        level: LogLevel.Info);
  }

  Future<void> fullRescan(
      int maxUnusedAddressGap, int maxNumberOfIndexesToCheck) async {
    try {
      await _currentWallet.fullRescan(
          maxUnusedAddressGap, maxNumberOfIndexesToCheck);
    } catch (e) {
      rethrow;
    }
  }

  bool get isConnected => _currentWallet.isConnected;

  Future<int> estimateFeeFor(int satoshiAmount, int feeRate) async {
    return _currentWallet.estimateFeeFor(satoshiAmount, feeRate);
  }

  Future<bool> generateNewAddress() async {
    final success = await _currentWallet.generateNewAddress();
    if (success) {
      notifyListeners();
    }
    return success;
  }

  int get currentHeight => _currentWallet.storedChainHeight;

  bool get hasPaynymSupport => _currentWallet is PaynymWalletInterface;

  bool get hasCoinControlSupport => _currentWallet is CoinControlInterface;

  bool get hasWhirlpoolSupport => false;

  int get rescanOnOpenVersion =>
      DB.instance.get<dynamic>(
        boxName: DB.boxNameDBInfo,
        key: "rescan_on_open_$walletId",
      ) as int? ??
      0;

  Future<void> resetRescanOnOpen() async {
    await DB.instance.delete<dynamic>(
      key: "rescan_on_open_$walletId",
      boxName: DB.boxNameDBInfo,
    );
  }
}
