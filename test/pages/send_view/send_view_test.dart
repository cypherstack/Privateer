// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:stackduo/models/send_view_auto_fill_data.dart';
// import 'package:stackduo/pages/send_view/send_view.dart';
// import 'package:stackduo/providers/providers.dart';
// import 'package:stackduo/services/coins/bitcoin/bitcoin_wallet.dart';
// import 'package:stackduo/services/coins/coin_service.dart';
// import 'package:stackduo/services/coins/manager.dart';
// import 'package:stackduo/services/locale_service.dart';
// import 'package:stackduo/services/node_service.dart';
// import 'package:stackduo/services/wallets.dart';
// import 'package:stackduo/services/wallets_service.dart';
// import 'package:stackduo/utilities/enums/coin_enum.dart';
// import 'package:stackduo/utilities/prefs.dart';
// import 'package:stackduo/utilities/theme/light_colors.dart';
// import 'package:stackduo/utilities/theme/stack_colors.dart';
//
// import 'send_view_test.mocks.dart';
//
// @GenerateMocks([
//   Wallets,
//   WalletsService,
//   NodeService,
//   BitcoinWallet,
//   LocaleService,
//   Prefs,
// ], customMocks: [
//   MockSpec<Manager>(returnNullOnMissingStub: true),
//   MockSpec<CoinServiceAPI>(returnNullOnMissingStub: true),
// ])
// void main() {
//   testWidgets("Send to valid address", (widgetTester) async {
//     final mockWallets = MockWallets();
//     final mockWalletsService = MockWalletsService();
//     final mockNodeService = MockNodeService();
//     final CoinServiceAPI wallet = MockBitcoinWallet();
//     final mockLocaleService = MockLocaleService();
//     final mockPrefs = MockPrefs();
//
//     when(wallet.coin).thenAnswer((_) => Coin.bitcoin);
//     when(wallet.walletName).thenAnswer((_) => "some wallet");
//     when(wallet.walletId).thenAnswer((_) => "wallet id");
//
//     final manager = Manager(wallet);
//     when(mockWallets.getManagerProvider("wallet id")).thenAnswer(
//         (realInvocation) => ChangeNotifierProvider((ref) => manager));
//     when(mockWallets.getManager("wallet id"))
//         .thenAnswer((realInvocation) => manager);
//
//     when(mockLocaleService.locale).thenAnswer((_) => "en_US");
//     when(mockPrefs.currency).thenAnswer((_) => "USD");
//     when(mockPrefs.enableCoinControl).thenAnswer((_) => false);
//     when(wallet.validateAddress("send to address"))
//         .thenAnswer((realInvocation) => true);
//
//     await widgetTester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           walletsChangeNotifierProvider.overrideWithValue(mockWallets),
//           walletsServiceChangeNotifierProvider
//               .overrideWithValue(mockWalletsService),
//           nodeServiceChangeNotifierProvider.overrideWithValue(mockNodeService),
//           localeServiceChangeNotifierProvider
//               .overrideWithValue(mockLocaleService),
//           prefsChangeNotifierProvider.overrideWithValue(mockPrefs),
//           // previewTxButtonStateProvider
//         ],
//         child: MaterialApp(
//           theme: ThemeData(
//             extensions: [
//               StackColors.fromStackColorTheme(
//                 LightColors(),
//               ),
//             ],
//           ),
//           home: SendView(
//             walletId: "wallet id",
//             coin: Coin.bitcoin,
//             autoFillData: SendViewAutoFillData(
//                 address: "send to address", contactLabel: "contact label"),
//           ),
//         ),
//       ),
//     );
//
//     await widgetTester.pumpAndSettle();
//
//     expect(find.text("Send to"), findsOneWidget);
//     expect(find.text("Amount"), findsOneWidget);
//     expect(find.text("Note (optional)"), findsOneWidget);
//     expect(find.text("Transaction fee (estimated)"), findsOneWidget);
//     verify(manager.validateAddress("send to address")).called(1);
//   });
//
//   testWidgets("Send to invalid address", (widgetTester) async {
//     final mockWallets = MockWallets();
//     final mockWalletsService = MockWalletsService();
//     final mockNodeService = MockNodeService();
//     final CoinServiceAPI wallet = MockBitcoinWallet();
//     final mockLocaleService = MockLocaleService();
//     final mockPrefs = MockPrefs();
//
//     when(wallet.coin).thenAnswer((_) => Coin.bitcoin);
//     when(wallet.walletName).thenAnswer((_) => "some wallet");
//     when(wallet.walletId).thenAnswer((_) => "wallet id");
//
//     final manager = Manager(wallet);
//     when(mockWallets.getManagerProvider("wallet id")).thenAnswer(
//         (realInvocation) => ChangeNotifierProvider((ref) => manager));
//     when(mockWallets.getManager("wallet id"))
//         .thenAnswer((realInvocation) => manager);
//
//     when(mockLocaleService.locale).thenAnswer((_) => "en_US");
//     when(mockPrefs.currency).thenAnswer((_) => "USD");
//     when(mockPrefs.enableCoinControl).thenAnswer((_) => false);
//     when(wallet.validateAddress("send to address"))
//         .thenAnswer((realInvocation) => false);
//
//     // when(manager.isOwnAddress("send to address"))
//     //     .thenAnswer((realInvocation) => Future(() => true));
//
//     await widgetTester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           walletsChangeNotifierProvider.overrideWithValue(mockWallets),
//           walletsServiceChangeNotifierProvider
//               .overrideWithValue(mockWalletsService),
//           nodeServiceChangeNotifierProvider.overrideWithValue(mockNodeService),
//           localeServiceChangeNotifierProvider
//               .overrideWithValue(mockLocaleService),
//           prefsChangeNotifierProvider.overrideWithValue(mockPrefs),
//           // previewTxButtonStateProvider
//         ],
//         child: MaterialApp(
//           theme: ThemeData(
//             extensions: [
//               StackColors.fromStackColorTheme(
//                 LightColors(),
//               ),
//             ],
//           ),
//           home: SendView(
//             walletId: "wallet id",
//             coin: Coin.bitcoin,
//             autoFillData: SendViewAutoFillData(
//                 address: "send to address", contactLabel: "contact label"),
//           ),
//         ),
//       ),
//     );
//
//     await widgetTester.pumpAndSettle();
//
//     expect(find.text("Send to"), findsOneWidget);
//     expect(find.text("Amount"), findsOneWidget);
//     expect(find.text("Note (optional)"), findsOneWidget);
//     expect(find.text("Transaction fee (estimated)"), findsOneWidget);
//     expect(find.text("Invalid address"), findsOneWidget);
//     verify(manager.validateAddress("send to address")).called(1);
//   });
// }
