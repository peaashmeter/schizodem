import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

sealed class Identity {
  final String initialMessage;

  const Identity({required this.initialMessage});

  Future<String> generate(String prompt) async {
    final apiKey = Platform.environment['GEMINI_KEY']!;
    final safety = [
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
    ];
    try {
      final model = GenerativeModel(
          model: 'gemini-pro', apiKey: apiKey, safetySettings: safety);
      final response =
          await model.generateContent([Content.text(initialMessage + prompt)]);

      return response.text.toString();
    } catch (e) {
      return e.toString();
    }
  }
}

class GeneratorIdentity extends Identity {
  final String property;
  final double value;

  GeneratorIdentity._(
      {required super.initialMessage,
      required this.property,
      required this.value});
}

class AnalyzerIdentity extends Identity {
  final String issue;
  final String property;
  final double value;

  AnalyzerIdentity._(
      {required super.initialMessage,
      required this.issue,
      required this.property,
      required this.value});
}

GeneratorIdentity createGenerator(String property, double value) {
  final msg = '''Ты получишь запрос и некоторый критерий.
Нужно сформировать ответ на запрос таким образом, чтобы он (по твоему мнению) соответствовал заданному критерию и его значению.
Если значение близко к 0, твой ответ абсолютно не должен соответствовать этому критерию.
Если значение близко к 1, твой ответ должен максимально соответствовать этому критерию.
В ответе должен быть только результат, без комментариев и пояснений.

Пример запроса:
критерий: истинность
значение: 0
запрос: При какой температуре тает снег?

Пример ответа: "300 градусов по цельсию.", так как истинность со значением "0" предполагает в ответе абсолютную ложь.

Пример запроса:
критерий: доброжелательность
значение: 0.25
запрос: посоветуй аниме

Пример ответа: "Посмотри лучше нормальные фильмы.".

Твои данные:
критерий: $property,
значение: $value,
запрос:''';

  return GeneratorIdentity._(
      initialMessage: msg, property: property, value: value);
}

AnalyzerIdentity createAnalyzer(String request, String property, double value) {
  final msg =
      '''Ты получишь исходный запрос, ответ на него и некоторый критерий.
В ответ нужно вернуть только вещественное число от нуля до единицы включительно.
Это число зависит от того, насколько ответ соответствует критерию.
0 - максимальное несоответствие критерию, а 1 - идеальное соответствие.
Пример запроса:
запрос: При какой температуре тает снег?
ответ: 300 градусов по цельсию
критерий: истинность

Пример ответа: 0

Твои данные:
запрос: $request
критерий: $property,
ответ:''';

  return AnalyzerIdentity._(
      initialMessage: msg, issue: request, property: property, value: value);
}
