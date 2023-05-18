import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/models/isar/stack_theme.dart';
import 'package:stackduo/themes/theme_providers.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

final coinImageProvider = Provider.family<String, Coin>((ref, coin) {
  final assets = ref.watch(themeAssetsProvider);

  if (assets is ThemeAssets) {
    switch (coin) {
      case Coin.bitcoin:
      case Coin.bitcoinTestNet:
        return assets.bitcoinImage;

      case Coin.monero:
        return assets.moneroImage;
    }
  } else {
    return (assets as ThemeAssetsV2).coinImages[coin.mainNetVersion]!;
  }
});

final coinImageSecondaryProvider = Provider.family<String, Coin>((ref, coin) {
  final assets = ref.watch(themeAssetsProvider);

  if (assets is ThemeAssets) {
    switch (coin) {
      case Coin.bitcoin:
      case Coin.bitcoinTestNet:
        return assets.bitcoinImageSecondary;

      case Coin.monero:
        return assets.moneroImageSecondary;
    }
  } else {
    return (assets as ThemeAssetsV2).coinSecondaryImages[coin.mainNetVersion]!;
  }
});
