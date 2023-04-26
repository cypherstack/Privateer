import 'package:stackduo/utilities/enums/coin_enum.dart';

Uri getBlockExplorerTransactionUrlFor({
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
