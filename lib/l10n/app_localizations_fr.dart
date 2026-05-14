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
  String get loginWelcome => 'Bienvenue sur AgriMada';

  @override
  String get welcomeHeadline => 'L\'intelligence au service de vos rizières';

  @override
  String get welcomeBody =>
      'Un riz sain et protégé grâce à l\'expertise AgriMada.';

  @override
  String get welcomeStart => 'Commencer';

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
  String get homeSearchPlaceholder => 'recherche...';

  @override
  String get homeSummaryTitle => 'Résumé de votre exploitation';

  @override
  String get homeSystemReady => 'Système prêt';

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
  String get homeServiceSolutionsTitle => 'Solutions agricoles';

  @override
  String get homeServiceSolutionsDescription =>
      'Découvrez les traitements biologiques et solutions locales recommandées';

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
  String get diseaseBacterialLeafBlight => 'Brûlure bactérienne';

  @override
  String get diseaseBrownSpot => 'Tache brune';

  @override
  String get diseaseLeafSmut => 'Charbon foliaire';

  @override
  String get diseaseHealthy => 'Plante saine';

  @override
  String scanResultConfidence(String value) {
    return '$value% de confiance';
  }

  @override
  String get scanShareTitle => 'Diagnostic AgriMada';

  @override
  String get scanShareCulture => 'Culture: Riz';

  @override
  String scanShareDisease(String disease) {
    return 'Maladie: $disease';
  }

  @override
  String scanShareConfidence(String value) {
    return 'Confiance: $value%';
  }

  @override
  String scanShareDate(String date) {
    return 'Date: $date';
  }

  @override
  String get scanSeverityTitle => 'Niveau de gravité';

  @override
  String get scanSeverityLow => 'Faible';

  @override
  String get scanSeverityMedium => 'Moyen';

  @override
  String get scanSeverityHigh => 'Élevé';

  @override
  String get scanSeverityNoneStatus => 'Aucune - Plante saine';

  @override
  String get scanSeverityLowStatus => 'Faible - Surveiller';

  @override
  String get scanSeverityMediumStatus => 'Modéré - Intervention conseillée';

  @override
  String get scanSeverityHighStatus => 'Élevé - Intervention urgente';

  @override
  String get scanRecommendationsTitle => 'Recommandations adaptées';

  @override
  String get scanRecommendationItemTitle => 'Recommandation';

  @override
  String get scanRecBlbEvacuateWater => 'Évacuer l\'eau des rizières infectées';

  @override
  String get scanRecBlbApplyCopper => 'Appliquer du cuivre hydroxyde (2-3 g/L)';

  @override
  String get scanRecBlbAvoidNitrogen => 'Éviter l\'excès d\'azote';

  @override
  String get scanRecBlbUseResistantVarieties =>
      'Utiliser des variétés résistantes lors du prochain cycle';

  @override
  String get scanRecBrownSpotFertilize =>
      'Améliorer la fertilisation (potassium)';

  @override
  String get scanRecBrownSpotApplyFungicide =>
      'Appliquer un fongicide à base de mancozèbe';

  @override
  String get scanRecBrownSpotDrainage => 'Assurer un drainage correct';

  @override
  String get scanRecBrownSpotAvoidStress => 'Éviter le stress hydrique';

  @override
  String get scanRecLeafSmutTreatSeeds =>
      'Traiter les semences avant plantation';

  @override
  String get scanRecLeafSmutApplyFungicide =>
      'Appliquer des fongicides systémiques';

  @override
  String get scanRecLeafSmutRemovePlants =>
      'Retirer et brûler les plants infectés';

  @override
  String get scanRecLeafSmutRotation => 'Rotation des cultures recommandée';

  @override
  String get scanRecHealthy =>
      'Plante en bonne santé. Continuez les bonnes pratiques agricoles.';

  @override
  String get scanTip => 'Astuce : évitez l\'arrosage excessif pendant 3 jours';

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
  String get registerTitle => 'Créer un compte';

  @override
  String get registerHeadline => 'Inscription agriculteur';

  @override
  String get registerDescription =>
      'Renseignez vos informations pour créer votre accès.';

  @override
  String get registerNameLabel => 'Nom';

  @override
  String get registerFirstNameLabel => 'Prénom';

  @override
  String get registerRegionLabel => 'Région';

  @override
  String get registerPhoneLabel => 'Téléphone';

  @override
  String get registerPasswordLabel => 'Mot de passe';

  @override
  String get registerSubmit => 'Créer mon compte';

  @override
  String get registerAlreadyAccount => 'J’ai déjà un compte';

  @override
  String get registerSuccess => 'Inscription réussie';

  @override
  String get validationRequired => 'Champ requis';

  @override
  String get validationPhoneInvalid => 'Numéro invalide';

  @override
  String get validationPasswordMin => 'Minimum 6 caractères';

  @override
  String get resetTitle => 'Mot de passe oublié';

  @override
  String get resetHeadline => 'Réinitialiser le mot de passe';

  @override
  String get resetDescription =>
      'Entrez votre numéro de téléphone pour recevoir les instructions.';

  @override
  String get resetBackToLogin => 'Retour à la connexion';

  @override
  String get resetSuccessMessage =>
      'Si ce numéro est associé à un compte, des instructions seront envoyées.';

  @override
  String get splashInitializing => 'Initialisation en cours...';

  @override
  String get splashPartialInit => 'Initialisation partielle, mode dégradé.';

  @override
  String get splashAiReady => 'IA prête';

  @override
  String get splashAiUnavailable => 'IA indisponible';

  @override
  String get splashSessionActive => 'Session active';

  @override
  String get splashSessionGuest => 'Session invité';

  @override
  String splashStatus(String mode, String session) {
    return '$mode • $session';
  }

  @override
  String welcomeGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get welcomeAiReady => 'IA hors-ligne prête';

  @override
  String get welcomeAiUnavailable => 'Mode dégradé sans IA';

  @override
  String welcomeAiModelStatus(String status, String version) {
    return '$status • Modèle v$version';
  }

  @override
  String get onboardingSlide1Title => 'Photographiez la feuille malade';

  @override
  String get onboardingSlide1Description =>
      'Placez la feuille dans le cadre. Gardez 20-30 cm de distance et une bonne lumière naturelle.';

  @override
  String get onboardingSlide2Title => 'L\'IA analyse hors ligne';

  @override
  String get onboardingSlide2Description =>
      'Pas besoin d\'internet. Le diagnostic fonctionne directement sur votre téléphone.';

  @override
  String get onboardingSlide3Title => 'Consultez le diagnostic';

  @override
  String get onboardingSlide3Description =>
      'Visualisez la gravité détectée, la confiance de l\'analyse et les recommandations adaptées.';

  @override
  String get onboardingSlide4Title => 'Suivez vos parcelles';

  @override
  String get onboardingSlide4Description =>
      'Retrouvez l\'historique des analyses de chaque parcelle dans le journal agricole.';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingClose => 'Fermer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingHelpTitle => 'Aide AgriMada';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue';

  @override
  String get onboardingModelVersionTitle => 'Version du modèle IA';

  @override
  String onboardingSupportedDiseases(String diseases) {
    return 'Maladies supportées: $diseases';
  }

  @override
  String get onboardingAppStatusTitle => 'Statut de l\'application';

  @override
  String get onboardingAiAvailable => 'IA disponible sur cet appareil';

  @override
  String get onboardingAiUnavailable => 'IA indisponible, mode dégradé';

  @override
  String onboardingActiveVersion(String version) {
    return 'Version active: v$version';
  }
}
