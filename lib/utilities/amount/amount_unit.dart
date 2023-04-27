import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:stackduo/utilities/amount/amount.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

enum AmountUnit {
  normal(0),
  milli(3),
  micro(6),
  nano(9),
  pico(12),
  femto(15),
  atto(18),
  ;

  const AmountUnit(this.shift);
  final int shift;
}

extension AmountUnitExt on AmountUnit {
  String unitForCoin(Coin coin) {
    switch (this) {
      case AmountUnit.normal:
        return coin.ticker;
      case AmountUnit.milli:
        return "m${coin.ticker}";
      case AmountUnit.micro:
        return "µ${coin.ticker}";
      case AmountUnit.nano:
        if (coin == Coin.monero) {
          return "n${coin.ticker}";
        } else {
          return "sats";
        }
      case AmountUnit.pico:
        if (coin == Coin.monero) {
          return "p${coin.ticker}";
        } else {
          return "invalid";
        }
      case AmountUnit.femto:
      case AmountUnit.atto:
        return "invalid";
    }
  }

  String displayAmount({
    required Amount amount,
    required String locale,
    required Coin coin,
    required int maxDecimalPlaces,
  }) {
    assert(maxDecimalPlaces >= 0);
    // ensure we don't shift past minimum atomic value
    final realShift = math.min(shift, amount.fractionDigits);

    // shifted to unit
    final Decimal shifted = amount.decimal.shift(realShift);

    // get shift int value without fractional value
    final BigInt wholeNumber = shifted.toBigInt();

    // get decimal places to display
    final int places = math.max(0, amount.fractionDigits - realShift);

    // start building the return value with just the whole value
    String returnValue = wholeNumber.toString();

    // if any decimal places should be shown continue building the return value
    if (places > 0) {
      // get the fractional value
      final Decimal fraction = shifted - shifted.truncate();

      // get final decimal based on max precision wanted
      final int actualDecimalPlaces = math.min(places, maxDecimalPlaces);

      // get remainder string without the prepending "0."
      String remainder = fraction.toString().substring(2);

      if (remainder.length > actualDecimalPlaces) {
        // trim unwanted trailing digits
        remainder = remainder.substring(0, actualDecimalPlaces);
      } else if (remainder.length < actualDecimalPlaces) {
        // pad with zeros to achieve requested precision
        for (int i = remainder.length; i < actualDecimalPlaces; i++) {
          remainder += "0";
        }
      }

      // get decimal separator based on locale
      final String separator =
          (numberFormatSymbols[locale] as NumberSymbols?)?.DECIMAL_SEP ??
              (numberFormatSymbols[locale.substring(0, 2)] as NumberSymbols?)
                  ?.DECIMAL_SEP ??
              ".";

      // append separator and fractional amount
      returnValue += "$separator$remainder";
    }

    // return the value with the proper unit symbol
    return "$returnValue ${unitForCoin(coin)}";
  }
}
