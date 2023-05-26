import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:stackduo/utilities/logger.dart';

// hacky fix to receive large jsonrpc responses
class JsonRPC {
  JsonRPC({
    required this.host,
    required this.port,
    this.useSSL = false,
    this.connectionTimeout = const Duration(seconds: 60),
  });
  final bool useSSL;
  final String host;
  final int port;
  final Duration connectionTimeout;
  Socket? socket;

  Future<dynamic> request(String jsonRpcRequest) async {
    final completer = Completer<dynamic>();
    final List<int> responseData = [];

    void dataHandler(List<int> data) {
      responseData.addAll(data);

      // 0x0A is newline
      // https://electrumx-spesmilo.readthedocs.io/en/latest/protocol-basics.html
      if (data.last == 0x0A) {
        try {
          final response = json.decode(String.fromCharCodes(responseData));
          completer.complete(response);
        } catch (e, s) {
          Logging.instance
              .log("JsonRPC json.decode: $e\n$s", level: LogLevel.Error);
          completer.completeError(e, s);
        } finally {
          socket?.destroy();
        }
      }
    }

    void errorHandler(Object error, StackTrace trace) {
      Logging.instance
          .log("JsonRPC errorHandler: $error\n$trace", level: LogLevel.Error);
      completer.completeError(error, trace);
      socket?.destroy();
    }

    void doneHandler() {
      socket?.destroy();
    }

    if (socket != null) {
      // TODO check if the socket is valid, alive, connected, etc
    }

    if (useSSL) {
      socket ??= await SecureSocket.connect(host, port,
          timeout: connectionTimeout,
          onBadCertificate: (_) => true);
      socket!.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: true);
    } else {
      socket ??= await Socket.connect(host, port, timeout: connectionTimeout);
      socket!.listen(dataHandler,
      onError: errorHandler, onDone: doneHandler, cancelOnError: true);
    }

    socket?.write('$jsonRpcRequest\r\n');

    return completer.future;
  }
}
