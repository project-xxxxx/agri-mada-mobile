import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/ai/disease_catalog.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
import 'package:agri_mada/features/scan/domain/questionnaire.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('chaque organe pose entre deux et quatre questions', () {
    for (final organe in Organe.values) {
      final questions = ScanQuestionnaire.pour(organe);
      expect(questions.length, inInclusiveRange(2, 4), reason: organe.code);
      expect(questions.map((q) => q.id).toSet(), hasLength(questions.length));
      for (final question in questions) {
        expect(question.options.length, greaterThanOrEqualTo(3), reason: question.id);
        expect(question.options.map((o) => o.id).toSet(), hasLength(question.options.length));
        expect(question.options.last.id, 'je_ne_sais_pas',
            reason: 'chaque question doit permettre de ne pas savoir');
      }
    }
  });

  for (final code in ['fr', 'mg']) {
    test('toutes les questions et réponses sont traduites ($code)', () {
      final loc = lookupAppLocalizations(Locale(code));

      for (final organe in Organe.values) {
        for (final question in ScanQuestionnaire.pour(organe)) {
          expect(question.prompt(loc).trim(), isNotEmpty, reason: question.id);
          for (final option in question.options) {
            expect(option.label(loc).trim(), isNotEmpty, reason: '${question.id}/${option.id}');
          }
        }
      }
    });
  }

  test('les indices ne citent que des fiches connues du catalogue', () {
    for (final organe in Organe.values) {
      for (final question in ScanQuestionnaire.pour(organe)) {
        for (final option in question.options) {
          for (final label in option.indices.keys) {
            expect(DiseaseCatalog.of(label), isNotNull,
                reason: '$label n\'a pas de fiche : l\'app ne doit pas le nommer');
          }
        }
      }
    }
  });

  test('seul un organe analysé par le modèle apporte des indices', () {
    for (final organe in Organe.values.where((o) => !o.usesModel)) {
      final indices = ScanQuestionnaire.pour(organe)
          .expand((question) => question.options)
          .expand((option) => option.indices.keys);

      expect(indices, isEmpty,
          reason: '${organe.code} : sans modèle, les réponses partent au technicien');
    }
  });

  group('indices', () {
    test('cumule les poids des réponses choisies', () {
      final indices = ScanQuestionnaire.indices(Organe.feuille, const {
        'feuille_taches': 'bandes_bord',
        'feuille_exsudat': 'oui',
      });

      expect(indices['Bacterial leaf blight'], closeTo(0.9 + 0.7, 1e-9));
      expect(indices['Brown spot'], closeTo(-0.5, 1e-9));
    });

    test('ignore les questions sans réponse et les réponses inconnues', () {
      final indices = ScanQuestionnaire.indices(Organe.feuille, const {
        'feuille_taches': 'option_qui_n_existe_pas',
        'question_inconnue': 'oui',
      });

      expect(indices, isEmpty);
    });

    test('« je ne sais pas » n\'apporte aucun indice', () {
      final indices = ScanQuestionnaire.indices(Organe.feuille, const {
        'feuille_taches': 'je_ne_sais_pas',
      });

      expect(indices, isEmpty);
    });
  });
}
