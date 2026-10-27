// Contrôle de la photo avant analyse (tâche P2.2).
//
// Le décodage et la mesure tournent dans un isolate : sur un téléphone d'entrée
// de gamme, analyser une photo de 4000 pixels de côté sur le thread de l'écran
// le fige pendant une seconde.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'image_quality.dart';

/// Retourne null quand la photo est illisible (fichier tronqué, format inconnu).
Future<ImageQualityReport?> verifierPhoto(File photo) async {
  final bytes = await photo.readAsBytes();
  return compute(evaluerBytes, bytes);
}

@visibleForTesting
ImageQualityReport? evaluerBytes(Uint8List bytes) {
  final decodee = img.decodeImage(bytes);
  if (decodee == null) return null;
  return assessImageQuality(bakeExifOrientation(decodee));
}
