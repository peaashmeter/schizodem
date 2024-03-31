import 'dart:convert';

import 'package:web/web.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final endpoint = 'wss://${window.location.href.split('://').last}ws';

void main() {
  _setupSlider();
  final btn = querySelector('#submit-btn')!;
  btn.onClick.listen((event) {
    _connect();
  });
}

_setupSlider() {
  final valueSlider = querySelector('#value') as HTMLInputElement;
  final valueText = querySelector('#analyzer-value');

  final val = valueSlider.value;
  valueText?.text = val;

  querySelector('#value')?.onInput.listen((_) {
    final val = valueSlider.value;
    valueText?.text = val.toString();
  });
}

_connect() async {
  final generatorField = querySelector('#generator') as HTMLInputElement;
  final analyzerField = querySelector('#analyzer') as HTMLInputElement;
  final valueSlider = querySelector('#value') as HTMLInputElement;
  final queryField = querySelector('#query') as HTMLTextAreaElement;

  final logField = querySelector('#log-content') as HTMLTextAreaElement;
  final resultBlock = querySelector('#result-block') as HTMLDivElement;
  final btn = querySelector('#submit-btn') as HTMLButtonElement;

  resultBlock.style.setProperty('display', 'none');
  logField.value = '';
  btn.disabled = true;

  final wsUrl = Uri.parse(endpoint);
  final channel = WebSocketChannel.connect(wsUrl);
  await channel.ready;
  final data = jsonEncode({
    'genProp': generatorField.value,
    'analProp': analyzerField.value,
    'analValue': num.tryParse(valueSlider.value),
    'topic': queryField.value
  });
  channel.stream.listen((event) {
    dynamic data;

    try {
      data = jsonDecode(event);
    } catch (e) {
      data = event;
    }

    logField.value += '$data\n';

    if ((data as Map).containsKey('result')) {
      resultBlock.style.removeProperty('display');
      final resultContent = resultBlock.querySelector('#result-content');
      resultContent?.textContent = data['result'];
    }
  }, onDone: () => btn.disabled = false);

  channel.sink.add(data);
}
