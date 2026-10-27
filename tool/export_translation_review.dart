// Exporte toutes les traductions dans un tableau de relecture pour l'agronome
// malgachophone (tâche P1.5) : clé, français, malgache, statut, remarque.
//
// Usage : dart run tool/export_translation_review.dart
// Le tableau (CSV, séparateur « ; », UTF-8 avec BOM pour Excel) est écrit dans
// docs/traductions/relecture-malgache.csv. Les statuts et remarques déjà saisis
// sont conservés d'un export à l'autre.

import 'dart:convert';
import 'dart:io';

const _output = 'docs/traductions/relecture-malgache.csv';
const _header = ['cle', 'francais', 'malagasy', 'statut', 'remarque'];

void main() {
  final french = _messages('assets/l10n/app_fr.arb');
  final malagasy = _messages('assets/l10n/app_mg.arb');
  final previous = _previousReview();

  final rows = <List<String>>[
    _header,
    for (final key in french.keys)
      [
        key,
        french[key]!,
        malagasy[key] ?? '',
        previous[key]?.$1 ?? (malagasy.containsKey(key) ? 'à relire' : 'traduction manquante'),
        previous[key]?.$2 ?? '',
      ],
  ];

  final file = File(_output)..parent.createSync(recursive: true);
  file.writeAsStringSync(
    '﻿${rows.map((row) => row.map(_cell).join(';')).join('\r\n')}\r\n',
    encoding: utf8,
  );

  final missing = rows.skip(1).where((row) => row[2].isEmpty).length;
  stdout.writeln('$_output : ${rows.length - 1} clés, $missing sans traduction malgache');
}

Map<String, String> _messages(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final entry in json.entries)
      if (!entry.key.startsWith('@')) entry.key: entry.value.toString(),
  };
}

Map<String, (String, String)> _previousReview() {
  final file = File(_output);
  if (!file.existsSync()) return const {};
  final lines = file.readAsStringSync().replaceFirst('﻿', '').split('\r\n');
  return {
    for (final line in lines.skip(1).where((line) => line.isNotEmpty))
      if (_parse(line) case [final key, _, _, final status, final note]) key: (status, note),
  };
}

String _cell(String value) => '"${value.replaceAll('"', '""').replaceAll('\n', r'\n')}"';

List<String> _parse(String line) {
  final cells = <String>[];
  final buffer = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (quoted) {
      if (char == '"' && i + 1 < line.length && line[i + 1] == '"') {
        buffer.write('"');
        i++;
      } else if (char == '"') {
        quoted = false;
      } else {
        buffer.write(char);
      }
    } else if (char == '"') {
      quoted = true;
    } else if (char == ';') {
      cells.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  cells.add(buffer.toString());
  return cells;
}
