// Chargement des fiches de connaissance depuis l'asset embarqué (tâche P5.3).

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/fiche.dart';

class FicheRepository {
  const FicheRepository();

  static const _cheminAsset = 'assets/knowledge/fiches.json';

  Future<List<Fiche>> chargerToutes() async {
    final contenu = await rootBundle.loadString(_cheminAsset);
    final liste = jsonDecode(contenu) as List<dynamic>;
    return liste.map((e) => Fiche.fromJson(e as Map<String, dynamic>)).toList();
  }
}
