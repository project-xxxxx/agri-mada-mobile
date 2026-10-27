// Contrôles simples sur la photo avant de croire le modèle (tâche P1.2).

import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Part des pixels de teinte végétale (jaune-vert à vert, assez saturés et
/// assez clairs), mesurée sur l'image telle qu'elle entre dans le modèle.
///
/// Même calcul que `vegetation_ratio` dans ml/scripts/eval_off_topic.py :
/// teinte entre 25° et 160°, saturation ≥ 0,18, luminosité ≥ 0,15.
double vegetationRatio(img.Image image) {
  var plantPixels = 0;
  var totalPixels = 0;

  for (final pixel in image) {
    totalPixels++;
    final r = pixel.rNormalized.toDouble();
    final g = pixel.gNormalized.toDouble();
    final b = pixel.bNormalized.toDouble();
    final maxChannel = math.max(r, math.max(g, b));
    final minChannel = math.min(r, math.min(g, b));
    final delta = maxChannel - minChannel;

    if (maxChannel < 0.15 || delta == 0 || delta / maxChannel < 0.18) continue;

    final double hue;
    if (maxChannel == r) {
      hue = 60 * (((g - b) / delta) % 6);
    } else if (maxChannel == g) {
      hue = 60 * (((b - r) / delta) + 2);
    } else {
      hue = 60 * (((r - g) / delta) + 4);
    }

    if (hue >= 25 && hue <= 160) plantPixels++;
  }

  return totalPixels == 0 ? 0 : plantPixels / totalPixels;
}
