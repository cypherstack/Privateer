import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/models/exchange/exchange_form_state.dart';

final exchangeFormStateProvider =
    ChangeNotifierProvider<ExchangeFormState>((ref) => ExchangeFormState());
