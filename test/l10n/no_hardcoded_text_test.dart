// Garde-fou P1.5 : aucun texte visible par l'agriculteur n'est écrit en dur
// dans lib/. Tout passe par les fichiers ARB (français et malgache).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Textes visibles : `Text('…')` et paramètres d'interface à valeur littérale.
final _patterns = [
  RegExp(r"""\bText\(\s*'((?:[^'\\\n]|\\.)*)'"""),
  RegExp(r'''\bText\(\s*"((?:[^"\\\n]|\\.)*)"'''),
  RegExp(
    r"""\b(?:label|title|hintText|labelText|tooltip|semanticsLabel|message)\s*:\s*'((?:[^'\\\n]|\\.)*)'""",
  ),
];

/// Noms propres qui ne se traduisent pas.
const _allowed = {'AgriMada'};

/// Étiquettes du modèle et codes internes, jamais affichés tels quels.
const _excludedDirectories = ['lib/l10n/', 'lib/core/ai/'];

final _interpolation = RegExp(r'\$\{[^}]*\}|\$[A-Za-z_]\w*');
final _word = RegExp(r'[A-Za-zÀ-ÿ]{3,}');

void main() {
  test('aucun texte visible écrit en dur dans lib/', () {
    final violations = <String>[];

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) {
      final path = file.path.replaceAll(r'\', '/');
      return path.endsWith('.dart') &&
          !path.endsWith('.g.dart') &&
          !path.endsWith('.freezed.dart') &&
          !_excludedDirectories.any(path.contains);
    });

    for (final file in files) {
      final source = file.readAsStringSync();
      for (final pattern in _patterns) {
        for (final match in pattern.allMatches(source)) {
          final literal = match.group(1)!;
          final visible = literal.replaceAll(_interpolation, '');
          if (_allowed.contains(literal) || !_word.hasMatch(visible)) continue;

          final lineStart = source.lastIndexOf('\n', match.start) + 1;
          final lineEnd = source.indexOf('\n', match.start);
          final line = source.substring(
            lineStart,
            lineEnd == -1 ? source.length : lineEnd,
          );
          if (line.trimLeft().startsWith('//')) continue;

          final lineNumber = '\n'.allMatches(source.substring(0, match.start)).length + 1;
          violations.add('${file.path.replaceAll(r'\', '/')}:$lineNumber  $literal');
        }
      }
    }

    expect(violations, isEmpty, reason: '\n${violations.join('\n')}');
  });
}
