// Mocks generated by Mockito 5.4.2 from annotations
// in stackduo/test/widget_tests/node_options_sheet_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i11;

import 'package:flutter/foundation.dart' as _i4;
import 'package:flutter_riverpod/flutter_riverpod.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;
import 'package:stackduo/models/node_model.dart' as _i16;
import 'package:stackduo/services/coins/manager.dart' as _i6;
import 'package:stackduo/services/node_service.dart' as _i3;
import 'package:stackduo/services/wallets.dart' as _i8;
import 'package:stackduo/services/wallets_service.dart' as _i2;
import 'package:stackduo/utilities/amount/amount_unit.dart' as _i15;
import 'package:stackduo/utilities/enums/backup_frequency_type.dart' as _i14;
import 'package:stackduo/utilities/enums/coin_enum.dart' as _i9;
import 'package:stackduo/utilities/enums/sync_type_enum.dart' as _i13;
import 'package:stackduo/utilities/flutter_secure_storage_interface.dart'
    as _i7;
import 'package:stackduo/utilities/prefs.dart' as _i12;
import 'package:tuple/tuple.dart' as _i10;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeWalletsService_0 extends _i1.SmartFake
    implements _i2.WalletsService {
  _FakeWalletsService_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeNodeService_1 extends _i1.SmartFake implements _i3.NodeService {
  _FakeNodeService_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeChangeNotifierProvider_2<Notifier extends _i4.ChangeNotifier?>
    extends _i1.SmartFake implements _i5.ChangeNotifierProvider<Notifier> {
  _FakeChangeNotifierProvider_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeManager_3 extends _i1.SmartFake implements _i6.Manager {
  _FakeManager_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSecureStorageInterface_4 extends _i1.SmartFake
    implements _i7.SecureStorageInterface {
  _FakeSecureStorageInterface_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Wallets].
///
/// See the documentation for Mockito's code generation for more information.
class MockWallets extends _i1.Mock implements _i8.Wallets {
  MockWallets() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WalletsService get walletsService => (super.noSuchMethod(
        Invocation.getter(#walletsService),
        returnValue: _FakeWalletsService_0(
          this,
          Invocation.getter(#walletsService),
        ),
      ) as _i2.WalletsService);
  @override
  set walletsService(_i2.WalletsService? _walletsService) => super.noSuchMethod(
        Invocation.setter(
          #walletsService,
          _walletsService,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i3.NodeService get nodeService => (super.noSuchMethod(
        Invocation.getter(#nodeService),
        returnValue: _FakeNodeService_1(
          this,
          Invocation.getter(#nodeService),
        ),
      ) as _i3.NodeService);
  @override
  set nodeService(_i3.NodeService? _nodeService) => super.noSuchMethod(
        Invocation.setter(
          #nodeService,
          _nodeService,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get hasWallets => (super.noSuchMethod(
        Invocation.getter(#hasWallets),
        returnValue: false,
      ) as bool);
  @override
  List<_i5.ChangeNotifierProvider<_i6.Manager>> get managerProviders =>
      (super.noSuchMethod(
        Invocation.getter(#managerProviders),
        returnValue: <_i5.ChangeNotifierProvider<_i6.Manager>>[],
      ) as List<_i5.ChangeNotifierProvider<_i6.Manager>>);
  @override
  List<_i6.Manager> get managers => (super.noSuchMethod(
        Invocation.getter(#managers),
        returnValue: <_i6.Manager>[],
      ) as List<_i6.Manager>);
  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  List<String> getWalletIdsFor({required _i9.Coin? coin}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getWalletIdsFor,
          [],
          {#coin: coin},
        ),
        returnValue: <String>[],
      ) as List<String>);
  @override
  List<_i10.Tuple2<_i9.Coin, List<_i5.ChangeNotifierProvider<_i6.Manager>>>>
      getManagerProvidersByCoin() => (super.noSuchMethod(
            Invocation.method(
              #getManagerProvidersByCoin,
              [],
            ),
            returnValue: <
                _i10.Tuple2<_i9.Coin,
                    List<_i5.ChangeNotifierProvider<_i6.Manager>>>>[],
          ) as List<
              _i10.Tuple2<_i9.Coin,
                  List<_i5.ChangeNotifierProvider<_i6.Manager>>>>);
  @override
  List<_i5.ChangeNotifierProvider<_i6.Manager>> getManagerProvidersForCoin(
          _i9.Coin? coin) =>
      (super.noSuchMethod(
        Invocation.method(
          #getManagerProvidersForCoin,
          [coin],
        ),
        returnValue: <_i5.ChangeNotifierProvider<_i6.Manager>>[],
      ) as List<_i5.ChangeNotifierProvider<_i6.Manager>>);
  @override
  _i5.ChangeNotifierProvider<_i6.Manager> getManagerProvider(
          String? walletId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getManagerProvider,
          [walletId],
        ),
        returnValue: _FakeChangeNotifierProvider_2<_i6.Manager>(
          this,
          Invocation.method(
            #getManagerProvider,
            [walletId],
          ),
        ),
      ) as _i5.ChangeNotifierProvider<_i6.Manager>);
  @override
  _i6.Manager getManager(String? walletId) => (super.noSuchMethod(
        Invocation.method(
          #getManager,
          [walletId],
        ),
        returnValue: _FakeManager_3(
          this,
          Invocation.method(
            #getManager,
            [walletId],
          ),
        ),
      ) as _i6.Manager);
  @override
  void addWallet({
    required String? walletId,
    required _i6.Manager? manager,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #addWallet,
          [],
          {
            #walletId: walletId,
            #manager: manager,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeWallet({required String? walletId}) => super.noSuchMethod(
        Invocation.method(
          #removeWallet,
          [],
          {#walletId: walletId},
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i11.Future<void> load(_i12.Prefs? prefs) => (super.noSuchMethod(
        Invocation.method(
          #load,
          [prefs],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<void> loadAfterStackRestore(
    _i12.Prefs? prefs,
    List<_i6.Manager>? managers,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadAfterStackRestore,
          [
            prefs,
            managers,
          ],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  void addListener(dynamic listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeListener(dynamic listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [Prefs].
///
/// See the documentation for Mockito's code generation for more information.
class MockPrefs extends _i1.Mock implements _i12.Prefs {
  MockPrefs() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isInitialized => (super.noSuchMethod(
        Invocation.getter(#isInitialized),
        returnValue: false,
      ) as bool);
  @override
  int get lastUnlockedTimeout => (super.noSuchMethod(
        Invocation.getter(#lastUnlockedTimeout),
        returnValue: 0,
      ) as int);
  @override
  set lastUnlockedTimeout(int? lastUnlockedTimeout) => super.noSuchMethod(
        Invocation.setter(
          #lastUnlockedTimeout,
          lastUnlockedTimeout,
        ),
        returnValueForMissingStub: null,
      );
  @override
  int get lastUnlocked => (super.noSuchMethod(
        Invocation.getter(#lastUnlocked),
        returnValue: 0,
      ) as int);
  @override
  set lastUnlocked(int? lastUnlocked) => super.noSuchMethod(
        Invocation.setter(
          #lastUnlocked,
          lastUnlocked,
        ),
        returnValueForMissingStub: null,
      );
  @override
  int get currentNotificationId => (super.noSuchMethod(
        Invocation.getter(#currentNotificationId),
        returnValue: 0,
      ) as int);
  @override
  List<String> get walletIdsSyncOnStartup => (super.noSuchMethod(
        Invocation.getter(#walletIdsSyncOnStartup),
        returnValue: <String>[],
      ) as List<String>);
  @override
  set walletIdsSyncOnStartup(List<String>? walletIdsSyncOnStartup) =>
      super.noSuchMethod(
        Invocation.setter(
          #walletIdsSyncOnStartup,
          walletIdsSyncOnStartup,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i13.SyncingType get syncType => (super.noSuchMethod(
        Invocation.getter(#syncType),
        returnValue: _i13.SyncingType.currentWalletOnly,
      ) as _i13.SyncingType);
  @override
  set syncType(_i13.SyncingType? syncType) => super.noSuchMethod(
        Invocation.setter(
          #syncType,
          syncType,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get wifiOnly => (super.noSuchMethod(
        Invocation.getter(#wifiOnly),
        returnValue: false,
      ) as bool);
  @override
  set wifiOnly(bool? wifiOnly) => super.noSuchMethod(
        Invocation.setter(
          #wifiOnly,
          wifiOnly,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get showFavoriteWallets => (super.noSuchMethod(
        Invocation.getter(#showFavoriteWallets),
        returnValue: false,
      ) as bool);
  @override
  set showFavoriteWallets(bool? showFavoriteWallets) => super.noSuchMethod(
        Invocation.setter(
          #showFavoriteWallets,
          showFavoriteWallets,
        ),
        returnValueForMissingStub: null,
      );
  @override
  String get language => (super.noSuchMethod(
        Invocation.getter(#language),
        returnValue: '',
      ) as String);
  @override
  set language(String? newLanguage) => super.noSuchMethod(
        Invocation.setter(
          #language,
          newLanguage,
        ),
        returnValueForMissingStub: null,
      );
  @override
  String get currency => (super.noSuchMethod(
        Invocation.getter(#currency),
        returnValue: '',
      ) as String);
  @override
  set currency(String? newCurrency) => super.noSuchMethod(
        Invocation.setter(
          #currency,
          newCurrency,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get randomizePIN => (super.noSuchMethod(
        Invocation.getter(#randomizePIN),
        returnValue: false,
      ) as bool);
  @override
  set randomizePIN(bool? randomizePIN) => super.noSuchMethod(
        Invocation.setter(
          #randomizePIN,
          randomizePIN,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get useBiometrics => (super.noSuchMethod(
        Invocation.getter(#useBiometrics),
        returnValue: false,
      ) as bool);
  @override
  set useBiometrics(bool? useBiometrics) => super.noSuchMethod(
        Invocation.setter(
          #useBiometrics,
          useBiometrics,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get hasPin => (super.noSuchMethod(
        Invocation.getter(#hasPin),
        returnValue: false,
      ) as bool);
  @override
  set hasPin(bool? hasPin) => super.noSuchMethod(
        Invocation.setter(
          #hasPin,
          hasPin,
        ),
        returnValueForMissingStub: null,
      );
  @override
  int get familiarity => (super.noSuchMethod(
        Invocation.getter(#familiarity),
        returnValue: 0,
      ) as int);
  @override
  set familiarity(int? familiarity) => super.noSuchMethod(
        Invocation.setter(
          #familiarity,
          familiarity,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get showTestNetCoins => (super.noSuchMethod(
        Invocation.getter(#showTestNetCoins),
        returnValue: false,
      ) as bool);
  @override
  set showTestNetCoins(bool? showTestNetCoins) => super.noSuchMethod(
        Invocation.setter(
          #showTestNetCoins,
          showTestNetCoins,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get isAutoBackupEnabled => (super.noSuchMethod(
        Invocation.getter(#isAutoBackupEnabled),
        returnValue: false,
      ) as bool);
  @override
  set isAutoBackupEnabled(bool? isAutoBackupEnabled) => super.noSuchMethod(
        Invocation.setter(
          #isAutoBackupEnabled,
          isAutoBackupEnabled,
        ),
        returnValueForMissingStub: null,
      );
  @override
  set autoBackupLocation(String? autoBackupLocation) => super.noSuchMethod(
        Invocation.setter(
          #autoBackupLocation,
          autoBackupLocation,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i14.BackupFrequencyType get backupFrequencyType => (super.noSuchMethod(
        Invocation.getter(#backupFrequencyType),
        returnValue: _i14.BackupFrequencyType.everyTenMinutes,
      ) as _i14.BackupFrequencyType);
  @override
  set backupFrequencyType(_i14.BackupFrequencyType? backupFrequencyType) =>
      super.noSuchMethod(
        Invocation.setter(
          #backupFrequencyType,
          backupFrequencyType,
        ),
        returnValueForMissingStub: null,
      );
  @override
  set lastAutoBackup(DateTime? lastAutoBackup) => super.noSuchMethod(
        Invocation.setter(
          #lastAutoBackup,
          lastAutoBackup,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get hideBlockExplorerWarning => (super.noSuchMethod(
        Invocation.getter(#hideBlockExplorerWarning),
        returnValue: false,
      ) as bool);
  @override
  set hideBlockExplorerWarning(bool? hideBlockExplorerWarning) =>
      super.noSuchMethod(
        Invocation.setter(
          #hideBlockExplorerWarning,
          hideBlockExplorerWarning,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get gotoWalletOnStartup => (super.noSuchMethod(
        Invocation.getter(#gotoWalletOnStartup),
        returnValue: false,
      ) as bool);
  @override
  set gotoWalletOnStartup(bool? gotoWalletOnStartup) => super.noSuchMethod(
        Invocation.setter(
          #gotoWalletOnStartup,
          gotoWalletOnStartup,
        ),
        returnValueForMissingStub: null,
      );
  @override
  set startupWalletId(String? startupWalletId) => super.noSuchMethod(
        Invocation.setter(
          #startupWalletId,
          startupWalletId,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get externalCalls => (super.noSuchMethod(
        Invocation.getter(#externalCalls),
        returnValue: false,
      ) as bool);
  @override
  set externalCalls(bool? externalCalls) => super.noSuchMethod(
        Invocation.setter(
          #externalCalls,
          externalCalls,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get enableCoinControl => (super.noSuchMethod(
        Invocation.getter(#enableCoinControl),
        returnValue: false,
      ) as bool);
  @override
  set enableCoinControl(bool? enableCoinControl) => super.noSuchMethod(
        Invocation.setter(
          #enableCoinControl,
          enableCoinControl,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get enableSystemBrightness => (super.noSuchMethod(
        Invocation.getter(#enableSystemBrightness),
        returnValue: false,
      ) as bool);
  @override
  set enableSystemBrightness(bool? enableSystemBrightness) =>
      super.noSuchMethod(
        Invocation.setter(
          #enableSystemBrightness,
          enableSystemBrightness,
        ),
        returnValueForMissingStub: null,
      );
  @override
  String get themeId => (super.noSuchMethod(
        Invocation.getter(#themeId),
        returnValue: '',
      ) as String);
  @override
  set themeId(String? themeId) => super.noSuchMethod(
        Invocation.setter(
          #themeId,
          themeId,
        ),
        returnValueForMissingStub: null,
      );
  @override
  String get systemBrightnessLightThemeId => (super.noSuchMethod(
        Invocation.getter(#systemBrightnessLightThemeId),
        returnValue: '',
      ) as String);
  @override
  set systemBrightnessLightThemeId(String? systemBrightnessLightThemeId) =>
      super.noSuchMethod(
        Invocation.setter(
          #systemBrightnessLightThemeId,
          systemBrightnessLightThemeId,
        ),
        returnValueForMissingStub: null,
      );
  @override
  String get systemBrightnessDarkThemeId => (super.noSuchMethod(
        Invocation.getter(#systemBrightnessDarkThemeId),
        returnValue: '',
      ) as String);
  @override
  set systemBrightnessDarkThemeId(String? systemBrightnessDarkThemeId) =>
      super.noSuchMethod(
        Invocation.setter(
          #systemBrightnessDarkThemeId,
          systemBrightnessDarkThemeId,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);
  @override
  _i11.Future<void> init() => (super.noSuchMethod(
        Invocation.method(
          #init,
          [],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<void> incrementCurrentNotificationIndex() => (super.noSuchMethod(
        Invocation.method(
          #incrementCurrentNotificationIndex,
          [],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<bool> isExternalCallsSet() => (super.noSuchMethod(
        Invocation.method(
          #isExternalCallsSet,
          [],
        ),
        returnValue: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);
  @override
  _i11.Future<void> saveUserID(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #saveUserID,
          [userId],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<void> saveSignupEpoch(int? signupEpoch) => (super.noSuchMethod(
        Invocation.method(
          #saveSignupEpoch,
          [signupEpoch],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i15.AmountUnit amountUnit(_i9.Coin? coin) => (super.noSuchMethod(
        Invocation.method(
          #amountUnit,
          [coin],
        ),
        returnValue: _i15.AmountUnit.normal,
      ) as _i15.AmountUnit);
  @override
  void updateAmountUnit({
    required _i9.Coin? coin,
    required _i15.AmountUnit? amountUnit,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #updateAmountUnit,
          [],
          {
            #coin: coin,
            #amountUnit: amountUnit,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  int maxDecimals(_i9.Coin? coin) => (super.noSuchMethod(
        Invocation.method(
          #maxDecimals,
          [coin],
        ),
        returnValue: 0,
      ) as int);
  @override
  void updateMaxDecimals({
    required _i9.Coin? coin,
    required int? maxDecimals,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #updateMaxDecimals,
          [],
          {
            #coin: coin,
            #maxDecimals: maxDecimals,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  void addListener(dynamic listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeListener(dynamic listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [NodeService].
///
/// See the documentation for Mockito's code generation for more information.
class MockNodeService extends _i1.Mock implements _i3.NodeService {
  MockNodeService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.SecureStorageInterface get secureStorageInterface => (super.noSuchMethod(
        Invocation.getter(#secureStorageInterface),
        returnValue: _FakeSecureStorageInterface_4(
          this,
          Invocation.getter(#secureStorageInterface),
        ),
      ) as _i7.SecureStorageInterface);
  @override
  List<_i16.NodeModel> get primaryNodes => (super.noSuchMethod(
        Invocation.getter(#primaryNodes),
        returnValue: <_i16.NodeModel>[],
      ) as List<_i16.NodeModel>);
  @override
  List<_i16.NodeModel> get nodes => (super.noSuchMethod(
        Invocation.getter(#nodes),
        returnValue: <_i16.NodeModel>[],
      ) as List<_i16.NodeModel>);
  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);
  @override
  _i11.Future<void> updateDefaults() => (super.noSuchMethod(
        Invocation.method(
          #updateDefaults,
          [],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<void> setPrimaryNodeFor({
    required _i9.Coin? coin,
    required _i16.NodeModel? node,
    bool? shouldNotifyListeners = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setPrimaryNodeFor,
          [],
          {
            #coin: coin,
            #node: node,
            #shouldNotifyListeners: shouldNotifyListeners,
          },
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i16.NodeModel? getPrimaryNodeFor({required _i9.Coin? coin}) =>
      (super.noSuchMethod(Invocation.method(
        #getPrimaryNodeFor,
        [],
        {#coin: coin},
      )) as _i16.NodeModel?);
  @override
  List<_i16.NodeModel> getNodesFor(_i9.Coin? coin) => (super.noSuchMethod(
        Invocation.method(
          #getNodesFor,
          [coin],
        ),
        returnValue: <_i16.NodeModel>[],
      ) as List<_i16.NodeModel>);
  @override
  _i16.NodeModel? getNodeById({required String? id}) =>
      (super.noSuchMethod(Invocation.method(
        #getNodeById,
        [],
        {#id: id},
      )) as _i16.NodeModel?);
  @override
  List<_i16.NodeModel> failoverNodesFor({required _i9.Coin? coin}) =>
      (super.noSuchMethod(
        Invocation.method(
          #failoverNodesFor,
          [],
          {#coin: coin},
        ),
        returnValue: <_i16.NodeModel>[],
      ) as List<_i16.NodeModel>);
  @override
  _i11.Future<void> add(
    _i16.NodeModel? node,
    String? password,
    bool? shouldNotifyListeners,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #add,
          [
            node,
            password,
            shouldNotifyListeners,
          ],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<void> delete(
    String? id,
    bool? shouldNotifyListeners,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [
            id,
            shouldNotifyListeners,
          ],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<void> setEnabledState(
    String? id,
    bool? enabled,
    bool? shouldNotifyListeners,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #setEnabledState,
          [
            id,
            enabled,
            shouldNotifyListeners,
          ],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<void> edit(
    _i16.NodeModel? editedNode,
    String? password,
    bool? shouldNotifyListeners,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #edit,
          [
            editedNode,
            password,
            shouldNotifyListeners,
          ],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  _i11.Future<void> updateCommunityNodes() => (super.noSuchMethod(
        Invocation.method(
          #updateCommunityNodes,
          [],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);
  @override
  void addListener(dynamic listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeListener(dynamic listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
