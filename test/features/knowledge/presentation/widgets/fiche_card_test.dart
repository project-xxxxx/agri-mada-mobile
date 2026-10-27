// Le garde-fou d'ADR-010 (« une fiche brouillon ne s'affiche jamais sans le
// dire ») est vérifié en CI par une recherche de texte dans lib/ : elle reste
// verte si quelqu'un supprime la condition d'affichage. Ce test vérifie le
// comportement réel, pas la présence de la chaîne.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agri_mada/features/knowledge/domain/entities/fiche.dart';
import 'package:agri_mada/features/knowledge/presentation/widgets/fiche_card.dart';
import 'package:agri_mada/features/scan/domain/entities/organe.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

Fiche _fiche({required String statut}) => Fiche(
      id: 'pyriculariose',
      noms: const FicheNoms(fr: 'Pyriculariose', mg: 'Menalavitra'),
      organes: const {
        Organe.feuille: ['lésions en losange'],
      },
      confusions: const [],
      conditions: const FicheConditions(),
      prevention: const ['semences saines'],
      luttechimiqueStatut: 'a_completer_liste_DPV',
      sources: const [],
      statutValidation: statut,
    );

Future<void> _afficher(WidgetTester tester, Fiche fiche) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ListView(children: [FicheCard(fiche: fiche)])),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byType(ExpansionTile));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('une fiche brouillon affiche le bandeau de divulgation', (tester) async {
    await _afficher(tester, _fiche(statut: 'brouillon'));

    final loc = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(find.text(loc.guidesDraftBadge), findsOneWidget);
  });

  testWidgets('une fiche validée n’affiche pas le bandeau', (tester) async {
    await _afficher(tester, _fiche(statut: 'valide'));

    final loc = await AppLocalizations.delegate.load(const Locale('fr'));
    expect(find.text(loc.guidesDraftBadge), findsNothing);
  });
}
