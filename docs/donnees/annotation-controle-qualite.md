# Annotation et contrôle qualité des données (P3.5)

Tâche P3.5 du plan de correction. Recentrée sur les jeux publics par la décision
ADR-008 : pas de collecte terrain dans l'app, donc pas de photos locales à
annoter pour l'instant. Le travail de l'agronome porte sur la validation des
correspondances déjà faites, pas sur de nouvelles photos.

## Ce qui reste à valider par l'agronome référent

1. **`ml/label_map.yaml`** (P3.2) : pour chaque jeu public, l'étiquette brute de
   l'hébergeur (ex. `"Leaf scald"`) a été rapprochée d'un id de
   `ml/taxonomy_v1.yaml` (ex. `echaudure`) sans relecture agronomique. À
   vérifier en priorité, par ordre de risque de contresens :
   - les étiquettes ambiguës ou traduites de l'anglais (`Narrow Brown Leaf Spot`
     → `cercosporiose`, `Leaf scald` → `echaudure`, `Sheath Blight`/`Shath Blight`
     → `rhizoctone`) ;
   - les classes marquées `a_confirmer` dans la taxonomie (présence à Madagascar
     non retrouvée dans les sources consultées : `echaudure`, `rhizoctone`,
     `mildiou`, `sterilite_froid`, `faux_charbon`, `brunissure_bacterienne_panicule`,
     `bakanae`, `racines_noires_pourries`, `racines_rongees`) — un modèle ne doit
     nommer une de ces classes que si sa présence est confirmée entre-temps ;
   - la classe `blast` de `paddy_doctor`, mappée à `pyriculariose_feuille` par
     défaut faute de sous-catégorie déclarée par l'hébergeur (feuille vs cou) : à
     vérifier par échantillonnage si le jeu mélange les deux.
2. **Échantillonnage** : un tirage aléatoire d'au moins 20 images par classe et
   par jeu (voir `ml/data/manifest.csv` pour la liste), à confronter à l'œil aux
   fiches de `ml/taxonomy_v1.yaml` (`sources`) et aux cours de l'école partenaire
   (`docs/connaissances/cours-pathologie-riz.md`).
3. **Cas douteux** : si une classe reste incertaine après relecture visuelle, le
   consigner dans `ml/taxonomy_v1.yaml` (champ `notes`) plutôt que de deviner —
   cohérent avec ADR-006 (ne pas nommer sans certitude).

## Hors périmètre pour l'instant

- **Double annotation à 20 % (kappa ≥ 0,7)** et **escalade laboratoire** (ELISA
  RYMV, extraction de nématodes, isolement bactérien) : prévues par le plan pour
  des photos de terrain collectées localement. Sans collecte terrain (ADR-008),
  rien à annoter deux fois pour l'instant. À réactiver si l'équipe revient sur
  cette décision.
- **Label Studio auto-hébergé** : non installé (nécessite un serveur dédié). Pour
  l'échantillonnage ci-dessus, une revue directe des dossiers `ml/data/raw/`
  (une fois extraits) suffit à cette échelle.

## Historique

| Date | Changement |
|---|---|
| 2026-09-16 | Première version, recentrée sur les jeux publics (ADR-008) |
