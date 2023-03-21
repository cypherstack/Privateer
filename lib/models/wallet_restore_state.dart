import 'package:flutter/cupertino.dart';
import 'package:stackduo/services/coins/manager.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/enums/stack_restoring_status.dart';

class WalletRestoreState extends ChangeNotifier {
  final String walletId;
  final String walletName;
  final Coin coin;
  late StackRestoringStatus _restoringStatus;
  Manager? manager;
  String? address;
  String? mnemonic;
  String? mnemonicPassphrase;
  int? height;

  StackRestoringStatus get restoringState => _restoringStatus;
  set restoringState(StackRestoringStatus restoringStatus) {
    _restoringStatus = restoringStatus;
    notifyListeners();
  }

  WalletRestoreState({
    required this.walletId,
    required this.walletName,
    required this.coin,
    required StackRestoringStatus restoringStatus,
    this.manager,
    this.address,
    this.mnemonic,
    this.mnemonicPassphrase,
    this.height,
  }) {
    _restoringStatus = restoringStatus;
  }

  WalletRestoreState copyWith({
    StackRestoringStatus? restoringStatus,
    String? address,
    int? height,
  }) {
    return WalletRestoreState(
      walletId: walletId,
      walletName: walletName,
      coin: coin,
      restoringStatus: restoringStatus ?? _restoringStatus,
      manager: manager,
      address: this.address,
      mnemonic: mnemonic,
      mnemonicPassphrase: mnemonicPassphrase,
      height: this.height,
    );
  }
}
