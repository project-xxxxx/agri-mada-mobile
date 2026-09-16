import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:agri_mada/core/ai/image_quality.dart';

/// Damier net : beaucoup de bords, donc une variance du laplacien élevée.
img.Image _damier({int taille = 256, int carre = 8, int sombre = 30, int clair = 220}) {
  final image = img.Image(width: taille, height: taille);
  for (var y = 0; y < taille; y++) {
    for (var x = 0; x < taille; x++) {
      final pair = ((x ~/ carre) + (y ~/ carre)).isEven;
      final valeur = pair ? clair : sombre;
      image.setPixelRgb(x, y, valeur, valeur, valeur);
    }
  }
  return image;
}

void main() {
  test('une photo nette et bien exposée est acceptée', () {
    final rapport = assessImageQuality(_damier());

    expect(rapport.acceptable, isTrue);
    expect(rapport.nettete, greaterThan(ImageQualityThresholds.netteteMin));
  });

  test('une photo floue est refusée', () {
    final floue = img.gaussianBlur(_damier(), radius: 8);

    final rapport = assessImageQuality(floue);

    expect(rapport.probleme, ImageQualityIssue.flou);
    expect(rapport.acceptable, isFalse);
  });

  test('une photo trop sombre est refusée', () {
    final rapport = assessImageQuality(_damier(sombre: 2, clair: 60));

    expect(rapport.probleme, ImageQualityIssue.sousExpose);
  });

  test('une photo sombre et floue parle de lumière, pas de mise au point', () {
    // Une photo sombre a mécaniquement peu de contraste : sans cette règle,
    // l'app enverrait l'agriculteur régler la netteté (calibration 2026-09-16).
    final sombreEtFloue = img.gaussianBlur(_damier(sombre: 2, clair: 60), radius: 6);

    expect(assessImageQuality(sombreEtFloue).probleme, ImageQualityIssue.sousExpose);
  });

  test('une photo brûlée par le soleil est refusée', () {
    final rapport = assessImageQuality(_damier(sombre: 200, clair: 255));

    expect(rapport.probleme, ImageQualityIssue.surExpose);
  });

  test('un contre-jour est reconnu comme tel, pas comme une photo sombre', () {
    // Bande de ciel brûlé à gauche, sujet sombre mais net à droite.
    final image = _damier(sombre: 10, clair: 70);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < (image.width * 0.15).round(); x++) {
        image.setPixelRgb(x, y, 255, 255, 255);
      }
    }

    final rapport = assessImageQuality(image);

    expect(rapport.probleme, ImageQualityIssue.contreJour);
    expect(rapport.partBrulee, greaterThan(ImageQualityThresholds.contreJourPartBrulee));
  });

  test('la mesure ne dépend pas de la taille de la photo', () {
    final petite = _damier(taille: 256, carre: 8);
    final grande = _damier(taille: 1024, carre: 32);

    expect(assessImageQuality(grande).acceptable, assessImageQuality(petite).acceptable);
  });
}
