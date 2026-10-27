// Génère assets/model/model_version.json à partir des étiquettes réelles du
// modèle (tâche P1.4), pour que l'app n'annonce que les maladies reconnues.
//
// Usage :
//   dart run tool/gen_model_version.dart [version]   régénère le fichier
//   dart run tool/gen_model_version.dart --check     échoue si le fichier ne
//                                                    correspond plus au modèle
//
// L'empreinte SHA-256 du modèle rend le contrôle indépendant du poste : la date
// ne change que lorsque le fichier du modèle change. Le test
// test/core/ai/model_version_test.dart fait le même contrôle en CI.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

void main(List<String> args) {
  final check = args.contains('--check');
  final positional = args.where((arg) => !arg.startsWith('--')).toList();

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

  final modelSha256 = sha256.convert(modelFile.readAsBytesSync()).toString();
  final previous = outFile.existsSync()
      ? jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};

  if (check) {
    final previousLabels = (previous['maladies_supportees'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList();
    final problems = <String>[
      if (!_sameList(previousLabels, labels))
        'maladies_supportees ne correspond pas à labels.txt',
      if (previous['modele_sha256'] != modelSha256)
        'modele_sha256 ne correspond pas à agrimada_model.tflite',
    ];
    if (problems.isEmpty) {
      stdout.writeln('model_version.json est à jour.');
    } else {
      stderr.writeln(
        'model_version.json est périmé : ${problems.join(' ; ')}.\n'
        'Lancer : dart run tool/gen_model_version.dart',
      );
      exitCode = 1;
    }
    return;
  }

  final version = positional.isNotEmpty
      ? positional.first
      : (previous['version'] as String? ?? '1.0.0');
  final previousDate = previous['date'] as String?;
  final sameModel = previous['modele_sha256'] == modelSha256 ||
      (previous['modele_sha256'] == null && previousDate != null);
  final date = sameModel && previousDate != null
      ? previousDate
      : DateTime.now().toIso8601String().substring(0, 10);

  final content = const JsonEncoder.withIndent('  ').convert({
    'version': version,
    'date': date,
    'modele_sha256': modelSha256,
    'maladies_supportees': labels,
  });
  outFile.writeAsStringSync('$content\n');
  stdout.writeln(
    'model_version.json : v$version, $date, ${labels.length} classes',
  );
}

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
