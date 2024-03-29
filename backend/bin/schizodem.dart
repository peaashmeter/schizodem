import 'package:schizodem/api.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:web_socket_channel/web_socket_channel.dart';

void main(List<String> arguments) async {
  shelf_io.serve(webSocketHandler((WebSocketChannel ws) {
    ws.stream.listen((data) => onData(ws, data));
  }), 'localhost', 8081);
}
