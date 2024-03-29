import 'package:schizodem/identity.dart';
import 'package:schizodem/json.dart';
import 'package:schizodem/logger.dart';

class Commitee {
  final List<GeneratorIdentity> members;
  final AnalyzerIdentity chairman;
  final Logger logger;

  const Commitee._(
      {required this.members, required this.chairman, required this.logger});

  factory Commitee(
      {required String generatorProperty,
      required String analyzerProperty,
      required double analyzerValue,
      required String topic,
      Logger logger = const Logger(null)}) {
    final members = [
      createGenerator(generatorProperty, 0.2),
      createGenerator(generatorProperty, 0.5),
      createGenerator(generatorProperty, 0.8)
    ];
    final chairman = createAnalyzer(topic, analyzerProperty, analyzerValue);

    return Commitee._(members: members, chairman: chairman, logger: logger);
  }

  Future<String> consider() async {
    final issue = chairman.issue;

    logger.log({'issue': issue}.json);

    Map<String, double> opinions = {};
    for (final member in members) {
      final response = await member.generate(issue);
      logger.log({
        'property': member.property,
        'value': member.value,
        'response': response
      }.json);
      await Future.delayed(Duration(seconds: 1));

      final evaluation = await chairman.generate(response);
      logger.log({
        'property': chairman.property,
        'reference': chairman.value,
        'evaluation': evaluation
      }.json);
      await Future.delayed(Duration(seconds: 1));

      if (double.tryParse(evaluation) == null) continue;
      opinions[response] = double.parse(evaluation);
    }

    if (opinions.isEmpty) return 'Не удалось получить ответ.';

    final entries = opinions.entries.toList();
    var str = entries.first.key;
    var val = (entries.first.value - chairman.value).abs();
    for (final e in entries) {
      if ((e.value - chairman.value).abs() < val) {
        str = e.key;
        val = e.value;
      }
    }

    logger.log({'result': str}.json);
    return str;
  }
}
