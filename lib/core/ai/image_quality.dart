// Contrôle de qualité de la photo avant analyse (tâche P2.2).
//
// Trois mesures, toutes calculées sur la même image réduite :
//   - netteté : variance du laplacien, qui s'effondre quand la photo est floue ;
//   - luminosité moyenne ;
//   - part de pixels brûlés, qui trahit un contre-jour ou un plein soleil.
//
// Les seuils viennent de ml/scripts/calibrate_image_quality.py, mesuré sur des
// photos de riz prises au champ et leurs versions floutées, sombres et brûlées.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

enum ImageQualityIssue { flou, sousExpose, surExpose, contreJour }

/// Seuils mesurés le 2026-09-16 sur 120 photos de riz prises au champ et leurs
/// versions dégradées (ml/reports/qualite_photo_2026-09-16.md).
abstract final class ImageQualityThresholds {
  /// Netteté : les photos correctes commencent à 635 (5 % les plus basses),
  /// une photo légèrement bougée plafonne à 151.
  static const double netteteMin = 350;

  /// Luminosité moyenne acceptable, sur 0 à 1 : les photos correctes vont de
  /// 0,36 à 0,64 ; les photos sous-exposées plafonnent à 0,16 et les photos
  /// brûlées commencent à 0,70.
  static const double luminositeMin = 0.25;
  static const double luminositeMax = 0.67;

  /// Part de pixels brûlés au-delà de laquelle la photo est illisible
  /// (2,6 % au plus sur une photo correcte).
  static const double partBruleeMax = 0.12;

  /// Contre-jour : beaucoup de blanc autour d'un sujet sombre.
  static const double contreJourPartBrulee = 0.08;
  static const double contreJourLuminosite = 0.36;

  /// Côté de l'image réduite sur laquelle tout est mesuré.
  static const int tailleAnalyse = 512;
}

class ImageQualityReport {
  const ImageQualityReport({
    required this.nettete,
    required this.luminosite,
    required this.partBrulee,
    required this.probleme,
  });

  /// Variance du laplacien : plus c'est haut, plus la photo est nette.
  final double nettete;

  /// Luminosité moyenne, de 0 (noir) à 1 (blanc).
  final double luminosite;

  /// Part de pixels proches du blanc pur.
  final double partBrulee;

  /// null quand la photo est utilisable.
  final ImageQualityIssue? probleme;

  bool get acceptable => probleme == null;
}

/// Évalue une photo. L'orientation EXIF doit être corrigée avant l'appel
/// (voir [bakeExifOrientation]).
ImageQualityReport assessImageQuality(img.Image image) {
  final reduite = _reduire(image);
  final largeur = reduite.width;
  final hauteur = reduite.height;

  // Luminance 0-255, une seule lecture des pixels.
  final luminance = Float32List(largeur * hauteur);
  var somme = 0.0;
  var brules = 0;
  var index = 0;
  for (var y = 0; y < hauteur; y++) {
    for (var x = 0; x < largeur; x++) {
      final pixel = reduite.getPixel(x, y);
      final valeur = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
      luminance[index++] = valeur;
      somme += valeur;
      if (valeur >= 250) brules++;
    }
  }

  final total = largeur * hauteur;
  final luminosite = total == 0 ? 0.0 : somme / total / 255.0;
  final partBrulee = total == 0 ? 0.0 : brules / total;
  final nettete = _varianceLaplacien(luminance, largeur, hauteur);

  return ImageQualityReport(
    nettete: nettete,
    luminosite: luminosite,
    partBrulee: partBrulee,
    probleme: _probleme(
      nettete: nettete,
      luminosite: luminosite,
      partBrulee: partBrulee,
    ),
  );
}

/// Applique la rotation notée dans les données EXIF : sans cela, une photo
/// prise en portrait arrive couchée dans le modèle (tâche P2.2).
img.Image bakeExifOrientation(img.Image image) => img.bakeOrientation(image);

/// L'exposition est jugée avant la netteté : une photo sombre a mécaniquement
/// peu de contraste, donc une netteté basse. La calibration du 2026-09-16 le
/// montre (netteté médiane 162 sur des photos assombries, contre 2591 sur les
/// mêmes photos correctes). Annoncer « photo floue » enverrait l'agriculteur
/// régler la mise au point alors qu'il lui manque de la lumière.
ImageQualityIssue? _probleme({
  required double nettete,
  required double luminosite,
  required double partBrulee,
}) {
  if (partBrulee >= ImageQualityThresholds.contreJourPartBrulee &&
      luminosite < ImageQualityThresholds.contreJourLuminosite) {
    return ImageQualityIssue.contreJour;
  }
  if (luminosite < ImageQualityThresholds.luminositeMin) {
    return ImageQualityIssue.sousExpose;
  }
  if (luminosite > ImageQualityThresholds.luminositeMax ||
      partBrulee > ImageQualityThresholds.partBruleeMax) {
    return ImageQualityIssue.surExpose;
  }
  if (nettete < ImageQualityThresholds.netteteMin) return ImageQualityIssue.flou;
  return null;
}

img.Image _reduire(img.Image image) {
  final cote = math.max(image.width, image.height);
  if (cote <= ImageQualityThresholds.tailleAnalyse) return image;
  final facteur = ImageQualityThresholds.tailleAnalyse / cote;
  return img.copyResize(
    image,
    width: math.max(1, (image.width * facteur).round()),
    height: math.max(1, (image.height * facteur).round()),
  );
}

double _varianceLaplacien(Float32List luminance, int largeur, int hauteur) {
  if (largeur < 3 || hauteur < 3) return 0;

  var somme = 0.0;
  var sommeCarres = 0.0;
  var compte = 0;
  for (var y = 1; y < hauteur - 1; y++) {
    for (var x = 1; x < largeur - 1; x++) {
      final centre = luminance[y * largeur + x];
      final laplacien = 4 * centre -
          luminance[(y - 1) * largeur + x] -
          luminance[(y + 1) * largeur + x] -
          luminance[y * largeur + x - 1] -
          luminance[y * largeur + x + 1];
      somme += laplacien;
      sommeCarres += laplacien * laplacien;
      compte++;
    }
  }

  if (compte == 0) return 0;
  final moyenne = somme / compte;
  return sommeCarres / compte - moyenne * moyenne;
}
