import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/models/isar/stack_theme.dart';
import 'package:stackduo/themes/theme_providers.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

final coinIconProvider = Provider.family<String, Coin>((ref, coin) {
  final assets = ref.watch(themeAssetsProvider);

  if (assets is ThemeAssets) {
    switch (coin) {
      case Coin.bitcoin:
      case Coin.bitcoinTestNet:
        return assets.bitcoin;
      case Coin.monero:
        return assets.monero;
    }
  } else if (assets is ThemeAssetsV2) {
    return (assets).coinIcons[coin.mainNetVersion]!;
  } else {
    return (assets as ThemeAssetsV3).coinIcons[coin.mainNetVersion]!;
  }
});
