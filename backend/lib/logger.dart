import 'package:web_socket_channel/web_socket_channel.dart';

class Logger {
  final WebSocketChannel? ws;
  const Logger(this.ws);

  void log(Object? data) {
    ws?.sink.add(data);
    print(data);
  }
}
