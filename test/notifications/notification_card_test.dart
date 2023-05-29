// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:stackduo/models/notification_model.dart';
// import 'package:stackduo/notifications/notification_card.dart';
// import 'package:stackduo/utilities/assets.dart';
// import 'package:stackduo/utilities/enums/coin_enum.dart';
// import 'package:stackduo/utilities/theme/light_colors.dart';
// import 'package:stackduo/utilities/theme/stack_colors.dart';
//
// void main() {
//   testWidgets("test notification card", (widgetTester) async {
//     final key = UniqueKey();
//     final notificationCard = NotificationCard(
//       key: key,
//       notification: NotificationModel(
//           id: 1,
//           title: "notification title",
//           description: "notification description",
//           iconAssetName: Assets.svg.iconFor(coin: Coin.bitcoin),
//           date: DateTime.parse("1662544771"),
//           walletId: "wallet id",
//           read: true,
//           shouldWatchForUpdates: true,
//           coinName: "Bitcoin"),
//     );
//
//     await widgetTester.pumpWidget(
//       MaterialApp(
//         theme: ThemeData(
//           extensions: [
//             StackColors.fromStackColorTheme(LightColors()),
//           ],
//         ),
//         home: Material(
//           child: notificationCard,
//         ),
//       ),
//     );
//
//     expect(find.byWidget(notificationCard), findsOneWidget);
//     expect(find.text("notification title"), findsOneWidget);
//     expect(find.text("notification description"), findsOneWidget);
//     expect(find.byType(SvgPicture), findsOneWidget);
//   });
// }
