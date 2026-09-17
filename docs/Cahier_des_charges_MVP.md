# Cahier des charges MVP - Application mobile d'analyse des maladies du riz

## 1. Contexte
Le projet vise a aider les agriculteurs malagasy a diagnostiquer les maladies du riz avec un smartphone Android, dans des zones a connectivite limitee.

## 2. Objectif du MVP
Livrer une application Android utilisable hors ligne qui permet:
- de prendre une photo d'une plante de riz,
- d'obtenir un diagnostic automatique,
- d'afficher un niveau de gravite,
- de proposer des recommandations pratiques,
- d'enregistrer l'historique des analyses.

## 3. Perimetre fonctionnel

### 3.1 Fonctionnalites incluses (MVP)
- Prise de photo depuis l'appareil.
- Analyse locale embarquee par modele IA (on-device).
- Detection d'un ensemble de maladies prioritaires du riz (liste v1 a figer).
- Affichage du diagnostic:
  - maladie detectee,
  - score de confiance,
  - niveau de gravite (faible, moyen, severe).
- Recommandations agricoles contextualisees:
  - traitement conseille,
  - dosage indicatif,
  - prevention pour les cultures voisines.
- Journal local par parcelle:
  - date/heure,
  - photo,
  - diagnostic,
  - gravite,
  - recommandation.
- Interface bilingue Malagasy/Francais.
- Fonctionnement hors ligne apres installation.

### 3.2 Hors perimetre MVP (phase 2)
- Synchronisation cloud obligatoire.
- Dashboard web superviseur.
- Detection multi-cultures (hors riz).
- Telemedecine/agronome en direct.

## 4. Exigences non fonctionnelles

### 4.1 Performance
- Temps de diagnostic cible <= 5 secondes sur smartphone cible.
- Taille application optimisee pour appareils d'entree de gamme.

### 4.2 Fiabilite
- Gestion des cas non exploitables:
  - photo floue,
  - luminosite insuffisante,
  - feuille hors cadre.
- Message explicite et action corrective proposee.

### 4.3 Utilisabilite
- Parcours utilisateur en 3 etapes max: photo -> resultat -> conseil.
- Textes simples, lisibles, et comprehensibles en contexte rural.

### 4.4 Confidentialite
- Donnees conservees localement par defaut.
- Aucune transmission internet imposee dans le MVP.

## 5. Personas cibles
- Agriculteur individuel en zone rurale.
- Responsable de parcelle/cooperative.
- Technicien agricole de terrain.

## 6. User stories principales
- En tant qu'agriculteur, je veux photographier une plante malade afin d'obtenir rapidement un diagnostic.
- En tant qu'agriculteur, je veux recevoir des recommandations simples afin d'agir immediatement.
- En tant qu'utilisateur hors ligne, je veux utiliser l'app sans internet afin qu'elle soit utile dans ma zone.
- En tant que responsable de parcelle, je veux consulter l'historique des analyses afin de suivre l'evolution des maladies.

## 7. Criteres d'acceptation (MVP)
- L'utilisateur peut lancer une analyse depuis une photo en moins de 3 interactions.
- L'application affiche toujours un resultat: diagnostic ou message d'echec guide.
- Le journal enregistre automatiquement chaque diagnostic valide.
- L'application fonctionne en mode avion pour les parcours critiques.
- Le changement de langue Malagasy/Francais est disponible en parametres.

## 8. Risques et mitigations
- Risque: precision faible sur photos de mauvaise qualite.
  - Mitigation: assistant de prise de vue + seuil minimal de confiance.
- Risque: performance degradee sur telephones bas de gamme.
  - Mitigation: optimisation modele et compression.
- Risque: recommandations mal interpretees.
  - Mitigation: formulation simple + pictogrammes + test terrain.

## 9. Indicateurs de succes
- Taux d'analyses completes sans erreur.
- Temps moyen de diagnostic.
- Taux d'utilisation recurrente du journal.
- Satisfaction utilisateur terrain (questionnaire court).

## 10. Livrables MVP
- Application Android installable (APK).
- Modele IA embarque (versionne).
- Jeu de tests fonctionnels de base.
- Documentation utilisateur courte (guide terrain).
