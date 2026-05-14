import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_mg.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('mg')
  ];

  /// Sous-titre écran splash
  ///
  /// In fr, this message translates to:
  /// **'Diagnostiquer les maladies du riz, hors ligne'**
  String get splashSubtitle;

  /// Titre de la fenêtre mot de passe oublié
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPasswordTitle;

  /// Libellé du champ email
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// Placeholder email
  ///
  /// In fr, this message translates to:
  /// **'nom@exemple.com'**
  String get loginEmailHint;

  /// Validation email requis
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre email'**
  String get loginEmailRequired;

  /// Validation email invalide
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get loginEmailInvalid;

  /// Action annuler
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// Action envoyer
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get commonSend;

  /// Message fonctionnalité bientôt disponible
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité bientôt disponible'**
  String get featureComingSoon;

  /// Message inscription bientôt disponible
  ///
  /// In fr, this message translates to:
  /// **'Inscription bientôt disponible'**
  String get registerComingSoon;

  /// Titre écran login
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// Libellé mot de passe
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPasswordLabel;

  /// Validation mot de passe requis
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre mot de passe'**
  String get loginPasswordRequired;

  /// Lien mot de passe oublié
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get loginForgotPassword;

  /// Bouton connexion
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginSubmit;

  /// Texte pas de compte
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get loginNoAccount;

  /// Lien inscription
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get loginRegister;

  /// Texte salutation login
  ///
  /// In fr, this message translates to:
  /// **'Bonjour !'**
  String get loginHello;

  /// Sous-titre login
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur AgriMada'**
  String get loginWelcome;

  /// Titre ecran bienvenue
  ///
  /// In fr, this message translates to:
  /// **'L\'intelligence au service de vos rizières'**
  String get welcomeHeadline;

  /// Description ecran bienvenue
  ///
  /// In fr, this message translates to:
  /// **'Un riz sain et protégé grâce à l\'expertise AgriMada.'**
  String get welcomeBody;

  /// Bouton commencer
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get welcomeStart;

  /// Snack bar bientôt disponible
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get homeSoonMessage;

  /// Titre section services
  ///
  /// In fr, this message translates to:
  /// **'Nos Services'**
  String get homeServicesTitle;

  /// Semantique bouton menu
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le menu'**
  String get homeMenuSemantics;

  /// Salutation utilisateur
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {name}!'**
  String homeHelloUser(String name);

  /// Prénom par défaut si absent
  ///
  /// In fr, this message translates to:
  /// **'Agriculteur'**
  String get homeFarmerDefault;

  /// Sous-texte accueil
  ///
  /// In fr, this message translates to:
  /// **'Prêt pour une analyse ?'**
  String get homeReadyForAnalysis;

  /// Indicateur mode hors ligne
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne'**
  String get homeOfflineMode;

  /// Placeholder recherche
  ///
  /// In fr, this message translates to:
  /// **'recherche...'**
  String get homeSearchPlaceholder;

  /// Titre carte résumé
  ///
  /// In fr, this message translates to:
  /// **'Résumé de votre exploitation'**
  String get homeSummaryTitle;

  /// Statut système prêt
  ///
  /// In fr, this message translates to:
  /// **'Système prêt'**
  String get homeSystemReady;

  /// Nombre de parcelles
  ///
  /// In fr, this message translates to:
  /// **'{count} parcelle(s) enregistrée(s)'**
  String homeRegisteredPlots(int count);

  /// Service mes parcelles
  ///
  /// In fr, this message translates to:
  /// **'Mes parcelles'**
  String get homeServicePlotsTitle;

  /// Description service mes parcelles
  ///
  /// In fr, this message translates to:
  /// **'Suivez vos rizières, surfaces cultivées et l\'état sanitaire de chaque parcelle'**
  String get homeServicePlotsDescription;

  /// Service état des cultures
  ///
  /// In fr, this message translates to:
  /// **'État des cultures'**
  String get homeServiceCropsTitle;

  /// Description service état cultures
  ///
  /// In fr, this message translates to:
  /// **'Consultez l\'état global de vos cultures et les niveaux de risque actuels'**
  String get homeServiceCropsDescription;

  /// Service solutions agricoles
  ///
  /// In fr, this message translates to:
  /// **'Solutions agricoles'**
  String get homeServiceSolutionsTitle;

  /// Description service solutions
  ///
  /// In fr, this message translates to:
  /// **'Découvrez les traitements biologiques et solutions locales recommandées'**
  String get homeServiceSolutionsDescription;

  /// Service prevention
  ///
  /// In fr, this message translates to:
  /// **'Prévenir les maladies'**
  String get homeServicePreventionTitle;

  /// Description service prevention
  ///
  /// In fr, this message translates to:
  /// **'Apprenez les bonnes pratiques pour protéger vos rizières et éviter les pertes'**
  String get homeServicePreventionDescription;

  /// Semantique bouton scan
  ///
  /// In fr, this message translates to:
  /// **'Scanner une plante'**
  String get homeScanPlantSemantics;

  /// Label onglet accueil
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get homeTabHome;

  /// Label onglet journal
  ///
  /// In fr, this message translates to:
  /// **'Journal'**
  String get homeTabJournal;

  /// Message indisponibilite IA
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic IA indisponible, veuillez réessayer'**
  String get scanIaUnavailable;

  /// Titre selection parcelle
  ///
  /// In fr, this message translates to:
  /// **'Choisir une parcelle'**
  String get scanSelectPlot;

  /// Titre dialogue aucune parcelle
  ///
  /// In fr, this message translates to:
  /// **'Aucune parcelle'**
  String get scanNoPlotTitle;

  /// Description dialogue aucune parcelle
  ///
  /// In fr, this message translates to:
  /// **'Créez d\'abord une parcelle dans votre journal agricole avant de scanner.'**
  String get scanNoPlotDescription;

  /// Action OK
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Action aller au journal
  ///
  /// In fr, this message translates to:
  /// **'Aller au journal'**
  String get scanGoToJournal;

  /// Texte chargement scan
  ///
  /// In fr, this message translates to:
  /// **'Analyse en cours...'**
  String get scanLoading;

  /// Instruction caméra
  ///
  /// In fr, this message translates to:
  /// **'Pointez la caméra vers\nla feuille de riz'**
  String get scanPointCamera;

  /// Info analyse hors ligne
  ///
  /// In fr, this message translates to:
  /// **'L\'analyse se fait hors ligne'**
  String get scanOfflineAnalysis;

  /// Titre ecran scan
  ///
  /// In fr, this message translates to:
  /// **'Scanner une feuille'**
  String get scanHeaderTitle;

  /// Bouton annuler scan
  ///
  /// In fr, this message translates to:
  /// **'ANNULER'**
  String get scanCancel;

  /// Message echec sauvegarde diagnostic
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'enregistrer le diagnostic'**
  String get scanResultSaveFailed;

  /// Message sauvegarde diagnostic réussie
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic enregistré'**
  String get scanResultSaved;

  /// Semantique bouton retour
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get scanResultBackSemantics;

  /// Titre écran résultat
  ///
  /// In fr, this message translates to:
  /// **'Résultat de l\'analyse'**
  String get scanResultTitle;

  /// Sous-titre écran résultat
  ///
  /// In fr, this message translates to:
  /// **'Analyse hors ligne terminée'**
  String get scanResultSubtitle;

  /// Nom localisé maladie BLB
  ///
  /// In fr, this message translates to:
  /// **'Brûlure bactérienne'**
  String get diseaseBacterialLeafBlight;

  /// Nom localisé maladie brown spot
  ///
  /// In fr, this message translates to:
  /// **'Tache brune'**
  String get diseaseBrownSpot;

  /// Nom localisé maladie leaf smut
  ///
  /// In fr, this message translates to:
  /// **'Charbon foliaire'**
  String get diseaseLeafSmut;

  /// Nom localisé état sain
  ///
  /// In fr, this message translates to:
  /// **'Plante saine'**
  String get diseaseHealthy;

  /// Badge de confiance
  ///
  /// In fr, this message translates to:
  /// **'{value}% de confiance'**
  String scanResultConfidence(String value);

  /// Titre partage diagnostic
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic AgriMada'**
  String get scanShareTitle;

  /// Ligne culture partage
  ///
  /// In fr, this message translates to:
  /// **'Culture: Riz'**
  String get scanShareCulture;

  /// Ligne maladie partage
  ///
  /// In fr, this message translates to:
  /// **'Maladie: {disease}'**
  String scanShareDisease(String disease);

  /// Ligne confiance partage
  ///
  /// In fr, this message translates to:
  /// **'Confiance: {value}%'**
  String scanShareConfidence(String value);

  /// Ligne date partage
  ///
  /// In fr, this message translates to:
  /// **'Date: {date}'**
  String scanShareDate(String date);

  /// Titre carte gravité
  ///
  /// In fr, this message translates to:
  /// **'Niveau de gravité'**
  String get scanSeverityTitle;

  /// Niveau faible
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get scanSeverityLow;

  /// Niveau moyen
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get scanSeverityMedium;

  /// Niveau élevé
  ///
  /// In fr, this message translates to:
  /// **'Élevé'**
  String get scanSeverityHigh;

  /// Texte statut gravité aucune
  ///
  /// In fr, this message translates to:
  /// **'Aucune - Plante saine'**
  String get scanSeverityNoneStatus;

  /// Texte statut gravité faible
  ///
  /// In fr, this message translates to:
  /// **'Faible - Surveiller'**
  String get scanSeverityLowStatus;

  /// Texte statut gravité modérée
  ///
  /// In fr, this message translates to:
  /// **'Modéré - Intervention conseillée'**
  String get scanSeverityMediumStatus;

  /// Texte statut gravité élevée
  ///
  /// In fr, this message translates to:
  /// **'Élevé - Intervention urgente'**
  String get scanSeverityHighStatus;

  /// Titre recommandations
  ///
  /// In fr, this message translates to:
  /// **'Recommandations adaptées'**
  String get scanRecommendationsTitle;

  /// Titre item recommandation
  ///
  /// In fr, this message translates to:
  /// **'Recommandation'**
  String get scanRecommendationItemTitle;

  /// Recommandation BLB 1
  ///
  /// In fr, this message translates to:
  /// **'Évacuer l\'eau des rizières infectées'**
  String get scanRecBlbEvacuateWater;

  /// Recommandation BLB 2
  ///
  /// In fr, this message translates to:
  /// **'Appliquer du cuivre hydroxyde (2-3 g/L)'**
  String get scanRecBlbApplyCopper;

  /// Recommandation BLB 3
  ///
  /// In fr, this message translates to:
  /// **'Éviter l\'excès d\'azote'**
  String get scanRecBlbAvoidNitrogen;

  /// Recommandation BLB 4
  ///
  /// In fr, this message translates to:
  /// **'Utiliser des variétés résistantes lors du prochain cycle'**
  String get scanRecBlbUseResistantVarieties;

  /// Recommandation Brown Spot 1
  ///
  /// In fr, this message translates to:
  /// **'Améliorer la fertilisation (potassium)'**
  String get scanRecBrownSpotFertilize;

  /// Recommandation Brown Spot 2
  ///
  /// In fr, this message translates to:
  /// **'Appliquer un fongicide à base de mancozèbe'**
  String get scanRecBrownSpotApplyFungicide;

  /// Recommandation Brown Spot 3
  ///
  /// In fr, this message translates to:
  /// **'Assurer un drainage correct'**
  String get scanRecBrownSpotDrainage;

  /// Recommandation Brown Spot 4
  ///
  /// In fr, this message translates to:
  /// **'Éviter le stress hydrique'**
  String get scanRecBrownSpotAvoidStress;

  /// Recommandation Leaf Smut 1
  ///
  /// In fr, this message translates to:
  /// **'Traiter les semences avant plantation'**
  String get scanRecLeafSmutTreatSeeds;

  /// Recommandation Leaf Smut 2
  ///
  /// In fr, this message translates to:
  /// **'Appliquer des fongicides systémiques'**
  String get scanRecLeafSmutApplyFungicide;

  /// Recommandation Leaf Smut 3
  ///
  /// In fr, this message translates to:
  /// **'Retirer et brûler les plants infectés'**
  String get scanRecLeafSmutRemovePlants;

  /// Recommandation Leaf Smut 4
  ///
  /// In fr, this message translates to:
  /// **'Rotation des cultures recommandée'**
  String get scanRecLeafSmutRotation;

  /// Recommandation plante saine
  ///
  /// In fr, this message translates to:
  /// **'Plante en bonne santé. Continuez les bonnes pratiques agricoles.'**
  String get scanRecHealthy;

  /// Astuce résultat scan
  ///
  /// In fr, this message translates to:
  /// **'Astuce : évitez l\'arrosage excessif pendant 3 jours'**
  String get scanTip;

  /// Sémantique bouton refaire scan
  ///
  /// In fr, this message translates to:
  /// **'Refaire un scan'**
  String get scanRescanSemantics;

  /// Bouton refaire scan
  ///
  /// In fr, this message translates to:
  /// **'Refaire un scan'**
  String get scanRescan;

  /// Sémantique bouton enregistrer journal
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer dans le journal'**
  String get scanSaveJournalSemantics;

  /// Action enregistrer
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// Sémantique bouton partager
  ///
  /// In fr, this message translates to:
  /// **'Partager le résultat'**
  String get scanShareSemantics;

  /// Bouton partager
  ///
  /// In fr, this message translates to:
  /// **'Partager le résultat'**
  String get scanShare;

  /// Message d'erreur écran journal
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String journalError(String error);

  /// Bouton nouvelle parcelle
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle parcelle'**
  String get journalNewPlot;

  /// Titre écran journal
  ///
  /// In fr, this message translates to:
  /// **'Journal agricole'**
  String get journalTitle;

  /// Sous-titre écran journal
  ///
  /// In fr, this message translates to:
  /// **'Suivi de vos parcelles'**
  String get journalSubtitle;

  /// Stat total
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get journalTotal;

  /// Stat saines
  ///
  /// In fr, this message translates to:
  /// **'Saines'**
  String get journalHealthyPlural;

  /// Stat malades
  ///
  /// In fr, this message translates to:
  /// **'Malades'**
  String get journalSickPlural;

  /// Badge statut malade
  ///
  /// In fr, this message translates to:
  /// **'Malade'**
  String get journalStatusSick;

  /// Badge statut sain
  ///
  /// In fr, this message translates to:
  /// **'Sain'**
  String get journalStatusHealthy;

  /// Badge statut non analysé
  ///
  /// In fr, this message translates to:
  /// **'Non analysé'**
  String get journalStatusNotAnalyzed;

  /// Affichage surface en hectares
  ///
  /// In fr, this message translates to:
  /// **'{surface} ha'**
  String journalAreaHa(String surface);

  /// Nombre d'analyses
  ///
  /// In fr, this message translates to:
  /// **'{count} analyse(s)'**
  String journalAnalysesCount(int count);

  /// Dernier diagnostic
  ///
  /// In fr, this message translates to:
  /// **'Dernier : {disease} - {date}'**
  String journalLastDiagnostic(String disease, String date);

  /// Action scanner
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get journalScan;

  /// Texte aucun diagnostic
  ///
  /// In fr, this message translates to:
  /// **'Aucun diagnostic encore'**
  String get journalNoDiagnosticYet;

  /// Action scanner maintenant
  ///
  /// In fr, this message translates to:
  /// **'Scanner maintenant'**
  String get journalScanNow;

  /// Titre état vide journal
  ///
  /// In fr, this message translates to:
  /// **'Aucune parcelle'**
  String get journalEmptyTitle;

  /// Description état vide journal
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre première parcelle\npour commencer le suivi.'**
  String get journalEmptyDescription;

  /// Bouton ajouter une parcelle
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une parcelle'**
  String get journalAddPlot;

  /// Libellé nom parcelle
  ///
  /// In fr, this message translates to:
  /// **'Nom de la parcelle *'**
  String get journalPlotNameLabel;

  /// Libellé description optionnelle
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnel)'**
  String get journalDescriptionOptional;

  /// Libellé surface optionnelle
  ///
  /// In fr, this message translates to:
  /// **'Surface (ha, optionnel)'**
  String get journalSurfaceOptional;

  /// Validation nom parcelle requis
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get journalNameRequired;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get registerTitle;

  /// No description provided for @registerHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Inscription agriculteur'**
  String get registerHeadline;

  /// No description provided for @registerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez vos informations pour créer votre accès.'**
  String get registerDescription;

  /// No description provided for @registerNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get registerNameLabel;

  /// No description provided for @registerFirstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get registerFirstNameLabel;

  /// No description provided for @registerRegionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get registerRegionLabel;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get registerPhoneLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerPasswordLabel;

  /// No description provided for @registerSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get registerSubmit;

  /// No description provided for @registerAlreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'J’ai déjà un compte'**
  String get registerAlreadyAccount;

  /// No description provided for @registerSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie'**
  String get registerSuccess;

  /// No description provided for @validationRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get validationRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide'**
  String get validationPhoneInvalid;

  /// No description provided for @validationPasswordMin.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 6 caractères'**
  String get validationPasswordMin;

  /// No description provided for @resetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get resetTitle;

  /// No description provided for @resetHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetHeadline;

  /// No description provided for @resetDescription.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre numéro de téléphone pour recevoir les instructions.'**
  String get resetDescription;

  /// No description provided for @resetBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get resetBackToLogin;

  /// No description provided for @resetSuccessMessage.
  ///
  /// In fr, this message translates to:
  /// **'Si ce numéro est associé à un compte, des instructions seront envoyées.'**
  String get resetSuccessMessage;

  /// No description provided for @splashInitializing.
  ///
  /// In fr, this message translates to:
  /// **'Initialisation en cours...'**
  String get splashInitializing;

  /// No description provided for @splashPartialInit.
  ///
  /// In fr, this message translates to:
  /// **'Initialisation partielle, mode dégradé.'**
  String get splashPartialInit;

  /// No description provided for @splashAiReady.
  ///
  /// In fr, this message translates to:
  /// **'IA prête'**
  String get splashAiReady;

  /// No description provided for @splashAiUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'IA indisponible'**
  String get splashAiUnavailable;

  /// No description provided for @splashSessionActive.
  ///
  /// In fr, this message translates to:
  /// **'Session active'**
  String get splashSessionActive;

  /// No description provided for @splashSessionGuest.
  ///
  /// In fr, this message translates to:
  /// **'Session invité'**
  String get splashSessionGuest;

  /// No description provided for @splashStatus.
  ///
  /// In fr, this message translates to:
  /// **'{mode} • {session}'**
  String splashStatus(String mode, String session);

  /// No description provided for @welcomeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}'**
  String welcomeGreeting(String name);

  /// No description provided for @welcomeAiReady.
  ///
  /// In fr, this message translates to:
  /// **'IA hors-ligne prête'**
  String get welcomeAiReady;

  /// No description provided for @welcomeAiUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Mode dégradé sans IA'**
  String get welcomeAiUnavailable;

  /// No description provided for @welcomeAiModelStatus.
  ///
  /// In fr, this message translates to:
  /// **'{status} • Modèle v{version}'**
  String welcomeAiModelStatus(String status, String version);

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In fr, this message translates to:
  /// **'Photographiez la feuille malade'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Description.
  ///
  /// In fr, this message translates to:
  /// **'Placez la feuille dans le cadre. Gardez 20-30 cm de distance et une bonne lumière naturelle.'**
  String get onboardingSlide1Description;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In fr, this message translates to:
  /// **'L\'IA analyse hors ligne'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Description.
  ///
  /// In fr, this message translates to:
  /// **'Pas besoin d\'internet. Le diagnostic fonctionne directement sur votre téléphone.'**
  String get onboardingSlide2Description;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In fr, this message translates to:
  /// **'Consultez le diagnostic'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Description.
  ///
  /// In fr, this message translates to:
  /// **'Visualisez la gravité détectée, la confiance de l\'analyse et les recommandations adaptées.'**
  String get onboardingSlide3Description;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In fr, this message translates to:
  /// **'Suivez vos parcelles'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Description.
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez l\'historique des analyses de chaque parcelle dans le journal agricole.'**
  String get onboardingSlide4Description;

  /// No description provided for @onboardingNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// No description provided for @onboardingClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get onboardingClose;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @onboardingHelpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide AgriMada'**
  String get onboardingHelpTitle;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingModelVersionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Version du modèle IA'**
  String get onboardingModelVersionTitle;

  /// No description provided for @onboardingSupportedDiseases.
  ///
  /// In fr, this message translates to:
  /// **'Maladies supportées: {diseases}'**
  String onboardingSupportedDiseases(String diseases);

  /// No description provided for @onboardingAppStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statut de l\'application'**
  String get onboardingAppStatusTitle;

  /// No description provided for @onboardingAiAvailable.
  ///
  /// In fr, this message translates to:
  /// **'IA disponible sur cet appareil'**
  String get onboardingAiAvailable;

  /// No description provided for @onboardingAiUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'IA indisponible, mode dégradé'**
  String get onboardingAiUnavailable;

  /// No description provided for @onboardingActiveVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version active: v{version}'**
  String onboardingActiveVersion(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'mg'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'mg':
      return AppLocalizationsMg();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
