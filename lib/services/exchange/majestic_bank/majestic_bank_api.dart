import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import 'package:stackduo/exceptions/exchange/exchange_exception.dart';
import 'package:stackduo/exceptions/exchange/majestic_bank/mb_exception.dart';
import 'package:stackduo/exceptions/exchange/pair_unavailable_exception.dart';
import 'package:stackduo/models/exchange/majestic_bank/mb_limit.dart';
import 'package:stackduo/models/exchange/majestic_bank/mb_order.dart';
import 'package:stackduo/models/exchange/majestic_bank/mb_order_calculation.dart';
import 'package:stackduo/models/exchange/majestic_bank/mb_order_status.dart';
import 'package:stackduo/models/exchange/majestic_bank/mb_rate.dart';
import 'package:stackduo/services/exchange/exchange_response.dart';
import 'package:stackduo/utilities/logger.dart';

class MajesticBankAPI {
  // ensure no api calls go out to mb
  static const String scheme = ""; //"""https";
  static const String authority = ""; //"""majesticbank.sc";
  static const String version = ""; //"""v1";
  static const kMajesticBankRefCode = ""; //"""rjWugM";

  MajesticBankAPI._();

  static final MajesticBankAPI _instance = MajesticBankAPI._();

  static MajesticBankAPI get instance => _instance;

  /// set this to override using standard http client. Useful for testing
  http.Client? client;

  Uri _buildUri({required String endpoint, Map<String, String>? params}) {
    return Uri.https(authority, "/api/$version/$endpoint", params);
  }

  Future<dynamic> _makeGetRequest(Uri uri) async {
    return null;

    final client = this.client ?? http.Client();
    int code = -1;
    try {
      final response = await client.get(
        uri,
      );

      code = response.statusCode;

      final parsed = jsonDecode(response.body);

      return parsed;
    } catch (e, s) {
      Logging.instance.log(
        "_makeRequest($uri) HTTP:$code threw: $e\n$s",
        level: LogLevel.Error,
      );
      rethrow;
    }
  }

  Future<ExchangeResponse<List<MBRate>>> getRates() async {
    final uri = _buildUri(
      endpoint: "rates",
    );

    try {
      final jsonObject = await _makeGetRequest(uri);

      final map = Map<String, dynamic>.from(jsonObject as Map);
      final List<MBRate> rates = [];
      for (final key in map.keys) {
        final currencies = key.split("-");
        if (currencies.length == 2) {
          final rate = MBRate(
            fromCurrency: currencies.first,
            toCurrency: currencies.last,
            rate: Decimal.parse(map[key].toString()),
          );
          rates.add(rate);
        }
      }
      return ExchangeResponse(value: rates);
    } catch (e, s) {
      Logging.instance.log("getRates exception: $e\n$s", level: LogLevel.Error);
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }

  Future<ExchangeResponse<MBLimit>> getLimit({
    required String fromCurrency,
  }) async {
    final uri = _buildUri(
      endpoint: "limits",
      params: {
        "from_currency": fromCurrency,
      },
    );

    try {
      final jsonObject = await _makeGetRequest(uri);

      final map = Map<String, dynamic>.from(jsonObject as Map);

      final limit = MBLimit(
        currency: fromCurrency,
        min: Decimal.parse(map["min"].toString()),
        max: Decimal.parse(map["max"].toString()),
      );

      return ExchangeResponse(value: limit);
    } catch (e, s) {
      Logging.instance
          .log("getLimits exception: $e\n$s", level: LogLevel.Error);
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }

  Future<ExchangeResponse<List<MBLimit>>> getLimits() async {
    final uri = _buildUri(
      endpoint:
          "rates", // limits are included in the rates call for some reason???
    );

    try {
      final jsonObject = await _makeGetRequest(uri);

      final map = Map<String, dynamic>.from(jsonObject as Map)["limits"] as Map;
      final List<MBLimit> limits = [];
      for (final key in map.keys) {
        final limit = MBLimit(
          currency: key as String,
          min: Decimal.parse(map[key]["min"].toString()),
          max: Decimal.parse(map[key]["max"].toString()),
        );
        limits.add(limit);
      }

      return ExchangeResponse(value: limits);
    } catch (e, s) {
      Logging.instance
          .log("getLimits exception: $e\n$s", level: LogLevel.Error);
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }

  /// If [reversed] then the amount is the expected receive_amount, otherwise
  /// the amount is assumed to be the from_amount.
  Future<ExchangeResponse<MBOrderCalculation>> calculateOrder({
    required String amount,
    required bool reversed,
    required String fromCurrency,
    required String receiveCurrency,
  }) async {
    final params = {
      "from_currency": fromCurrency,
      "receive_currency": receiveCurrency,
    };

    if (reversed) {
      params["receive_amount"] = amount;
    } else {
      params["from_amount"] = amount;
    }

    final uri = _buildUri(
      endpoint: "calculate",
      params: params,
    );

    try {
      final jsonObject = await _makeGetRequest(uri);
      final map = Map<String, dynamic>.from(jsonObject as Map);

      if (map["error"] != null) {
        final errorMessage = map["extra"] as String?;
        if (errorMessage != null &&
            errorMessage.startsWith("Bad") &&
            errorMessage.endsWith("currency symbol")) {
          return ExchangeResponse(
            exception: PairUnavailableException(
              errorMessage,
              ExchangeExceptionType.generic,
            ),
          );
        } else {
          return ExchangeResponse(
            exception: ExchangeException(
              errorMessage ?? "Error: ${map["error"]}",
              ExchangeExceptionType.generic,
            ),
          );
        }
      }

      final result = MBOrderCalculation(
        fromCurrency: map["from_currency"] as String,
        fromAmount: Decimal.parse(map["from_amount"].toString()),
        receiveCurrency: map["receive_currency"] as String,
        receiveAmount: Decimal.parse(map["receive_amount"].toString()),
      );

      return ExchangeResponse(value: result);
    } catch (e, s) {
      Logging.instance.log(
          "calculateOrder $fromCurrency-$receiveCurrency exception: $e\n$s",
          level: LogLevel.Error);
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }

  Future<ExchangeResponse<MBOrder>> createOrder({
    required String fromAmount,
    required String fromCurrency,
    required String receiveCurrency,
    required String receiveAddress,
  }) async {
    final params = {
      "from_amount": fromAmount,
      "from_currency": fromCurrency,
      "receive_currency": receiveCurrency,
      "receive_address": receiveAddress,
      "referral_code": kMajesticBankRefCode,
    };

    final uri = _buildUri(endpoint: "exchange", params: params);

    try {
      final now = DateTime.now();
      final jsonObject = await _makeGetRequest(uri);
      final json = Map<String, dynamic>.from(jsonObject as Map);

      final order = MBOrder(
        orderId: json["trx"] as String,
        fromCurrency: json["from_currency"] as String,
        fromAmount: Decimal.parse(json["from_amount"].toString()),
        receiveCurrency: json["receive_currency"] as String,
        receiveAmount: Decimal.parse(json["receive_amount"].toString()),
        address: json["address"] as String,
        orderType: MBOrderType.floating,
        expiration: json["expiration"] as int,
        createdAt: now,
      );

      return ExchangeResponse(value: order);
    } catch (e, s) {
      Logging.instance
          .log("createOrder exception: $e\n$s", level: LogLevel.Error);
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }

  /// Fixed rate for 10 minutes, useful for payments.
  /// If [reversed] then the amount is the expected receive_amount, otherwise
  /// the amount is assumed to be the from_amount.
  Future<ExchangeResponse<MBOrder>> createFixedRateOrder({
    required String amount,
    required String fromCurrency,
    required String receiveCurrency,
    required String receiveAddress,
    required bool reversed,
  }) async {
    final params = {
      "from_currency": fromCurrency,
      "receive_currency": receiveCurrency,
      "receive_address": receiveAddress,
      "referral_code": kMajesticBankRefCode,
    };

    if (reversed) {
      params["receive_amount"] = amount;
    } else {
      params["from_amount"] = amount;
    }

    final uri = _buildUri(endpoint: "pay", params: params);

    try {
      final now = DateTime.now();
      final jsonObject = await _makeGetRequest(uri);
      final json = Map<String, dynamic>.from(jsonObject as Map);

      final order = MBOrder(
        orderId: json["trx"] as String,
        fromCurrency: json["from_currency"] as String,
        fromAmount: Decimal.parse(json["from_amount"].toString()),
        receiveCurrency: json["receive_currency"] as String,
        receiveAmount: Decimal.parse(json["receive_amount"].toString()),
        address: json["address"] as String,
        orderType: MBOrderType.fixed,
        expiration: json["expiration"] as int,
        createdAt: now,
      );

      return ExchangeResponse(value: order);
    } catch (e, s) {
      Logging.instance
          .log("createFixedRateOrder exception: $e\n$s", level: LogLevel.Error);
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }

  Future<ExchangeResponse<MBOrderStatus>> trackOrder({
    required String orderId,
  }) async {
    final uri = _buildUri(endpoint: "track", params: {
      "trx": orderId,
    });

    try {
      final jsonObject = await _makeGetRequest(uri);
      final json = Map<String, dynamic>.from(jsonObject as Map);

      if (json.length == 2) {
        return ExchangeResponse(
          exception: MBException(
            json["status"] as String,
            ExchangeExceptionType.orderNotFound,
          ),
        );
      }

      final status = MBOrderStatus(
        orderId: json["trx"] as String,
        status: json["status"] as String,
        fromCurrency: json["from_currency"] as String,
        fromAmount: Decimal.parse(json["from_amount"].toString()),
        receiveCurrency: json["receive_currency"] as String,
        receiveAmount: Decimal.parse(json["receive_amount"].toString()),
        address: json["address"] as String,
        received: Decimal.parse(json["received"].toString()),
        confirmed: Decimal.parse(json["confirmed"].toString()),
      );

      return ExchangeResponse(value: status);
    } catch (e, s) {
      Logging.instance.log(
        "trackOrder exception when trying to parse $json: $e\n$s",
        level: LogLevel.Error,
      );
      return ExchangeResponse(
        exception: ExchangeException(
          e.toString(),
          ExchangeExceptionType.generic,
        ),
      );
    }
  }
}
