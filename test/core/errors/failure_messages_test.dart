import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/errors/failure.dart';
import 'package:agri_mada/core/errors/failure_messages.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

void main() {
  for (final code in ['fr', 'mg']) {
    test('chaque cause d\'échec a son propre message ($code)', () {
      final loc = lookupAppLocalizations(Locale(code));
      final messages = [
        for (final failureCode in FailureCode.values) failureMessage(failureCode, loc),
      ];

      expect(messages.every((message) => message.trim().isNotEmpty), isTrue);
      expect(messages.toSet(), hasLength(FailureCode.values.length));
    });
  }
}
