import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/features/knowledge/domain/entities/fiche.dart';
import 'package:agri_mada/features/knowledge/domain/fiche_search.dart';

void main() {
  final fiches = (jsonDecode(File('assets/knowledge/fiches.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>()
      .map((json) => Fiche.fromJson(json))
      .toList();

  test('une requête vide renvoie toutes les fiches', () {
    expect(rechercherFiches(fiches, ''), hasLength(fiches.length));
  });

  test('le nom malgache retrouve la fiche française (menalavitra -> pyriculariose)', () {
    final resultats = rechercherFiches(fiches, 'menalavitra');
    expect(resultats.map((f) => f.id), contains('pyriculariose'));
  });

  test('un synonyme malgache secondaire retrouve la fiche (mativondrana -> rymv)', () {
    final resultats = rechercherFiches(fiches, 'mativondrana');
    expect(resultats.map((f) => f.id), contains('rymv'));
  });

  test('le nom français retrouve la fiche (pyriculariose)', () {
    final resultats = rechercherFiches(fiches, 'pyriculariose');
    expect(resultats.map((f) => f.id), contains('pyriculariose'));
  });

  test('un symptôme retrouve la fiche correspondante', () {
    final resultats = rechercherFiches(fiches, 'losange');
    expect(resultats.map((f) => f.id), contains('pyriculariose'));
  });

  // Sur un clavier de téléphone, les accents ne sont pas tapés.
  test('la recherche ignore les accents (sterilite -> stérilité due au froid)', () {
    final resultats = rechercherFiches(fiches, 'sterilite');
    expect(resultats.map((f) => f.id), contains('sterilite_froid'));
  });

  test('une requête accentuée retrouve aussi la fiche', () {
    final resultats = rechercherFiches(fiches, 'stérilité');
    expect(resultats.map((f) => f.id), contains('sterilite_froid'));
  });

  test('une requête sans correspondance renvoie une liste vide', () {
    expect(rechercherFiches(fiches, 'zzzzz_inexistant'), isEmpty);
  });
}
