import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/features/journal/domain/entities/contexte_parcelle.dart';
import 'package:agri_mada/features/journal/domain/entities/regions_madagascar.dart';
import 'package:agri_mada/features/journal/domain/entities/varietes_riz.dart';

void main() {
  group('stadeDepuisRepiquage', () {
    final repiquage = DateTime(2026, 9, 1);

    StadeCulture? stadeApres(int jours) => stadeDepuisRepiquage(
          repiquage,
          maintenant: repiquage.add(Duration(days: jours)),
        );

    test('suit le cycle depuis le repiquage', () {
      expect(stadeApres(0), StadeCulture.reprise);
      expect(stadeApres(14), StadeCulture.reprise);
      expect(stadeApres(15), StadeCulture.tallage);
      expect(stadeApres(44), StadeCulture.tallage);
      expect(stadeApres(45), StadeCulture.montaison);
      expect(stadeApres(69), StadeCulture.montaison);
      expect(stadeApres(70), StadeCulture.epiaison);
      expect(stadeApres(94), StadeCulture.epiaison);
      expect(stadeApres(95), StadeCulture.maturation);
    });

    test('sans date de repiquage, aucun stade n\'est inventé', () {
      expect(stadeDepuisRepiquage(null), isNull);
    });

    test('une date de repiquage à venir ne donne pas de stade', () {
      expect(stadeApres(-3), isNull);
    });
  });

  group('TrancheAltitude', () {
    test('se déduit de l\'altitude GPS', () {
      expect(TrancheAltitude.depuisMetres(12), TrancheAltitude.moins800);
      expect(TrancheAltitude.depuisMetres(799), TrancheAltitude.moins800);
      expect(TrancheAltitude.depuisMetres(800), TrancheAltitude.de800a1200);
      expect(TrancheAltitude.depuisMetres(1250), TrancheAltitude.de1200a1500);
      expect(TrancheAltitude.depuisMetres(1600), TrancheAltitude.plus1500);
    });

    test('les codes font l\'aller-retour', () {
      for (final tranche in TrancheAltitude.values) {
        expect(TrancheAltitude.fromCode(tranche.code), tranche);
      }
      expect(TrancheAltitude.fromCode('inconnu'), isNull);
    });
  });

  test('les codes des autres listes font l\'aller-retour', () {
    for (final ecosysteme in Ecosysteme.values) {
      expect(Ecosysteme.fromCode(ecosysteme.code), ecosysteme);
    }
    for (final saison in SaisonRiz.values) {
      expect(SaisonRiz.fromCode(saison.code), saison);
    }
    for (final stade in StadeCulture.values) {
      expect(StadeCulture.fromCode(stade.code), stade);
    }
  });

  group('listes de référence', () {
    test('les 23 régions de Madagascar sont présentes, sans doublon', () {
      expect(regionsMadagascar, hasLength(23));
      expect(regionsMadagascar.toSet(), hasLength(23));
      expect(regionsMadagascar, contains('Vakinankaratra'));
      expect(regionsMadagascar, contains('Alaotra-Mangoro'));
      // Découpage de 2021 : Vatovavy-Fitovinany a été séparée en deux régions.
      expect(regionsMadagascar, containsAll(['Vatovavy', 'Fitovinany']));
      expect(
        regionsMadagascar,
        orderedEquals(regionsMadagascar.toList()..sort()),
        reason: 'la liste est triée pour être cherchée du regard',
      );
    });

    test('les variétés viennent des fiches FOFIFA, sans doublon', () {
      expect(varietesRiz.toSet(), hasLength(varietesRiz.length));
      expect(varietesRiz, contains('Sambatra (FOFIFA 200)'));
      expect(varietesRiz, contains('X265'));
      expect(varietesRiz, isNot(contains(varieteLocaleOuInconnue)));
    });
  });
}
