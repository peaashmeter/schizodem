import 'dart:convert';

import 'package:schizodem/commitee.dart';
import 'package:schizodem/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void onData(WebSocketChannel ws, dynamic data) async {
  final logger = Logger(ws);

  try {
    final json = jsonDecode(data) as Map;
    Commitee(
            generatorProperty: json['genProp'],
            analyzerProperty: json['analProp'],
            analyzerValue: json['analValue'].toDouble(),
            topic: json['topic'],
            logger: logger)
        .consider()
        .then((_) => ws.sink.close());
  } catch (e) {
    logger.log("ERROR: $e, data: $data");
    ws.sink.close();
  }
}
