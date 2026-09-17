# Fiches de connaissance (P5.1, P5.3)

Une fiche par problème identifiable par un agriculteur ou un technicien — pas
une par classe de taxonomie : la pyriculariose, qui touche feuille, collet et
panicule, n'a qu'une fiche avec une entrée par organe.

- 27 fiches sont **générées** depuis `ml/taxonomy_v1.yaml` par
  `ml/scripts/generate_fiches.py` : ne pas les modifier à la main, elles sont
  réécrites à chaque exécution.
- 3 fiches sont **écrites à la main** (`carence_azote`, `carence_phosphore`,
  `carence_potassium`) : contenu tiré du cours de pathologie du riz de l'école
  partenaire (EPSA, pages 48-49) et, pour le phosphore, de la fiche FOFIFA
  P-dipping. Le générateur refuse de démarrer si l'un de ces ids apparaît dans
  sa table `FICHES`.

## Statut

- **Toutes les fiches sont `brouillon`** (`validation.statut`) : aucune n'a été
  relue par l'agronome référent. L'app les embarque quand même (ADR-010), à
  condition d'afficher le bandeau `guidesDraftBadge` — vérifié par
  `test/features/knowledge/presentation/widgets/fiche_card_test.dart`.
- **Aucun produit ni dosage** (ADR-005). `lutte_chimique.statut` vaut
  `a_completer_liste_DPV` (liste officielle à obtenir) ou `sans_objet` pour un
  trouble nutritionnel, qui se corrige par la fertilisation.
- **Traductions malgaches incomplètes** : `noms.mg` et les questions de
  confusion valent `null` tant qu'un locuteur malgache n'a pas traduit. L'app
  affiche alors le français, jamais un texte d'attente.

## Validation

`ml/scripts/validate_fiches.py` (job `fiches` de la CI) vérifie le schéma
`knowledge/schema.json`, les références croisées entre fiches, la parité des
codes d'organe avec l'enum `Organe` de l'app, et que le bundle embarqué
`assets/knowledge/fiches.json` est bien le reflet de ce dossier.

Après toute modification d'une fiche, reconstruire aussi l'index du conseil
(ADR-011), sans quoi `backend/tests/test_rag.py` échoue :

    cd backend && venv/Scripts/python scripts/build_rag_index.py

## Reste à faire

- Validation agronomique de chaque fiche, puis passage en `valide`.
- Traduction malgache relue par un locuteur natif.
- Une fois P5.4 engagée : découpage en extraits pour le RAG.
