import 'dart:convert';
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

  // P1.5, étendu par ADR-014 : chaque problème que le modèle peut nommer se
  // consulte dans le guide, soit dans les fiches de l'ancien modèle, soit dans
  // le guide complet (assets/knowledge/fiches.json, P5.3).
  test('chaque classe du modèle a une fiche dans le guide', () {
    final guideLabels = DiseaseCatalog.guides.map((info) => info.label).toSet();
    final fichesConnaissance = (jsonDecode(File('assets/knowledge/fiches.json').readAsStringSync()) as List)
        .map((fiche) => (fiche as Map<String, dynamic>)['id'] as String)
        .toSet();
    for (final label in labels) {
      final info = DiseaseCatalog.of(label)!;
      if (info.isRejection) continue;
      if (info.isHealthy) {
        expect(guideLabels, contains('healthy'), reason: label);
        continue;
      }
      expect(
        guideLabels.contains(info.label) || fichesConnaissance.contains(info.ficheId),
        isTrue,
        reason: '$label : ni fiche du guide, ni fiche de connaissance (ficheId ${info.ficheId})',
      );
    }
  });

  test('le rejet pas_riz et l\'état sain ne sont jamais annoncés comme des maladies reconnues', () {
    final reconnus = DiseaseCatalog.problemesReconnus(labels);
    expect(reconnus, isNot(contains('pas_riz')));
    expect(reconnus, isNot(contains('feuille_saine')));
    expect(reconnus, contains('pyriculariose_feuille'));
  });
}
