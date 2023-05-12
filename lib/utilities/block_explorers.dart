import 'package:stackduo/utilities/enums/coin_enum.dart';

import '../db/main_db.dart';
import '../models/isar/models/block_explorer.dart';

Uri getDefaultBlockExplorerUrlFor({
  required Coin coin,
  required String txid,
}) {
  switch (coin) {
    case Coin.bitcoin:
      return Uri.parse("https://mempool.space/tx/$txid");
    case Coin.bitcoinTestNet:
      return Uri.parse("mempool.space/testnet/tx/$txid");
    case Coin.monero:
      return Uri.parse("https://xmrchain.net/tx/$txid");
  }
}

Future<int> setBlockExplorerForCoin(
    {required Coin coin, required Uri url}
    ) async {
  await MainDB.instance.putTransactionBlockExplorer(TransactionBlockExplorer(ticker: coin.ticker, url: url.toString()));
  return 0;
}

Uri getBlockExplorerTransactionUrlFor({
  required Coin coin,
  required String txid,
}) {
  var url = MainDB.instance.getTransactionBlockExplorer(coin: coin)?.url.toString();
  if (url == null) {
    return getDefaultBlockExplorerUrlFor(coin: coin, txid: txid);
  } else {
    url =  url.replaceAll("%5BTXID%5D", txid);
    return Uri.parse(url);
  }
}
