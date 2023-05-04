import 'package:decimal/decimal.dart';
import 'package:stackduo/services/exchange/trocador/response_objects/trocador_quote.dart';

class TrocadorRate {
  final String tradeId;
  final DateTime date;
  final String tickerFrom;
  final String tickerTo;
  final String coinFrom;
  final String coinTo;
  final String networkFrom;
  final String networkTo;
  final Decimal amountFrom;
  final Decimal amountTo;
  final String provider;
  final bool fixed;
  final bool payment;
  final String status;
  final List<TrocadorQuote> quotes;

  TrocadorRate({
    required this.tradeId,
    required this.date,
    required this.tickerFrom,
    required this.tickerTo,
    required this.coinFrom,
    required this.coinTo,
    required this.networkFrom,
    required this.networkTo,
    required this.amountFrom,
    required this.amountTo,
    required this.provider,
    required this.fixed,
    required this.payment,
    required this.status,
    required this.quotes,
  });

  factory TrocadorRate.fromMap(Map<String, dynamic> map) {
    final list =
        List<Map<String, dynamic>>.from(map['quotes']['quotes'] as List);
    final quotes = list.map((quote) => TrocadorQuote.fromMap(quote)).toList();

    return TrocadorRate(
      tradeId: map['trade_id'] as String,
      date: DateTime.parse(map['date'] as String),
      tickerFrom: map['ticker_from'] as String,
      tickerTo: map['ticker_to'] as String,
      coinFrom: map['coin_from'] as String,
      coinTo: map['coin_to'] as String,
      networkFrom: map['network_from'] as String,
      networkTo: map['network_to'] as String,
      amountFrom: Decimal.parse(map['amount_from'].toString()),
      amountTo: Decimal.parse(map['amount_to'].toString()),
      provider: map['provider'] as String,
      fixed: map['fixed'] as bool,
      payment: map['payment'] as bool,
      status: map['status'] as String,
      quotes: quotes,
    );
  }

  @override
  String toString() {
    final quotesString = quotes.map((quote) => quote.toString()).join(', ');
    return 'TrocadorRate('
        'tradeId: $tradeId, '
        'date: $date, '
        'tickerFrom: $tickerFrom, '
        'tickerTo: $tickerTo, '
        'coinFrom: $coinFrom, '
        'coinTo: $coinTo, '
        'networkFrom: $networkFrom, '
        'networkTo: $networkTo, '
        'amountFrom: $amountFrom, '
        'amountTo: $amountTo, '
        'provider: $provider, '
        'fixed: $fixed, '
        'payment: $payment, '
        'status: $status, '
        'quotes: [$quotesString] '
        ')';
  }
}
