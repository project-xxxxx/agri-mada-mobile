import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:agri_mada/core/ai/image_checks.dart';

img.Image _filled(int r, int g, int b) {
  final image = img.Image(width: 10, height: 10);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  return image;
}

void main() {
  test('une feuille verte est entièrement végétale', () {
    expect(vegetationRatio(_filled(60, 150, 40)), 1.0);
  });

  test('un écran gris, un ciel bleu ou une photo noire ne le sont pas', () {
    expect(vegetationRatio(_filled(128, 128, 128)), 0.0);
    expect(vegetationRatio(_filled(40, 90, 200)), 0.0);
    expect(vegetationRatio(_filled(10, 20, 8)), 0.0);
  });

  test('mesure la part de pixels végétaux', () {
    final image = _filled(128, 128, 128);
    for (var y = 0; y < 10; y++) {
      for (var x = 0; x < 5; x++) {
        image.setPixelRgb(x, y, 60, 150, 40);
      }
    }

    expect(vegetationRatio(image), closeTo(0.5, 1e-9));
  });
}
