// Génère assets/model/model_version.json à partir des étiquettes réelles du
// modèle (tâche P1.4), pour que l'app n'annonce que les maladies reconnues.
//
// Usage : dart run tool/gen_model_version.dart [version]
// La date est celle de la dernière modification du fichier du modèle.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final modelFile = File('assets/model/agrimada_model.tflite');
  final labelsFile = File('assets/model/labels.txt');
  final outFile = File('assets/model/model_version.json');

  final labels = labelsFile
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (labels.isEmpty) {
    stderr.writeln('assets/model/labels.txt est vide.');
    exitCode = 1;
    return;
  }

  final previous = outFile.existsSync()
      ? jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};
  final version =
      args.isNotEmpty ? args.first : (previous['version'] as String? ?? '1.0.0');
  final date = modelFile.lastModifiedSync().toIso8601String().substring(0, 10);

  final content = const JsonEncoder.withIndent('  ').convert({
    'version': version,
    'date': date,
    'maladies_supportees': labels,
  });
  outFile.writeAsStringSync('$content\n');
  stdout.writeln(
    'model_version.json : v$version, $date, ${labels.length} classes',
  );
}
