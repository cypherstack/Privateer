import 'package:flutter/material.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

const kCoinThemeColorDefaults = CoinThemeColorDefault();

class CoinThemeColorDefault {
  const CoinThemeColorDefault();

  Color get bitcoin => const Color(0xFFFCC17B);
  Color get monero => const Color(0xFFFF9E6B);

  Color forCoin(Coin coin) {
    switch (coin) {
      case Coin.bitcoin:
      case Coin.bitcoinTestNet:
        return bitcoin;
      case Coin.monero:
        return monero;
    }
  }
}
