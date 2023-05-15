import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/themes/theme_providers.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

final coinIconProvider = Provider.family<String, Coin>((ref, coin) {
  final assets = ref.watch(themeProvider).assets;
  switch (coin) {
    case Coin.bitcoin:
    case Coin.bitcoinTestNet:
      return assets.bitcoin;

    case Coin.monero:
      return assets.monero;
  }
});
