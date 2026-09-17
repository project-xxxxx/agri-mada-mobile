import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/utils/number_parsing.dart';

void main() {
  group('parseSurfaceEnHectares', () {
    test('convertit les ares en hectares', () {
      expect(parseSurfaceEnHectares('25', enAres: true), closeTo(0.25, 1e-9));
      expect(parseSurfaceEnHectares('5,5', enAres: true), closeTo(0.055, 1e-9));
    });

    test('garde les hectares tels quels', () {
      expect(parseSurfaceEnHectares('0,55', enAres: false), closeTo(0.55, 1e-9));
    });

    test('une saisie vide ou invalide ne donne pas de surface', () {
      expect(parseSurfaceEnHectares('', enAres: true), isNull);
      expect(parseSurfaceEnHectares('deux ares', enAres: true), isNull);
      expect(parseSurfaceEnHectares('-3', enAres: false), isNull);
    });
  });

  group('parseLocalizedDecimal', () {
    test('accepte la virgule décimale', () {
      expect(parseLocalizedDecimal('0,55'), 0.55);
    });

    test('accepte le point décimal', () {
      expect(parseLocalizedDecimal('0.55'), 0.55);
    });

    test('ignore les espaces', () {
      expect(parseLocalizedDecimal(' 1 234,5 '), 1234.5);
    });

    test('renvoie null pour une saisie vide', () {
      expect(parseLocalizedDecimal('   '), isNull);
    });

    test('renvoie null pour une saisie invalide', () {
      expect(parseLocalizedDecimal('abc'), isNull);
      expect(parseLocalizedDecimal('1,5,3'), isNull);
    });

    test('renvoie null pour une valeur négative', () {
      expect(parseLocalizedDecimal('-2'), isNull);
    });
  });
}
