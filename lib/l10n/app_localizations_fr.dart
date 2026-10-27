// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get splashSubtitle => 'Diagnostiquer les maladies du riz, hors ligne';

  @override
  String get loginForgotPasswordTitle => 'Mot de passe oublié ?';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'nom@exemple.com';

  @override
  String get loginEmailRequired => 'Veuillez entrer votre email';

  @override
  String get loginEmailInvalid => 'Email invalide';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSend => 'Envoyer';

  @override
  String get featureComingSoon => 'Fonctionnalité bientôt disponible';

  @override
  String get registerComingSoon => 'Inscription bientôt disponible';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginPasswordRequired => 'Veuillez entrer votre mot de passe';

  @override
  String get loginPhoneLabel => 'Téléphone';

  @override
  String get loginPhoneRequired => 'Veuillez entrer votre numéro';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginNoAccount => 'Pas encore de compte ?';

  @override
  String get loginRegister => 'S\'inscrire';

  @override
  String get loginHello => 'Bonjour !';

  @override
  String get loginWelcome => 'Ravie de vous revoir sur AgriMada';

  @override
  String get welcomeHeadline => 'L\'intelligence au service de vos rizières';

  @override
  String get welcomeBody =>
      'Un riz sain et protégé grâce à l\'expertise AgriMada.';

  @override
  String get welcomeStart => 'Commencer';

  @override
  String welcomeModelVersion(String version) {
    return 'Modèle v$version';
  }

  @override
  String get homeSoonMessage => 'Bientôt disponible';

  @override
  String get homeServicesTitle => 'Nos Services';

  @override
  String get homeMenuSemantics => 'Ouvrir le menu';

  @override
  String homeHelloUser(String name) {
    return 'Bonjour, $name!';
  }

  @override
  String get homeFarmerDefault => 'Agriculteur';

  @override
  String get homeReadyForAnalysis => 'Prêt pour une analyse ?';

  @override
  String get homeOfflineMode => 'Mode hors ligne';

  @override
  String get homeHelpSemantics => 'Aide';

  @override
  String get homeSummaryTitle => 'Résumé de votre exploitation';

  @override
  String get homeSystemReady => 'Analyse photo prête';

  @override
  String get homeSystemAiUnavailable => 'Analyse photo indisponible';

  @override
  String homeRegisteredPlots(int count) {
    return '$count parcelle(s) enregistrée(s)';
  }

  @override
  String get homeServicePlotsTitle => 'Mes parcelles';

  @override
  String get homeServicePlotsDescription =>
      'Suivez vos rizières, surfaces cultivées et l\'état sanitaire de chaque parcelle';

  @override
  String get homeServiceCropsTitle => 'État des cultures';

  @override
  String get homeServiceCropsDescription =>
      'Consultez l\'état global de vos cultures et les niveaux de risque actuels';

  @override
  String get homeServiceSolutionsTitle => 'Maladies du riz';

  @override
  String get homeServiceSolutionsDescription =>
      'Reconnaître chaque maladie : symptômes, causes et gestes de prévention';

  @override
  String get homeServicePreventionTitle => 'Prévenir les maladies';

  @override
  String get homeServicePreventionDescription =>
      'Apprenez les bonnes pratiques pour protéger vos rizières et éviter les pertes';

  @override
  String get homeScanPlantSemantics => 'Scanner une plante';

  @override
  String get homeTabHome => 'Accueil';

  @override
  String get homeTabJournal => 'Journal';

  @override
  String get scanIaUnavailable =>
      'Diagnostic IA indisponible, veuillez réessayer';

  @override
  String get scanSelectPlot => 'Choisir une parcelle';

  @override
  String get scanNoPlotTitle => 'Aucune parcelle';

  @override
  String get scanNoPlotDescription =>
      'Créez d\'abord une parcelle dans votre journal agricole avant de scanner.';

  @override
  String get commonOk => 'OK';

  @override
  String get scanGoToJournal => 'Aller au journal';

  @override
  String get scanLoading => 'Analyse en cours...';

  @override
  String get scanPointCamera => 'Pointez la caméra vers\nla feuille de riz';

  @override
  String get scanOfflineAnalysis => 'L\'analyse se fait hors ligne';

  @override
  String get scanHeaderTitle => 'Scanner une feuille';

  @override
  String get scanCancel => 'ANNULER';

  @override
  String get scanResultSaveFailed => 'Impossible d\'enregistrer le diagnostic';

  @override
  String get scanResultSaved => 'Diagnostic enregistré';

  @override
  String get scanResultBackSemantics => 'Retour';

  @override
  String get scanResultTitle => 'Résultat de l\'analyse';

  @override
  String get scanResultSubtitle => 'Analyse hors ligne terminée';

  @override
  String get diseaseBacterialLeafBlight => 'Flétrissement bactérien (BLB)';

  @override
  String get diseaseBrownSpot => 'Helminthosporiose (tache brune)';

  @override
  String get diseaseLeafSmut => 'Charbon foliaire';

  @override
  String get diseaseHealthy => 'Plante saine';

  @override
  String get diseaseBacterialLeafStreak => 'Strie bactérienne (BLS)';

  @override
  String get diseaseBlast => 'Pyriculariose';

  @override
  String get diseaseNarrowBrownLeafSpot => 'Cercosporiose';

  @override
  String get diseaseLeafScald => 'Échaudure des feuilles';

  @override
  String get diseaseDownyMildew => 'Mildiou';

  @override
  String get diseaseHispaDamage => 'Dégâts d\'hispa (pou du riz)';

  @override
  String get diseaseNitrogenDeficiency => 'Carence en azote';

  @override
  String get diseasePhosphorusDeficiency => 'Carence en phosphore';

  @override
  String get diseasePotassiumDeficiency => 'Carence en potassium';

  @override
  String get diseaseNotRice => 'Ce n\'est pas du riz';

  @override
  String get scanShareTitle => 'Diagnostic AgriMada';

  @override
  String get scanShareCulture => 'Culture: Riz';

  @override
  String scanShareDisease(String disease) {
    return 'Maladie: $disease';
  }

  @override
  String scanShareCertainty(String value) {
    return 'Certitude : $value';
  }

  @override
  String scanShareDate(String date) {
    return 'Date: $date';
  }

  @override
  String get scanCertaintyProbable => 'Diagnostic probable';

  @override
  String get scanCertaintyPossible => 'Piste à confirmer';

  @override
  String get scanCertaintyUncertain => 'Résultat incertain';

  @override
  String get scanCertaintyExplainProbable =>
      'Les symptômes reconnus sont nets. Vérifiez sur la plante avant d\'agir.';

  @override
  String get scanCertaintyExplainPossible =>
      'Modèle expérimental : il se trompe souvent sur les photos prises au champ. Ce résultat est une piste, pas un diagnostic. Faites-le confirmer par un technicien agricole avant d\'agir.';

  @override
  String get scanUncertainTitle =>
      'L\'application ne reconnaît pas cette photo';

  @override
  String get scanUncertainBody =>
      'Ce n\'est peut-être pas du riz, ou la photo est floue ou mal éclairée. Aucune maladie n\'est retenue et rien n\'est enregistré.';

  @override
  String get scanRetakeTips =>
      'Pour une nouvelle photo : une seule feuille bien nette, à 20-30 cm, en lumière naturelle, sans contre-jour.';

  @override
  String get scanRetakePhoto => 'Reprendre la photo';

  @override
  String scanOtherCandidates(String names) {
    return 'Autres possibilités : $names';
  }

  @override
  String get scanNoResult => 'Aucun résultat à afficher';

  @override
  String get scanSeverityQuestion => 'Quelle part de la parcelle est touchée ?';

  @override
  String get scanSeverityFewPlants => 'Quelques plants';

  @override
  String get scanSeverityUnderThird => 'Moins d\'un tiers';

  @override
  String get scanSeverityOverThird => 'Plus d\'un tiers';

  @override
  String get scanSeverityUnknown => 'Part touchée non renseignée';

  @override
  String get scanAdviceTitle => 'Que faire ?';

  @override
  String get scanAdviceNoChemical =>
      'AgriMada ne recommande aucun produit ni dosage. Avant tout traitement, demandez conseil à un technicien agricole.';

  @override
  String get scanAdviceHealthySeeds => 'Utiliser des semences saines';

  @override
  String get scanAdviceRemoveResidues =>
      'Enlever et détruire les résidus des parcelles atteintes';

  @override
  String get scanAdviceRemoveHostWeeds =>
      'Enlever et détruire les mauvaises herbes qui hébergent la bactérie';

  @override
  String get scanAdviceCleanTools =>
      'Nettoyer les outils au savon après chaque utilisation';

  @override
  String get scanAdviceAlertTechnician =>
      'Prévenir le technicien agricole le plus proche';

  @override
  String get scanDiscard => 'Ce résultat me semble faux';

  @override
  String get scanDiscarded => 'Résultat écarté, rien n\'a été enregistré';

  @override
  String get scanRecommendationsTitle => 'Recommandations adaptées';

  @override
  String get scanRecommendationItemTitle => 'Recommandation';

  @override
  String get scanRecBlbAvoidNitrogen => 'Éviter l\'excès d\'azote';

  @override
  String get scanRecBlbUseResistantVarieties =>
      'Utiliser des variétés résistantes lors du prochain cycle';

  @override
  String get scanRecBrownSpotFertilize =>
      'Améliorer la fertilisation (potassium)';

  @override
  String get scanRecBrownSpotAvoidStress => 'Éviter que le riz manque d\'eau';

  @override
  String get scanRecHealthy =>
      'Plante en bonne santé. Continuez les bonnes pratiques agricoles.';

  @override
  String get scanRecHealthyWater => 'Maintenir une bonne gestion de l\'eau';

  @override
  String get scanRecHealthyFertilization => 'Fertilisation équilibrée';

  @override
  String get scanRecHealthyMonitoring => 'Surveillance régulière des parcelles';

  @override
  String get scanRecHealthyRotation => 'Rotation des cultures';

  @override
  String get scanRescanSemantics => 'Refaire un scan';

  @override
  String get scanRescan => 'Refaire un scan';

  @override
  String get scanSaveJournalSemantics => 'Enregistrer dans le journal';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get scanShareSemantics => 'Partager le résultat';

  @override
  String get scanShare => 'Partager le résultat';

  @override
  String get modelVersionTitle => 'Version du modèle IA';

  @override
  String modelSupportedDiseases(String diseases) {
    return 'Maladies reconnues : $diseases';
  }

  @override
  String journalError(String error) {
    return 'Erreur: $error';
  }

  @override
  String get journalNewPlot => 'Nouvelle parcelle';

  @override
  String get journalTitle => 'Journal agricole';

  @override
  String get journalSubtitle => 'Suivi de vos parcelles';

  @override
  String get journalTotal => 'Total';

  @override
  String get journalHealthyPlural => 'Saines';

  @override
  String get journalSickPlural => 'Malades';

  @override
  String get journalStatusSick => 'Malade';

  @override
  String get journalStatusHealthy => 'Sain';

  @override
  String get journalStatusNotAnalyzed => 'Non analysé';

  @override
  String journalAreaHa(String surface) {
    return '$surface ha';
  }

  @override
  String journalAnalysesCount(int count) {
    return '$count analyse(s)';
  }

  @override
  String journalLastDiagnostic(String disease, String date) {
    return 'Dernier : $disease - $date';
  }

  @override
  String get journalScan => 'Scanner';

  @override
  String get journalNoDiagnosticYet => 'Aucun diagnostic encore';

  @override
  String get journalScanNow => 'Scanner maintenant';

  @override
  String get journalEmptyTitle => 'Aucune parcelle';

  @override
  String get journalEmptyDescription =>
      'Ajoutez votre première parcelle\npour commencer le suivi.';

  @override
  String get journalAddPlot => 'Ajouter une parcelle';

  @override
  String get journalPlotNameLabel => 'Nom de la parcelle *';

  @override
  String get journalDescriptionOptional => 'Description (optionnel)';

  @override
  String get journalSurfaceOptional => 'Surface (ha, optionnel)';

  @override
  String get journalNameRequired => 'Nom requis';

  @override
  String get plotPhotoTake => 'Prendre une photo';

  @override
  String get plotPhotoGallery => 'Choisir dans la galerie';

  @override
  String get plotPhotoLabel => 'Photo de la parcelle';

  @override
  String get plotPhotoAdd => 'Ajouter une photo';

  @override
  String get plotPhotoHint => 'Facultative';

  @override
  String get plotPhotoRemove => 'Retirer la photo';

  @override
  String get plotNameLabel => 'Nom de la parcelle';

  @override
  String get plotNameHint => 'Ex. : rizière du bas-fond';

  @override
  String get plotCropLabel => 'Culture';

  @override
  String get plotCropHint => 'Riz';

  @override
  String get plotSurfaceLabel => 'Surface cultivée';

  @override
  String get plotSurfaceHint => 'En hectares, ex. : 0,55';

  @override
  String get plotSurfaceSuffix => 'ha';

  @override
  String get plotSurfaceInvalid => 'Surface invalide. Exemple : 0,55';

  @override
  String get plotLocationLabel => 'Emplacement';

  @override
  String get plotLocationHint => 'Village, fokontany, repère';

  @override
  String get plotSaveFailed => 'Impossible d\'enregistrer la parcelle';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get registerHello => 'Bonjour!';

  @override
  String get registerWelcome => 'Bienvenue sur AgriMada';

  @override
  String get registerNameLabel => 'Nom complet';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Mot de passe';

  @override
  String get registerConfirmPasswordLabel => 'Confirmer mot de passe';

  @override
  String get registerSubmit => 'S\'inscrire';

  @override
  String get registerAcceptTerms =>
      'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité';

  @override
  String get registerAcceptError =>
      'Veuillez accepter les Conditions d\'utilisation';

  @override
  String get registerHasAccount => 'Déjà un compte?';

  @override
  String get registerLoginLink => 'Se connecter';

  @override
  String get registerSuccess => 'Inscription réussie';

  @override
  String get preventionTitle => 'Prévenir les maladies';

  @override
  String get preventionSubtitle => 'Prévenez vos rizicultures';

  @override
  String get preventionAstuceTitle => 'Astuce de prévention';

  @override
  String get preventionAstuceDesc =>
      'Des gestes simples aujourd\'hui pour un riz sain et une meilleure récolte demain';

  @override
  String get preventionAstuceMoment => 'Astuce du moment';

  @override
  String get preventionWaterManagement =>
      'Maintenez une bonne gestion de l\'eau';

  @override
  String get preventionWaterDesc =>
      'Une bonne gestion de l\'eau limite le développement des maladies comme la pyriculariose, la bactériose et la fusariose.';

  @override
  String get preventionPourquoi => 'Pourquoi c\'est efficace ?';

  @override
  String get preventionPourquoiDesc =>
      'L\'excès d\'eau et l\'humidité favorisent les champignons et bactéries. Une bonne gestion de l\'eau renforce la résistance naturelle du riz.';

  @override
  String get preventionBonASavoir => 'Bon à savoir';

  @override
  String get preventionBonASavoirDesc =>
      'Des plantes vigoureuses, un sol bien oxygéné et une eau bien gérée sont les clés d\'un riz en bonne santé.';

  @override
  String get preventionCommentFaire => 'Comment faire ?';

  @override
  String get guidesTitle => 'Guides des maladies';

  @override
  String get guidesSubtitle => 'Fiches d\'identification hors ligne';

  @override
  String get guidesSymptoms => 'Symptômes';

  @override
  String get guidesCauses => 'Causes';

  @override
  String get guidesTreatments => 'Traitements';

  @override
  String get drawerMenuTitle => 'Menu';

  @override
  String get drawerHomeTitle => 'Accueil';

  @override
  String get drawerHomeSubtitle => 'Revenir à la page d\'accueil';

  @override
  String get drawerPlotsTitle => 'Mes parcelles';

  @override
  String get drawerPlotsSubtitle => 'Suivi de vos rizières et surfaces';

  @override
  String get drawerHistoryTitle => 'Historique';

  @override
  String get drawerHistorySubtitle => 'Liste de vos analyses passées';

  @override
  String get drawerGuidesTitle => 'Guides des maladies';

  @override
  String get drawerGuidesSubtitle => 'Fiches d\'identification hors ligne';

  @override
  String get drawerSettingsTitle => 'Paramètres';

  @override
  String get drawerSettingsSubtitle => 'Langue et préférences';

  @override
  String get drawerStorage => 'Stockage';

  @override
  String get drawerMemoryUsed => 'Mémoire utilisée sur ce smartphone';

  @override
  String get drawerLogout => 'Déconnexion';

  @override
  String drawerLastUpdate(String date) {
    return 'Dernière MAJ : $date';
  }

  @override
  String get drawerEmbeddedModel => 'Modèle IA embarqué';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPhoneUnavailable => 'Téléphone indisponible';

  @override
  String get settingsRegionUnavailable => 'Région indisponible';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get resetPasswordTitle => 'Mot de passe oublié';

  @override
  String get resetPasswordHeadline => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordInstruction =>
      'Entrez votre numéro de téléphone pour recevoir les instructions.';

  @override
  String get resetPasswordPhoneLabel => 'Téléphone';

  @override
  String get resetPasswordPhoneHint => '0341234567';

  @override
  String get resetPasswordPhoneRequired => 'Champ requis';

  @override
  String get resetPasswordPhoneInvalid => 'Numéro invalide';

  @override
  String get resetPasswordBackToLogin => 'Retour à la connexion';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingWelcome => 'Bienvenue';

  @override
  String get onboardingHelpTitle => 'Aide AgriMada';

  @override
  String get onboardingAiAvailable =>
      'Analyse photo disponible sur ce téléphone';

  @override
  String get onboardingAiUnavailable =>
      'Analyse photo indisponible sur ce téléphone';

  @override
  String get commonClose => 'Fermer';

  @override
  String get onboardingSlide1Title => 'Photographiez la feuille malade';

  @override
  String get onboardingSlide1Desc =>
      'Placez la feuille dans le cadre. Gardez 20-30 cm de distance et une bonne lumière naturelle.';

  @override
  String get onboardingSlide2Title => 'L\'IA analyse hors ligne';

  @override
  String get onboardingSlide2Desc =>
      'Pas besoin d\'internet. Le diagnostic fonctionne directement sur votre téléphone.';

  @override
  String get onboardingSlide3Title => 'Consultez le diagnostic';

  @override
  String get onboardingSlide3Desc =>
      'Voyez la maladie probable, le niveau de certitude et les gestes de prévention.';

  @override
  String get onboardingSlide4Title => 'Suivez vos parcelles';

  @override
  String get onboardingSlide4Desc =>
      'Retrouvez l\'historique des analyses de chaque parcelle dans le journal agricole.';

  @override
  String get preventionTip1 =>
      'Assurez un drainage efficace de la parcelle pour éviter la stagnation d\'eau.';

  @override
  String get preventionTip2 =>
      'Alternez les phases d\'inondation et d\'assèchement (en irrigation intermittente).';

  @override
  String get preventionTip3 =>
      'Évitez un niveau d\'eau trop élevé en permanence (3-5 cm suffisent).';

  @override
  String get preventionTip4 =>
      'Évitez l\'excès d\'azote, qui rend les plantes plus sensibles aux maladies.';

  @override
  String get preventionTip5 =>
      'Nettoyez régulièrement les canaux et entrées d\'eau pour une meilleure circulation.';

  @override
  String get splashStatusInitializing => 'Initialisation en cours...';

  @override
  String get splashStatusDegraded => 'Initialisation partielle, mode dégradé.';

  @override
  String get splashStatusAiReady => 'IA prête';

  @override
  String get splashStatusAiUnavailable => 'IA indisponible';

  @override
  String get splashStatusSessionActive => 'Session active';

  @override
  String get splashStatusSessionGuest => 'Session invité';

  @override
  String get exportCsvDate => 'Date';

  @override
  String get exportCsvPlot => 'Parcelle';

  @override
  String get exportCsvDisease => 'Maladie';

  @override
  String get exportCsvSeverity => 'Gravité';

  @override
  String get exportCsvCertainty => 'Certitude';

  @override
  String get exportCsvOrgans => 'Parties observées';

  @override
  String get exportCsvTreatment => 'Traitement appliqué';

  @override
  String get exportPdfGeneratedBy =>
      'Généré par AgriMada - Agriculture intelligente';

  @override
  String get exportPdfTitle => 'Export journal agricole';

  @override
  String get exportPdfAllPlots => 'Toutes les parcelles';

  @override
  String exportPdfPlotLabel(String plot) {
    return 'Parcelle: $plot';
  }

  @override
  String exportPdfDateLabel(String date) {
    return 'Date d\'export: $date';
  }

  @override
  String get guideDisease1Name => 'Brûlure bactérienne';

  @override
  String get guideDisease1Desc =>
      'Maladie bactérienne qui provoque le flétrissement des feuilles. Les premiers symptômes apparaissent sous forme de lésions gris-vert le long des bords des feuilles, qui s\'étendent rapidement et deviennent jaune-blanchâtre.';

  @override
  String get guideDisease1Symptoms =>
      '• Lésions gris-vert le long des nervures\n• Flétrissement en V sur les bords\n• Exsudat bactérien jaune par temps humide\n• Feuilles qui sèchent et blanchissent';

  @override
  String get guideDisease1Causes =>
      '• Forte humidité et températures élevées\n• Excès d\'azote\n• Eau stagnante prolongée\n• Variétés sensibles';

  @override
  String get guideDisease2Name => 'Tache brune';

  @override
  String get guideDisease2Desc =>
      'Maladie fongique courante du riz, surtout dans les sols carencés. Les taches brunes ovales apparaissent sur les feuilles, réduisant la capacité photosynthétique de la plante.';

  @override
  String get guideDisease2Symptoms =>
      '• Taches brunes ovales sur les feuilles\n• Anneaux concentriques sur les lésions\n• Grains tachetés dans les cas sévères\n• Réduction du rendement';

  @override
  String get guideDisease2Causes =>
      '• Carence en potassium\n• Sols pauvres et mal drainés\n• Stress hydrique\n• Forte humidité relative';

  @override
  String get guideDisease3Name => 'Charbon foliaire';

  @override
  String get guideDisease3Desc =>
      'Maladie fongique qui se manifeste par de petites taches noires sur les feuilles de riz. Le champignon se développe dans les tissus foliaires et forme des sores noirs remplis de spores.';

  @override
  String get guideDisease3Symptoms =>
      '• Taches noires angulaires sur les feuilles\n• Lésions sur les gaines foliaires\n• Spores noires poudreuses\n• Affaiblissement général de la plante';

  @override
  String get guideDisease3Causes =>
      '• Humidité élevée prolongée\n• Températures modérées (20-25°C)\n• Densité de semis élevée\n• Mauvais drainage';

  @override
  String get guideDisease4Name => 'Plante saine';

  @override
  String get guideDisease4Desc =>
      'Votre plant de riz ne présente aucun signe de maladie. Continuez à appliquer les bonnes pratiques agricoles pour maintenir la santé de vos cultures.';

  @override
  String get guideDisease4Symptoms =>
      '• Feuilles vertes et vigoureuses\n• Croissance régulière\n• Pas de lésions ni de décoloration\n• Tallage normal';

  @override
  String get guideDisease4Causes => 'Bonnes pratiques agricoles :';

  @override
  String get guidesDisclaimer =>
      'Ces fiches aident à reconnaître une maladie. Avant tout traitement, demandez conseil à un technicien agricole.';

  @override
  String get guidesAdvice => 'Gestes recommandés';

  @override
  String get guidesHealthySigns => 'Signes d\'une plante saine';

  @override
  String get guidesKnowledgeSectionTitle => 'Guide complet';

  @override
  String get guidesKnowledgeSectionSubtitle =>
      'Toutes les classes connues, y compris celles que l\'application ne détecte pas encore';

  @override
  String get guidesDraftBadge => 'Brouillon, non validé par un agronome';

  @override
  String get guidesSearchHint =>
      'Rechercher une maladie (français ou malgache)…';

  @override
  String get guidesNoResults => 'Aucun résultat';

  @override
  String get guidesPreventionTitle => 'Prévention';

  @override
  String get guidesConfusionTitle => 'Peut se confondre avec';

  @override
  String get guidesSourcesTitle => 'Sources';

  @override
  String get guidesConditionsTitle => 'Conditions favorables';

  @override
  String get guidesLoadError => 'Le guide complet n\'a pas pu être ouvert';

  @override
  String get drawerAgentTitle => 'Conseiller';

  @override
  String get drawerAgentSubtitle => 'Poser une question';

  @override
  String get agentTitle => 'Conseiller AgriMada';

  @override
  String get agentSubtitle => 'Réponses tirées des fiches et de vos scans';

  @override
  String get agentHomeCardTitle => 'Une question sur votre riz ?';

  @override
  String get agentHomeCardDescription =>
      'Le conseiller répond à partir des fiches AgriMada et de vos derniers scans (connexion nécessaire).';

  @override
  String get agentConsentTitle => 'Avant de commencer';

  @override
  String get agentConsentAccept => 'J\'accepte';

  @override
  String get agentConsentDecline => 'Non merci';

  @override
  String get agentDisclaimer =>
      'Conseils automatiques tirés de fiches pas encore validées par un agronome. Le conseiller ne pose aucun diagnostic et ne recommande aucun produit : confirmez toujours avec un technicien agricole.';

  @override
  String get agentEmptyTitle => 'Posez votre question';

  @override
  String get agentSuggestionScan => 'Que dit mon dernier scan ?';

  @override
  String get agentSuggestionPrevention => 'Comment prévenir la pyriculariose ?';

  @override
  String get agentSuggestionSymptoms =>
      'Mes feuilles jaunissent depuis la pointe, qu\'est-ce que c\'est ?';

  @override
  String get agentInputHint => 'Votre question…';

  @override
  String get agentSend => 'Envoyer';

  @override
  String get agentThinking => 'Le conseiller consulte les fiches…';

  @override
  String get agentNewConversation => 'Nouvelle conversation';

  @override
  String get agentDeleteHistory => 'Effacer mes échanges';

  @override
  String get agentDeleteHistoryConfirm =>
      'Effacer toutes vos questions et réponses conservées sur le serveur ?';

  @override
  String get agentConfirmDelete => 'Effacer';

  @override
  String get agentWithdrawConsent => 'Retirer mon accord';

  @override
  String get agentOffline =>
      'Pas de connexion : le conseiller a besoin d\'internet. Le guide des fiches reste disponible hors ligne.';

  @override
  String get agentFichesTitle => 'Fiches citées';

  @override
  String get agentAskTechnician => 'Demander à un technicien';

  @override
  String get agentTechnicianShareIntro =>
      'Question posée au conseiller AgriMada, à vérifier :';

  @override
  String get agentUrgentTitle => 'Urgence';

  @override
  String get agentWarningAutomatic =>
      'Réponse automatique : confirmez avec un technicien agricole avant d\'agir.';

  @override
  String get agentWarningDraft =>
      'Tirée de fiches en brouillon, pas encore validées par un agronome.';

  @override
  String get agentWarningExperimental =>
      'Les pistes de scan viennent d\'un modèle expérimental.';

  @override
  String get agentWarningMalagasy =>
      'Malgache produit automatiquement, pas encore relu par un locuteur natif.';

  @override
  String get agentReasonScanToConfirm => 'Piste de scan à confirmer';

  @override
  String get agentReasonReport =>
      'Maladie qui se propage ou sans remède : à signaler vite';

  @override
  String get agentReasonSevere => 'Plus d\'un tiers de la parcelle touché';

  @override
  String get agentReasonUnnamedScan => 'Scan sans maladie nommée';

  @override
  String get agentReasonOutOfScope => 'Question hors des fiches';

  @override
  String get agentReasonTreatment =>
      'Seul un technicien peut conseiller un traitement';

  @override
  String get agentErrorOffline =>
      'Impossible de joindre le serveur. Vérifiez votre connexion.';

  @override
  String get agentErrorQuota =>
      'Vous avez posé toutes vos questions pour aujourd\'hui. Revenez demain.';

  @override
  String get agentErrorUnavailable =>
      'Le conseiller est momentanément indisponible. Réessayez plus tard.';

  @override
  String get agentErrorSession => 'Votre session a expiré : reconnectez-vous.';

  @override
  String get agentErrorConsent =>
      'Votre accord est nécessaire pour utiliser le conseiller.';

  @override
  String get agentErrorHistoryReset =>
      'La conversation a été recommencée : renvoyez votre question.';

  @override
  String get agentErrorGeneric => 'Une erreur est survenue. Réessayez.';

  @override
  String agentConsentBody(int days) {
    return 'Vos questions et les réponses sont conservées $days jours pour améliorer le service, puis effacées. Elles sont traitées par Google (Gemini). N\'écrivez ni nom, ni numéro de téléphone, ni adresse. Vous pouvez effacer vos échanges à tout moment.';
  }

  @override
  String agentQuotaRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions restantes aujourd\'hui',
      one: '1 question restante aujourd\'hui',
      zero: 'Plus de question disponible aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String agentDeleteHistoryDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count échanges effacés',
      one: '1 échange effacé',
      zero: 'Aucun échange à effacer',
    );
    return '$_temp0';
  }

  @override
  String agentShareQuestion(String question) {
    return 'Question : $question';
  }

  @override
  String agentShareAnswer(String answer) {
    return 'Réponse du conseiller : $answer';
  }

  @override
  String get journalHistorySubtitle => 'Historique des analyses';

  @override
  String get journalHistoryEmptyTitle => 'Aucune analyse';

  @override
  String get journalHistoryEmptyDescription =>
      'Vos diagnostics récents apparaîtront ici';

  @override
  String get journalStartDiagnosis => 'Faire un diagnostic';

  @override
  String get exportNothing => 'Aucun diagnostic à exporter';

  @override
  String get exportAction => 'Exporter';

  @override
  String get exportAsCsv => 'Exporter en CSV';

  @override
  String get exportAsPdf => 'Exporter en PDF';

  @override
  String get exportShareText => 'Journal agricole AgriMada';

  @override
  String get exportDone => 'Export prêt à être partagé';

  @override
  String get parcelDetailTitle => 'Détail de la parcelle';

  @override
  String get parcelDetailNewAnalysis => 'Faire une nouvelle analyse';

  @override
  String get parcelDetailNotFound => 'Parcelle introuvable';

  @override
  String get parcelDetailNoAnalysis => 'Aucune analyse pour cette parcelle';

  @override
  String get parcelDetailNotAnalyzedYet =>
      'Cette parcelle n\'a pas encore été analysée';

  @override
  String get parcelDetailHealthStatus => 'État de santé';

  @override
  String get registerLastNameLabel => 'Nom';

  @override
  String get registerFirstNameLabel => 'Prénom';

  @override
  String get registerRegionLabel => 'Région';

  @override
  String get registerFieldRequired => 'Champ requis';

  @override
  String get registerPhoneInvalid => 'Numéro invalide';

  @override
  String get registerPasswordTooShort => 'Minimum 8 caractères';

  @override
  String get registerPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get splashLogoSemantics => 'Logo AgriMada';

  @override
  String get syncInProgress => 'Synchronisation…';

  @override
  String get scanAskTechnician => 'Demander à un technicien';

  @override
  String get scanAskTechnicianMessage =>
      'Bonjour, l\'application AgriMada n\'a pas pu identifier avec certitude le problème sur mon riz. Pouvez-vous regarder la photo ?';

  @override
  String scanAskTechnicianCandidates(String candidates) {
    return 'Pistes de l\'application, non confirmées : $candidates';
  }

  @override
  String get journalFilterAll => 'Tous';

  @override
  String get journalFilterLastSevenDays => '7 derniers jours';

  @override
  String get journalFilterSevere => 'Plus d\'un tiers touché';

  @override
  String get journalFilterHealthy => 'Sains';

  @override
  String get journalFilterEmpty => 'Aucune analyse ne correspond à ce filtre';

  @override
  String get errorInvalidCredentials =>
      'Numéro de téléphone ou mot de passe incorrect';

  @override
  String get errorTooManyAttempts =>
      'Trop de tentatives. Réessayez dans quelques minutes.';

  @override
  String get errorPhoneAlreadyUsed => 'Ce numéro de téléphone a déjà un compte';

  @override
  String get errorInvalidData => 'Informations invalides. Vérifiez les champs.';

  @override
  String get errorOffline => 'Pas de connexion internet';

  @override
  String get errorTimeout =>
      'Le serveur met trop de temps à répondre. Réessayez.';

  @override
  String get errorSessionExpired =>
      'Reconnectez-vous pour synchroniser vos données';

  @override
  String get errorServer =>
      'Le serveur a rencontré un problème. Réessayez plus tard.';

  @override
  String get errorUnknown => 'Une erreur est survenue. Réessayez.';

  @override
  String get syncErrorServerUnreachable =>
      'Serveur injoignable. Vérifiez la connexion ou l\'adresse du serveur.';

  @override
  String get syncErrorFailed =>
      'La synchronisation a échoué. Nouvel essai au retour du réseau.';

  @override
  String get resetPasswordRequestSent =>
      'Si ce numéro est associé à un compte, des instructions seront envoyées.';

  @override
  String get journalStatusToConfirm => 'À confirmer';

  @override
  String get scanOrganTitle => 'Qu\'observez-vous ?';

  @override
  String get scanOrganHelp =>
      'Choisissez la partie de la plante que vous voulez photographier.';

  @override
  String get scanOrganModelNotice =>
      'Seules les feuilles sont analysées par le modèle. Pour les autres parties, vos réponses sont enregistrées et transmises à un technicien.';

  @override
  String get organLeaf => 'Feuilles';

  @override
  String get organStemSheath => 'Tige et gaine';

  @override
  String get organCollar => 'Collet et base des tiges';

  @override
  String get organRoots => 'Racines';

  @override
  String get organPanicle => 'Panicule et grains';

  @override
  String get organWholePlant => 'Plante entière ou parcelle';

  @override
  String get organUnknown => 'Je ne sais pas';

  @override
  String get organUnknownHint =>
      'L\'application vous guide : la parcelle, puis une feuille, puis le collet.';

  @override
  String get photoQualityBlurred =>
      'Photo floue. Tenez le téléphone à deux mains, touchez l\'écran sur la plante pour faire le point, puis reprenez.';

  @override
  String get photoQualityTooDark =>
      'Photo trop sombre. Cherchez un endroit plus éclairé ou attendez que le soleil monte.';

  @override
  String get photoQualityTooBright =>
      'Photo trop claire. Évitez le plein soleil sur la feuille, cherchez une ombre légère.';

  @override
  String get photoQualityBacklit =>
      'Le soleil est derrière la plante. Tournez-vous pour l\'avoir dans le dos.';

  @override
  String get photoQualityGood => 'Photo nette.';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonDontKnow => 'Je ne sais pas';

  @override
  String get questionSinceWhen =>
      'Depuis combien de temps voyez-vous ce problème ?';

  @override
  String get questionSinceWhenDays => 'Moins d\'une semaine';

  @override
  String get questionSinceWhenWeeks => 'Une à trois semaines';

  @override
  String get questionSinceWhenMonth => 'Plus d\'un mois';

  @override
  String get questionLeafShape =>
      'À quoi ressemblent les taches sur les feuilles ?';

  @override
  String get questionLeafShapeBrownOval =>
      'Taches brunes ovales, éparpillées sur la feuille';

  @override
  String get questionLeafShapeYellowEdge =>
      'Bandes gris-vert puis jaunes, à partir du bord ou de la pointe';

  @override
  String get questionLeafShapeBlackAngular =>
      'Petites taches noires anguleuses, un peu poudreuses';

  @override
  String get questionLeafShapeNone => 'Aucune tache visible';

  @override
  String get questionLeafExudate =>
      'Le matin, voyez-vous des gouttes jaunes collantes sur les feuilles touchées ?';

  @override
  String get questionLeafSpread =>
      'Comment le problème se répand-il dans la parcelle ?';

  @override
  String get questionLeafSpreadFast =>
      'Vite, sur beaucoup de pieds en quelques jours';

  @override
  String get questionLeafSpreadSlow => 'Lentement, quelques pieds seulement';

  @override
  String get questionStem => 'Que voyez-vous sur la tige ou la gaine ?';

  @override
  String get questionStemBrownPatches => 'Taches brunes allongées sur la gaine';

  @override
  String get questionStemSoft => 'Tige molle qui se casse au ras de l\'eau';

  @override
  String get questionStemHoles => 'Trous ou galeries dans la tige';

  @override
  String get questionCollar => 'Que voyez-vous à la base des tiges ?';

  @override
  String get questionCollarChewed => 'Base rongée, plants qui se déchaussent';

  @override
  String get questionCollarRot => 'Pourriture noire au ras du sol';

  @override
  String get questionCollarRing => 'Anneau brun autour du nœud';

  @override
  String get questionRoots => 'À quoi ressemblent les racines ?';

  @override
  String get questionRootsRusty => 'Racines brun-orangé, comme rouillées';

  @override
  String get questionRootsBlack => 'Racines noires et molles';

  @override
  String get questionRootsGalls => 'Petites boules sur les racines';

  @override
  String get questionPanicle => 'Que voyez-vous sur la panicule ?';

  @override
  String get questionPanicleWhite => 'Panicule blanche et vide';

  @override
  String get questionPanicleStained => 'Grains tachés ou noircis';

  @override
  String get questionPanicleNeck => 'Cou de la panicule brun et cassant';

  @override
  String get questionWholePlant => 'Comment se présente la parcelle ?';

  @override
  String get questionWholePlantYellowPatches =>
      'Plants jaunis et rabougris, par taches dans la parcelle';

  @override
  String get questionWholePlantDriedSpots => 'Foyers de plants desséchés';

  @override
  String get questionWholePlantEvenYellow =>
      'Jaunissement régulier sur toute la parcelle';

  @override
  String get scanOrganNoPlotNotice =>
      'Vous pouvez scanner sans parcelle : vous la rattacherez après.';

  @override
  String get captureHintLeaf =>
      'Approchez-vous d\'une feuille atteinte, bien à plat, la lumière dans votre dos.';

  @override
  String get captureHintStem =>
      'Tenez le téléphone à la verticale et cadrez la tige du bas vers le haut.';

  @override
  String get captureHintCollar =>
      'Écartez les feuilles pour montrer la base des tiges, au ras du sol.';

  @override
  String get captureHintRoots =>
      'Déterrez un plant, rincez la terre et posez les racines sur un fond clair.';

  @override
  String get captureHintPanicle =>
      'Cadrez une panicule entière, du cou jusqu\'aux grains.';

  @override
  String get captureHintWholePlant =>
      'Reculez pour montrer la parcelle et les endroits atteints.';

  @override
  String get scanCaptureTake => 'Prendre la photo';

  @override
  String get scanCaptureAnother => 'Ajouter une autre photo';

  @override
  String get scanCaptureContinue => 'Continuer';

  @override
  String scanCapturePhotos(int count, int max) {
    return '$count photo(s) sur $max';
  }

  @override
  String get scanCameraUnavailable =>
      'Aperçu indisponible sur cet appareil : l\'appareil photo du téléphone s\'ouvrira.';

  @override
  String get scanQuestionsTitle => 'Quelques questions';

  @override
  String get scanQuestionsHelp =>
      'Vos réponses partent avec les photos. Elles aident le technicien, même quand l\'application ne reconnaît rien.';

  @override
  String get scanSessionResultTitle => 'Résultat du scan';

  @override
  String get scanSessionNoName => 'L\'application ne nomme aucune maladie';

  @override
  String get scanSessionNoNameBody =>
      'Cette partie de la plante n\'est pas analysée par le modèle. Vos photos et vos réponses sont enregistrées : montrez-les à un technicien.';

  @override
  String get scanSessionNotRecognizedBody =>
      'Ce n\'est peut-être pas du riz, ou la photo est floue ou mal éclairée. Aucune maladie n\'est retenue. Vos photos et vos réponses sont enregistrées : montrez-les à un technicien.';

  @override
  String scanSessionPhotosSaved(int count) {
    return '$count photo(s) enregistrée(s)';
  }

  @override
  String get scanSessionAttachPlot => 'Rattacher à une parcelle';

  @override
  String get scanSessionAttachPlotHint =>
      'Ce scan n\'est rattaché à aucune parcelle.';

  @override
  String get scanSessionAttached => 'Scan rattaché à la parcelle';

  @override
  String get scanSessionFinish => 'Terminer';

  @override
  String get journalUnnamedResult => 'Résultat non nommé';

  @override
  String get plotContextTitle => 'Contexte de la parcelle';

  @override
  String get plotContextOptional =>
      'Facultatif, mais très utile au technicien.';

  @override
  String get plotEcosystemLabel => 'Écosystème';

  @override
  String get ecosystemIrrigated => 'Irrigué';

  @override
  String get ecosystemLowland => 'Bas-fond';

  @override
  String get ecosystemUpland => 'Tanety (pluvial)';

  @override
  String get plotRegionLabel => 'Région';

  @override
  String get plotAltitudeLabel => 'Altitude';

  @override
  String get altitudeUnder800 => 'Moins de 800 m';

  @override
  String get altitude800to1200 => '800 à 1200 m';

  @override
  String get altitude1200to1500 => '1200 à 1500 m';

  @override
  String get altitudeOver1500 => 'Plus de 1500 m';

  @override
  String get plotVarietyLabel => 'Variété';

  @override
  String get varietyLocalUnknown => 'Locale ou inconnue';

  @override
  String get plotSeasonLabel => 'Saison';

  @override
  String get seasonVaryAloha => 'Vary aloha (riz précoce)';

  @override
  String get seasonMain => 'Saison des pluies';

  @override
  String get seasonOffSeason => 'Contre-saison';

  @override
  String get plotTransplantDateLabel => 'Date de repiquage';

  @override
  String get plotTransplantDateHint => 'Sert à situer le stade de la culture';

  @override
  String get plotTransplantDateChoose => 'Choisir la date';

  @override
  String get plotSurfaceUnitHectare => 'hectares';

  @override
  String get plotSurfaceUnitAre => 'ares';

  @override
  String get stageRecovery => 'Reprise après repiquage';

  @override
  String get stageTillering => 'Tallage';

  @override
  String get stageStemElongation => 'Montaison';

  @override
  String get stageHeading => 'Épiaison et floraison';

  @override
  String get stageMaturity => 'Maturation';

  @override
  String get exportNoPlot => 'Sans parcelle';

  @override
  String journalPhotoCount(int count) {
    return '$count photo(s)';
  }
}
