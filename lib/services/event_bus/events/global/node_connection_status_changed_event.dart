import 'package:stackduo/utilities/enums/coin_enum.dart';
import 'package:stackduo/utilities/logger.dart';

enum NodeConnectionStatus { disconnected, connected }

class NodeConnectionStatusChangedEvent {
  NodeConnectionStatus newStatus;
  String walletId;
  Coin coin;

  NodeConnectionStatusChangedEvent(this.newStatus, this.walletId, this.coin) {
    Logging.instance.log(
        "NodeConnectionStatusChangedEvent fired in $walletId with arg newStatus = $newStatus",
        level: LogLevel.Info);
  }
}
