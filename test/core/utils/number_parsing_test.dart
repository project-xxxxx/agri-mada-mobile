import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/core/utils/number_parsing.dart';

void main() {
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
