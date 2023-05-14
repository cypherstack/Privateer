import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/themes/theme_providers.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

final coinImageProvider = Provider.family<String, Coin>((ref, coin) {
  final assets = ref.watch(themeProvider).assets;
  switch (coin) {
    case Coin.bitcoin:
    case Coin.bitcoinTestNet:
      return assets.bitcoinImage;

    case Coin.monero:
      return assets.moneroImage;
  }
});

final coinImageSecondaryProvider = Provider.family<String, Coin>((ref, coin) {
  final assets = ref.watch(themeProvider).assets;
  switch (coin) {
    case Coin.bitcoin:
    case Coin.bitcoinTestNet:
      return assets.bitcoinImageSecondary;

    case Coin.monero:
      return assets.moneroImageSecondary;
  }
});
