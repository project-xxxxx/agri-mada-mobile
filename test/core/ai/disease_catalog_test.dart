import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/ai/disease_catalog.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

void main() {
  final labels = File('assets/model/labels.txt')
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  test('chaque classe du modèle a une entrée dans le catalogue', () {
    expect(labels, isNotEmpty);
    for (final label in labels) {
      expect(DiseaseCatalog.of(label), isNotNull, reason: label);
    }
  });

  // Tâche P1.1 : aucun conseil affiché ne cite de produit ni de dosage.
  final forbidden = RegExp(
    r'\d+(,\d+)?\s*(g|kg|l|ml|cl)\s*/|fongicide|cuivre|mancoz|tricyclazole|insecticide|pesticide|herbicide',
    caseSensitive: false,
  );

  for (final code in ['fr', 'mg']) {
    test('aucun conseil ($code) ne cite de produit ou de dosage', () {
      final loc = lookupAppLocalizations(Locale(code));
      for (final label in labels) {
        final info = DiseaseCatalog.of(label)!;
        expect(info.name(loc), isNotEmpty, reason: label);
        expect(info.advice, isNotEmpty, reason: label);
        for (final advice in info.advice) {
          final text = advice(loc);
          expect(forbidden.hasMatch(text), isFalse, reason: text);
        }
      }
    });

    test('aucune fiche du guide ($code) ne cite de produit ou de dosage', () {
      final loc = lookupAppLocalizations(Locale(code));
      for (final info in DiseaseCatalog.guides) {
        final texts = [info.description, info.symptoms, info.causes]
            .whereType<LocalizedText>()
            .map((text) => text(loc));
        for (final text in texts) {
          expect(text, isNotEmpty, reason: info.label);
          expect(forbidden.hasMatch(text), isFalse, reason: text);
        }
      }
    });
  }

  test('chaque classe du modèle a une fiche dans le guide', () {
    final guideLabels = DiseaseCatalog.guides.map((info) => info.label).toSet();
    for (final label in labels) {
      final info = DiseaseCatalog.of(label)!;
      final expected = info.isHealthy ? 'healthy' : info.label;
      expect(guideLabels, contains(expected), reason: label);
    }
  });
}
