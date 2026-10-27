import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/features/knowledge/domain/entities/fiche.dart';

void main() {
  final bundle = (jsonDecode(File('assets/knowledge/fiches.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();

  test('le bundle contient au moins 30 fiches', () {
    expect(bundle.length, greaterThanOrEqualTo(30));
  });

  test('chaque fiche du bundle se décode sans erreur', () {
    for (final json in bundle) {
      final fiche = Fiche.fromJson(json);
      expect(fiche.id, isNotEmpty);
      expect(fiche.noms.fr, isNotEmpty);
      expect(fiche.organes, isNotEmpty, reason: fiche.id);
    }
  });

  test('toutes les fiches sont brouillon (aucune validée par un agronome)', () {
    for (final json in bundle) {
      final fiche = Fiche.fromJson(json);
      expect(fiche.estBrouillon, isTrue, reason: fiche.id);
    }
  });

  // Cohérent avec test/core/ai/disease_catalog_test.dart (P1.1) : aucune
  // fiche n'affiche de produit ni de dosage, même en brouillon.
  final forbidden = RegExp(
    r'\d+(,\d+)?\s*(g|kg|l|ml|cl)\s*/|fongicide|cuivre|mancoz|tricyclazole|insecticide|pesticide|herbicide',
    caseSensitive: false,
  );

  test('aucune fiche ne cite de produit ou de dosage', () {
    for (final json in bundle) {
      final fiche = Fiche.fromJson(json);
      expect(fiche.luttechimiqueStatut, isIn(['a_completer_liste_DPV', 'sans_objet']), reason: fiche.id);
      for (final conseil in fiche.prevention) {
        expect(forbidden.hasMatch(conseil), isFalse, reason: '${fiche.id} : $conseil');
      }
      for (final symptomes in fiche.organes.values) {
        for (final symptome in symptomes) {
          expect(forbidden.hasMatch(symptome), isFalse, reason: '${fiche.id} : $symptome');
        }
      }
    }
  });

  test('pyriculariose regroupe bien ses trois organes', () {
    final json = bundle.firstWhere((f) => f['id'] == 'pyriculariose');
    final fiche = Fiche.fromJson(json);
    expect(fiche.noms.mg, 'Menalavitra');
    expect(fiche.organes.keys.map((o) => o.code), containsAll(['feuille', 'collet', 'panicule_grains']));
  });

  // Tant qu'un locuteur malgache n'a pas traduit une question de confusion,
  // elle vaut null dans les fiches : l'écran doit montrer le français, pas un
  // texte d'attente.
  test('une question de confusion non traduite retombe sur le français', () {
    const confusion = FicheConfusion(ficheId: 'bls', questionFr: 'Les stries sont-elles fines ?');
    expect(confusion.question(enMalgache: true), 'Les stries sont-elles fines ?');
  });

  test('aucune question de confusion du bundle ne contient de texte d’attente', () {
    for (final json in bundle) {
      final fiche = Fiche.fromJson(json);
      for (final confusion in fiche.confusions) {
        expect(confusion.questionMg?.contains('à traduire'), isNot(isTrue), reason: fiche.id);
      }
    }
  });

  test('rymv porte ses synonymes malgaches (mativondrana, fondrabe)', () {
    final json = bundle.firstWhere((f) => f['id'] == 'rymv');
    final fiche = Fiche.fromJson(json);
    expect(fiche.noms.autresNomsMg, containsAll(['Mativondrana', 'Fondrabe']));
  });
}
