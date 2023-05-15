import 'package:stackduo/db/main_db.dart';
import 'package:stackduo/models/isar/models/block_explorer.dart';
import 'package:stackduo/utilities/enums/coin_enum.dart';

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

/// returns internal Isar ID for the inserted object/record
Future<int> setBlockExplorerForCoin({
  required Coin coin,
  required Uri url,
}) async {
  return await MainDB.instance.putTransactionBlockExplorer(
    TransactionBlockExplorer(
      ticker: coin.ticker,
      url: url.toString(),
    ),
  );
}

Uri getBlockExplorerTransactionUrlFor({
  required Coin coin,
  required String txid,
}) {
  String? url = MainDB.instance.getTransactionBlockExplorer(coin: coin)?.url;
  if (url == null) {
    return getDefaultBlockExplorerUrlFor(coin: coin, txid: txid);
  } else {
    url = url.replaceAll("%5BTXID%5D", txid);
    return Uri.parse(url);
  }
}
