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

  /// Champ numéro de téléphone
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get loginPhoneLabel;

  /// Validation numéro requis
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer votre numéro'**
  String get loginPhoneRequired;

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
  /// **'Ravie de vous revoir sur AgriMada'**
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

  /// Version du modèle embarqué
  ///
  /// In fr, this message translates to:
  /// **'Modèle v{version}'**
  String welcomeModelVersion(String version);

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

  /// Libellé d'accessibilité du bouton d'aide
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get homeHelpSemantics;

  /// Titre carte résumé
  ///
  /// In fr, this message translates to:
  /// **'Résumé de votre exploitation'**
  String get homeSummaryTitle;

  /// Statut quand le modèle embarqué est chargé
  ///
  /// In fr, this message translates to:
  /// **'Analyse photo prête'**
  String get homeSystemReady;

  /// Statut quand le modèle embarqué n'a pas pu être chargé
  ///
  /// In fr, this message translates to:
  /// **'Analyse photo indisponible'**
  String get homeSystemAiUnavailable;

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

  /// Service guide des maladies
  ///
  /// In fr, this message translates to:
  /// **'Maladies du riz'**
  String get homeServiceSolutionsTitle;

  /// Description du service guide des maladies
  ///
  /// In fr, this message translates to:
  /// **'Reconnaître chaque maladie : symptômes, causes et gestes de prévention'**
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

  /// Nom localisé maladie BLB (terme de la fiche FOFIFA)
  ///
  /// In fr, this message translates to:
  /// **'Flétrissement bactérien (BLB)'**
  String get diseaseBacterialLeafBlight;

  /// Nom localisé maladie brown spot
  ///
  /// In fr, this message translates to:
  /// **'Helminthosporiose (tache brune)'**
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

  /// Ligne certitude partage
  ///
  /// In fr, this message translates to:
  /// **'Certitude : {value}'**
  String scanShareCertainty(String value);

  /// Ligne date partage
  ///
  /// In fr, this message translates to:
  /// **'Date: {date}'**
  String scanShareDate(String date);

  /// Certitude : classe nettement en tête
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic probable'**
  String get scanCertaintyProbable;

  /// Certitude : classe en tête mais proche d'autres
  ///
  /// In fr, this message translates to:
  /// **'Diagnostic possible, à confirmer'**
  String get scanCertaintyPossible;

  /// Certitude : aucune maladie retenue
  ///
  /// In fr, this message translates to:
  /// **'Résultat incertain'**
  String get scanCertaintyUncertain;

  /// Explication certitude probable
  ///
  /// In fr, this message translates to:
  /// **'Les symptômes reconnus sont nets. Vérifiez sur la plante avant d\'agir.'**
  String get scanCertaintyExplainProbable;

  /// Explication certitude possible
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs maladies se ressemblent sur cette photo. Faites confirmer par un technicien agricole.'**
  String get scanCertaintyExplainPossible;

  /// Titre résultat incertain
  ///
  /// In fr, this message translates to:
  /// **'L\'application ne reconnaît pas cette photo'**
  String get scanUncertainTitle;

  /// Explication résultat incertain
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est peut-être pas du riz, ou la photo est floue ou mal éclairée. Aucune maladie n\'est retenue et rien n\'est enregistré.'**
  String get scanUncertainBody;

  /// Conseils pour reprendre la photo
  ///
  /// In fr, this message translates to:
  /// **'Pour une nouvelle photo : une seule feuille bien nette, à 20-30 cm, en lumière naturelle, sans contre-jour.'**
  String get scanRetakeTips;

  /// Bouton reprendre la photo
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la photo'**
  String get scanRetakePhoto;

  /// Autres maladies proches selon le modèle
  ///
  /// In fr, this message translates to:
  /// **'Autres possibilités : {names}'**
  String scanOtherCandidates(String names);

  /// Écran résultat sans analyse en cours
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat à afficher'**
  String get scanNoResult;

  /// Question gravité déclarée
  ///
  /// In fr, this message translates to:
  /// **'Quelle part de la parcelle est touchée ?'**
  String get scanSeverityQuestion;

  /// Gravité déclarée : quelques plants
  ///
  /// In fr, this message translates to:
  /// **'Quelques plants'**
  String get scanSeverityFewPlants;

  /// Gravité déclarée : moins d'un tiers de la parcelle
  ///
  /// In fr, this message translates to:
  /// **'Moins d\'un tiers'**
  String get scanSeverityUnderThird;

  /// Gravité déclarée : plus d'un tiers de la parcelle
  ///
  /// In fr, this message translates to:
  /// **'Plus d\'un tiers'**
  String get scanSeverityOverThird;

  /// Gravité absente ou issue de l'ancien calcul
  ///
  /// In fr, this message translates to:
  /// **'Part touchée non renseignée'**
  String get scanSeverityUnknown;

  /// Titre section conseils
  ///
  /// In fr, this message translates to:
  /// **'Que faire ?'**
  String get scanAdviceTitle;

  /// Mention : aucun produit chimique conseillé
  ///
  /// In fr, this message translates to:
  /// **'AgriMada ne recommande aucun produit ni dosage. Avant tout traitement, demandez conseil à un technicien agricole.'**
  String get scanAdviceNoChemical;

  /// Conseil fiche FOFIFA bactérioses
  ///
  /// In fr, this message translates to:
  /// **'Utiliser des semences saines'**
  String get scanAdviceHealthySeeds;

  /// Conseil fiche FOFIFA bactérioses
  ///
  /// In fr, this message translates to:
  /// **'Enlever et détruire les résidus des parcelles atteintes'**
  String get scanAdviceRemoveResidues;

  /// Conseil fiche FOFIFA bactérioses
  ///
  /// In fr, this message translates to:
  /// **'Enlever et détruire les mauvaises herbes qui hébergent la bactérie'**
  String get scanAdviceRemoveHostWeeds;

  /// Conseil fiche FOFIFA bactérioses
  ///
  /// In fr, this message translates to:
  /// **'Nettoyer les outils au savon après chaque utilisation'**
  String get scanAdviceCleanTools;

  /// Conseil fiche FOFIFA bactérioses
  ///
  /// In fr, this message translates to:
  /// **'Prévenir le technicien agricole le plus proche'**
  String get scanAdviceAlertTechnician;

  /// Bouton écarter le résultat
  ///
  /// In fr, this message translates to:
  /// **'Ce résultat me semble faux'**
  String get scanDiscard;

  /// Message résultat écarté
  ///
  /// In fr, this message translates to:
  /// **'Résultat écarté, rien n\'a été enregistré'**
  String get scanDiscarded;

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

  /// Recommandation BLB
  ///
  /// In fr, this message translates to:
  /// **'Éviter l\'excès d\'azote'**
  String get scanRecBlbAvoidNitrogen;

  /// Recommandation BLB
  ///
  /// In fr, this message translates to:
  /// **'Utiliser des variétés résistantes lors du prochain cycle'**
  String get scanRecBlbUseResistantVarieties;

  /// Recommandation helminthosporiose
  ///
  /// In fr, this message translates to:
  /// **'Améliorer la fertilisation (potassium)'**
  String get scanRecBrownSpotFertilize;

  /// Recommandation helminthosporiose
  ///
  /// In fr, this message translates to:
  /// **'Éviter que le riz manque d\'eau'**
  String get scanRecBrownSpotAvoidStress;

  /// Recommandation plante saine
  ///
  /// In fr, this message translates to:
  /// **'Plante en bonne santé. Continuez les bonnes pratiques agricoles.'**
  String get scanRecHealthy;

  /// Recommandation plante saine eau
  ///
  /// In fr, this message translates to:
  /// **'Maintenir une bonne gestion de l\'eau'**
  String get scanRecHealthyWater;

  /// Recommandation plante saine fertilisation
  ///
  /// In fr, this message translates to:
  /// **'Fertilisation équilibrée'**
  String get scanRecHealthyFertilization;

  /// Recommandation plante saine surveillance
  ///
  /// In fr, this message translates to:
  /// **'Surveillance régulière des parcelles'**
  String get scanRecHealthyMonitoring;

  /// Recommandation plante saine rotation
  ///
  /// In fr, this message translates to:
  /// **'Rotation des cultures'**
  String get scanRecHealthyRotation;

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

  /// Titre carte version du modèle
  ///
  /// In fr, this message translates to:
  /// **'Version du modèle IA'**
  String get modelVersionTitle;

  /// Liste des maladies reconnues par le modèle
  ///
  /// In fr, this message translates to:
  /// **'Maladies reconnues : {diseases}'**
  String modelSupportedDiseases(String diseases);

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

  /// Formulaire parcelle : photo depuis la caméra
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get plotPhotoTake;

  /// Formulaire parcelle : photo depuis la galerie
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get plotPhotoGallery;

  /// Formulaire parcelle : titre photo
  ///
  /// In fr, this message translates to:
  /// **'Photo de la parcelle'**
  String get plotPhotoLabel;

  /// Formulaire parcelle : bouton photo
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get plotPhotoAdd;

  /// Formulaire parcelle : la photo est facultative
  ///
  /// In fr, this message translates to:
  /// **'Facultative'**
  String get plotPhotoHint;

  /// Formulaire parcelle : retirer la photo
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get plotPhotoRemove;

  /// Formulaire parcelle : nom
  ///
  /// In fr, this message translates to:
  /// **'Nom de la parcelle'**
  String get plotNameLabel;

  /// Formulaire parcelle : exemple de nom
  ///
  /// In fr, this message translates to:
  /// **'Ex. : rizière du bas-fond'**
  String get plotNameHint;

  /// Formulaire parcelle : culture
  ///
  /// In fr, this message translates to:
  /// **'Culture'**
  String get plotCropLabel;

  /// Formulaire parcelle : culture par défaut
  ///
  /// In fr, this message translates to:
  /// **'Riz'**
  String get plotCropHint;

  /// Formulaire parcelle : surface
  ///
  /// In fr, this message translates to:
  /// **'Surface cultivée'**
  String get plotSurfaceLabel;

  /// Formulaire parcelle : exemple de surface
  ///
  /// In fr, this message translates to:
  /// **'En hectares, ex. : 0,55'**
  String get plotSurfaceHint;

  /// Unité de surface
  ///
  /// In fr, this message translates to:
  /// **'ha'**
  String get plotSurfaceSuffix;

  /// Formulaire parcelle : surface invalide
  ///
  /// In fr, this message translates to:
  /// **'Surface invalide. Exemple : 0,55'**
  String get plotSurfaceInvalid;

  /// Formulaire parcelle : emplacement
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get plotLocationLabel;

  /// Formulaire parcelle : exemple d'emplacement
  ///
  /// In fr, this message translates to:
  /// **'Village, fokontany, repère'**
  String get plotLocationHint;

  /// Formulaire parcelle : échec d'enregistrement
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'enregistrer la parcelle'**
  String get plotSaveFailed;

  /// Titre écran inscription
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get registerTitle;

  /// Salutation inscription
  ///
  /// In fr, this message translates to:
  /// **'Bonjour!'**
  String get registerHello;

  /// Sous-titre inscription
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur AgriMada'**
  String get registerWelcome;

  /// Libellé nom complet
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get registerNameLabel;

  /// Libellé email inscription
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// Libellé mot de passe inscription
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get registerPasswordLabel;

  /// Libellé confirmer mot de passe
  ///
  /// In fr, this message translates to:
  /// **'Confirmer mot de passe'**
  String get registerConfirmPasswordLabel;

  /// Bouton inscription
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get registerSubmit;

  /// Texte conditions inscription
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité'**
  String get registerAcceptTerms;

  /// Erreur conditions non acceptées
  ///
  /// In fr, this message translates to:
  /// **'Veuillez accepter les Conditions d\'utilisation'**
  String get registerAcceptError;

  /// Lien connexion inscription
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte?'**
  String get registerHasAccount;

  /// Texte lien connexion
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get registerLoginLink;

  /// Succès inscription
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie'**
  String get registerSuccess;

  /// Titre page prévention
  ///
  /// In fr, this message translates to:
  /// **'Prévenir les maladies'**
  String get preventionTitle;

  /// Sous-titre prévention
  ///
  /// In fr, this message translates to:
  /// **'Prévenez vos rizicultures'**
  String get preventionSubtitle;

  /// Titre astuce prévention
  ///
  /// In fr, this message translates to:
  /// **'Astuce de prévention'**
  String get preventionAstuceTitle;

  /// Description astuce prévention
  ///
  /// In fr, this message translates to:
  /// **'Des gestes simples aujourd\'hui pour un riz sain et une meilleure récolte demain'**
  String get preventionAstuceDesc;

  /// Titre astuce du moment
  ///
  /// In fr, this message translates to:
  /// **'Astuce du moment'**
  String get preventionAstuceMoment;

  /// Sous-titre gestion eau
  ///
  /// In fr, this message translates to:
  /// **'Maintenez une bonne gestion de l\'eau'**
  String get preventionWaterManagement;

  /// Description gestion eau
  ///
  /// In fr, this message translates to:
  /// **'Une bonne gestion de l\'eau limite le développement des maladies comme la pyriculariose, la bactériose et la fusariose.'**
  String get preventionWaterDesc;

  /// Titre pourquoi efficace
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi c\'est efficace ?'**
  String get preventionPourquoi;

  /// Description pourquoi efficace
  ///
  /// In fr, this message translates to:
  /// **'L\'excès d\'eau et l\'humidité favorisent les champignons et bactéries. Une bonne gestion de l\'eau renforce la résistance naturelle du riz.'**
  String get preventionPourquoiDesc;

  /// Titre bon à savoir
  ///
  /// In fr, this message translates to:
  /// **'Bon à savoir'**
  String get preventionBonASavoir;

  /// Description bon à savoir
  ///
  /// In fr, this message translates to:
  /// **'Des plantes vigoureuses, un sol bien oxygéné et une eau bien gérée sont les clés d\'un riz en bonne santé.'**
  String get preventionBonASavoirDesc;

  /// Titre comment faire
  ///
  /// In fr, this message translates to:
  /// **'Comment faire ?'**
  String get preventionCommentFaire;

  /// Titre page guides
  ///
  /// In fr, this message translates to:
  /// **'Guides des maladies'**
  String get guidesTitle;

  /// Sous-titre guides
  ///
  /// In fr, this message translates to:
  /// **'Fiches d\'identification hors ligne'**
  String get guidesSubtitle;

  /// Section symptômes
  ///
  /// In fr, this message translates to:
  /// **'Symptômes'**
  String get guidesSymptoms;

  /// Section causes
  ///
  /// In fr, this message translates to:
  /// **'Causes'**
  String get guidesCauses;

  /// Section traitements
  ///
  /// In fr, this message translates to:
  /// **'Traitements'**
  String get guidesTreatments;

  /// Titre du menu
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get drawerMenuTitle;

  /// Titre accueil drawer
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get drawerHomeTitle;

  /// Sous-titre accueil drawer
  ///
  /// In fr, this message translates to:
  /// **'Revenir à la page d\'accueil'**
  String get drawerHomeSubtitle;

  /// Titre parcelles drawer
  ///
  /// In fr, this message translates to:
  /// **'Mes parcelles'**
  String get drawerPlotsTitle;

  /// Sous-titre parcelles drawer
  ///
  /// In fr, this message translates to:
  /// **'Suivi de vos rizières et surfaces'**
  String get drawerPlotsSubtitle;

  /// Titre historique drawer
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get drawerHistoryTitle;

  /// Sous-titre historique drawer
  ///
  /// In fr, this message translates to:
  /// **'Liste de vos analyses passées'**
  String get drawerHistorySubtitle;

  /// Titre guides dans le drawer
  ///
  /// In fr, this message translates to:
  /// **'Guides des maladies'**
  String get drawerGuidesTitle;

  /// Sous-titre guides dans le drawer
  ///
  /// In fr, this message translates to:
  /// **'Fiches d\'identification hors ligne'**
  String get drawerGuidesSubtitle;

  /// Titre paramètres dans le drawer
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get drawerSettingsTitle;

  /// Sous-titre paramètres dans le drawer
  ///
  /// In fr, this message translates to:
  /// **'Langue et préférences'**
  String get drawerSettingsSubtitle;

  /// Titre stockage
  ///
  /// In fr, this message translates to:
  /// **'Stockage'**
  String get drawerStorage;

  /// Texte mémoire utilisée
  ///
  /// In fr, this message translates to:
  /// **'Mémoire utilisée sur ce smartphone'**
  String get drawerMemoryUsed;

  /// Bouton déconnexion drawer
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get drawerLogout;

  /// Dernière mise à jour du modèle
  ///
  /// In fr, this message translates to:
  /// **'Dernière MAJ : {date}'**
  String drawerLastUpdate(String date);

  /// Texte modèle embarqué
  ///
  /// In fr, this message translates to:
  /// **'Modèle IA embarqué'**
  String get drawerEmbeddedModel;

  /// Titre écran paramètres
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// Téléphone indisponible
  ///
  /// In fr, this message translates to:
  /// **'Téléphone indisponible'**
  String get settingsPhoneUnavailable;

  /// Région indisponible
  ///
  /// In fr, this message translates to:
  /// **'Région indisponible'**
  String get settingsRegionUnavailable;

  /// Paramètre langue
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// Bouton déconnexion paramètres
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get settingsLogout;

  /// Titre écran mot de passe oublié
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get resetPasswordTitle;

  /// Titre réinitialisation
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetPasswordHeadline;

  /// Instructions réinitialisation
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre numéro de téléphone pour recevoir les instructions.'**
  String get resetPasswordInstruction;

  /// Label téléphone
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get resetPasswordPhoneLabel;

  /// Hint téléphone
  ///
  /// In fr, this message translates to:
  /// **'0341234567'**
  String get resetPasswordPhoneHint;

  /// Erreur champ requis
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get resetPasswordPhoneRequired;

  /// Erreur numéro invalide
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide'**
  String get resetPasswordPhoneInvalid;

  /// Lien retour connexion
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get resetPasswordBackToLogin;

  /// Bouton suivant onboarding
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// Bouton commencer onboarding
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStart;

  /// Bouton passer l'onboarding
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// Titre de l'onboarding
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get onboardingWelcome;

  /// Titre de l'onboarding en mode aide
  ///
  /// In fr, this message translates to:
  /// **'Aide AgriMada'**
  String get onboardingHelpTitle;

  /// Le modèle embarqué est chargé
  ///
  /// In fr, this message translates to:
  /// **'Analyse photo disponible sur ce téléphone'**
  String get onboardingAiAvailable;

  /// Le modèle embarqué n'a pas pu être chargé
  ///
  /// In fr, this message translates to:
  /// **'Analyse photo indisponible sur ce téléphone'**
  String get onboardingAiUnavailable;

  /// Action fermer
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// Titre slide 1
  ///
  /// In fr, this message translates to:
  /// **'Photographiez la feuille malade'**
  String get onboardingSlide1Title;

  /// Desc slide 1
  ///
  /// In fr, this message translates to:
  /// **'Placez la feuille dans le cadre. Gardez 20-30 cm de distance et une bonne lumière naturelle.'**
  String get onboardingSlide1Desc;

  /// Titre slide 2
  ///
  /// In fr, this message translates to:
  /// **'L\'IA analyse hors ligne'**
  String get onboardingSlide2Title;

  /// Desc slide 2
  ///
  /// In fr, this message translates to:
  /// **'Pas besoin d\'internet. Le diagnostic fonctionne directement sur votre téléphone.'**
  String get onboardingSlide2Desc;

  /// Titre slide 3
  ///
  /// In fr, this message translates to:
  /// **'Consultez le diagnostic'**
  String get onboardingSlide3Title;

  /// Desc slide 3
  ///
  /// In fr, this message translates to:
  /// **'Voyez la maladie probable, le niveau de certitude et les gestes de prévention.'**
  String get onboardingSlide3Desc;

  /// Titre slide 4
  ///
  /// In fr, this message translates to:
  /// **'Suivez vos parcelles'**
  String get onboardingSlide4Title;

  /// Desc slide 4
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez l\'historique des analyses de chaque parcelle dans le journal agricole.'**
  String get onboardingSlide4Desc;

  /// Tip 1 prevention
  ///
  /// In fr, this message translates to:
  /// **'Assurez un drainage efficace de la parcelle pour éviter la stagnation d\'eau.'**
  String get preventionTip1;

  /// Tip 2 prevention
  ///
  /// In fr, this message translates to:
  /// **'Alternez les phases d\'inondation et d\'assèchement (en irrigation intermittente).'**
  String get preventionTip2;

  /// Tip 3 prevention
  ///
  /// In fr, this message translates to:
  /// **'Évitez un niveau d\'eau trop élevé en permanence (3-5 cm suffisent).'**
  String get preventionTip3;

  /// Tip 4 prevention
  ///
  /// In fr, this message translates to:
  /// **'Évitez l\'excès d\'azote, qui rend les plantes plus sensibles aux maladies.'**
  String get preventionTip4;

  /// Tip 5 prevention
  ///
  /// In fr, this message translates to:
  /// **'Nettoyez régulièrement les canaux et entrées d\'eau pour une meilleure circulation.'**
  String get preventionTip5;

  /// Statut splash initialisation
  ///
  /// In fr, this message translates to:
  /// **'Initialisation en cours...'**
  String get splashStatusInitializing;

  /// Statut splash dégradé
  ///
  /// In fr, this message translates to:
  /// **'Initialisation partielle, mode dégradé.'**
  String get splashStatusDegraded;

  /// Statut splash IA prête
  ///
  /// In fr, this message translates to:
  /// **'IA prête'**
  String get splashStatusAiReady;

  /// Statut splash IA indisponible
  ///
  /// In fr, this message translates to:
  /// **'IA indisponible'**
  String get splashStatusAiUnavailable;

  /// Statut splash session active
  ///
  /// In fr, this message translates to:
  /// **'Session active'**
  String get splashStatusSessionActive;

  /// Statut splash session invité
  ///
  /// In fr, this message translates to:
  /// **'Session invité'**
  String get splashStatusSessionGuest;

  /// En-tête date CSV
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get exportCsvDate;

  /// En-tête parcelle CSV
  ///
  /// In fr, this message translates to:
  /// **'Parcelle'**
  String get exportCsvPlot;

  /// En-tête maladie CSV
  ///
  /// In fr, this message translates to:
  /// **'Maladie'**
  String get exportCsvDisease;

  /// En-tête gravité CSV
  ///
  /// In fr, this message translates to:
  /// **'Gravité'**
  String get exportCsvSeverity;

  /// En-tête confiance CSV
  ///
  /// In fr, this message translates to:
  /// **'Confiance(%)'**
  String get exportCsvConfidence;

  /// En-tête reco CSV
  ///
  /// In fr, this message translates to:
  /// **'Recommandations'**
  String get exportCsvRecommendations;

  /// En-tête traitement CSV
  ///
  /// In fr, this message translates to:
  /// **'Traitement appliqué'**
  String get exportCsvTreatment;

  /// Footer PDF
  ///
  /// In fr, this message translates to:
  /// **'Généré par AgriMada - Agriculture intelligente'**
  String get exportPdfGeneratedBy;

  /// Titre PDF
  ///
  /// In fr, this message translates to:
  /// **'Export journal agricole'**
  String get exportPdfTitle;

  /// Toutes parcelles PDF
  ///
  /// In fr, this message translates to:
  /// **'Toutes les parcelles'**
  String get exportPdfAllPlots;

  /// Label parcelle PDF
  ///
  /// In fr, this message translates to:
  /// **'Parcelle: {plot}'**
  String exportPdfPlotLabel(String plot);

  /// Label date PDF
  ///
  /// In fr, this message translates to:
  /// **'Date d\'export: {date}'**
  String exportPdfDateLabel(String date);

  /// No description provided for @guideDisease1Name.
  ///
  /// In fr, this message translates to:
  /// **'Brûlure bactérienne'**
  String get guideDisease1Name;

  /// No description provided for @guideDisease1Desc.
  ///
  /// In fr, this message translates to:
  /// **'Maladie bactérienne qui provoque le flétrissement des feuilles. Les premiers symptômes apparaissent sous forme de lésions gris-vert le long des bords des feuilles, qui s\'étendent rapidement et deviennent jaune-blanchâtre.'**
  String get guideDisease1Desc;

  /// No description provided for @guideDisease1Symptoms.
  ///
  /// In fr, this message translates to:
  /// **'• Lésions gris-vert le long des nervures\n• Flétrissement en V sur les bords\n• Exsudat bactérien jaune par temps humide\n• Feuilles qui sèchent et blanchissent'**
  String get guideDisease1Symptoms;

  /// No description provided for @guideDisease1Causes.
  ///
  /// In fr, this message translates to:
  /// **'• Forte humidité et températures élevées\n• Excès d\'azote\n• Eau stagnante prolongée\n• Variétés sensibles'**
  String get guideDisease1Causes;

  /// No description provided for @guideDisease2Name.
  ///
  /// In fr, this message translates to:
  /// **'Tache brune'**
  String get guideDisease2Name;

  /// No description provided for @guideDisease2Desc.
  ///
  /// In fr, this message translates to:
  /// **'Maladie fongique courante du riz, surtout dans les sols carencés. Les taches brunes ovales apparaissent sur les feuilles, réduisant la capacité photosynthétique de la plante.'**
  String get guideDisease2Desc;

  /// No description provided for @guideDisease2Symptoms.
  ///
  /// In fr, this message translates to:
  /// **'• Taches brunes ovales sur les feuilles\n• Anneaux concentriques sur les lésions\n• Grains tachetés dans les cas sévères\n• Réduction du rendement'**
  String get guideDisease2Symptoms;

  /// No description provided for @guideDisease2Causes.
  ///
  /// In fr, this message translates to:
  /// **'• Carence en potassium\n• Sols pauvres et mal drainés\n• Stress hydrique\n• Forte humidité relative'**
  String get guideDisease2Causes;

  /// No description provided for @guideDisease3Name.
  ///
  /// In fr, this message translates to:
  /// **'Charbon foliaire'**
  String get guideDisease3Name;

  /// No description provided for @guideDisease3Desc.
  ///
  /// In fr, this message translates to:
  /// **'Maladie fongique qui se manifeste par de petites taches noires sur les feuilles de riz. Le champignon se développe dans les tissus foliaires et forme des sores noirs remplis de spores.'**
  String get guideDisease3Desc;

  /// No description provided for @guideDisease3Symptoms.
  ///
  /// In fr, this message translates to:
  /// **'• Taches noires angulaires sur les feuilles\n• Lésions sur les gaines foliaires\n• Spores noires poudreuses\n• Affaiblissement général de la plante'**
  String get guideDisease3Symptoms;

  /// No description provided for @guideDisease3Causes.
  ///
  /// In fr, this message translates to:
  /// **'• Humidité élevée prolongée\n• Températures modérées (20-25°C)\n• Densité de semis élevée\n• Mauvais drainage'**
  String get guideDisease3Causes;

  /// No description provided for @guideDisease4Name.
  ///
  /// In fr, this message translates to:
  /// **'Plante saine'**
  String get guideDisease4Name;

  /// No description provided for @guideDisease4Desc.
  ///
  /// In fr, this message translates to:
  /// **'Votre plant de riz ne présente aucun signe de maladie. Continuez à appliquer les bonnes pratiques agricoles pour maintenir la santé de vos cultures.'**
  String get guideDisease4Desc;

  /// No description provided for @guideDisease4Symptoms.
  ///
  /// In fr, this message translates to:
  /// **'• Feuilles vertes et vigoureuses\n• Croissance régulière\n• Pas de lésions ni de décoloration\n• Tallage normal'**
  String get guideDisease4Symptoms;

  /// No description provided for @guideDisease4Causes.
  ///
  /// In fr, this message translates to:
  /// **'Bonnes pratiques agricoles :'**
  String get guideDisease4Causes;

  /// No description provided for @guidesDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Ces fiches aident à reconnaître une maladie. Avant tout traitement, demandez conseil à un technicien agricole.'**
  String get guidesDisclaimer;

  /// No description provided for @guidesAdvice.
  ///
  /// In fr, this message translates to:
  /// **'Gestes recommandés'**
  String get guidesAdvice;

  /// No description provided for @guidesHealthySigns.
  ///
  /// In fr, this message translates to:
  /// **'Signes d\'une plante saine'**
  String get guidesHealthySigns;

  /// No description provided for @journalHistorySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des analyses'**
  String get journalHistorySubtitle;

  /// No description provided for @journalHistoryEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune analyse'**
  String get journalHistoryEmptyTitle;

  /// No description provided for @journalHistoryEmptyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vos diagnostics récents apparaîtront ici'**
  String get journalHistoryEmptyDescription;

  /// No description provided for @journalStartDiagnosis.
  ///
  /// In fr, this message translates to:
  /// **'Faire un diagnostic'**
  String get journalStartDiagnosis;

  /// No description provided for @exportNothing.
  ///
  /// In fr, this message translates to:
  /// **'Aucun diagnostic à exporter'**
  String get exportNothing;

  /// No description provided for @exportAction.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get exportAction;

  /// No description provided for @exportAsCsv.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get exportAsCsv;

  /// No description provided for @exportAsPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en PDF'**
  String get exportAsPdf;

  /// No description provided for @exportShareText.
  ///
  /// In fr, this message translates to:
  /// **'Journal agricole AgriMada'**
  String get exportShareText;

  /// No description provided for @exportDone.
  ///
  /// In fr, this message translates to:
  /// **'Export prêt à être partagé'**
  String get exportDone;

  /// No description provided for @parcelDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail de la parcelle'**
  String get parcelDetailTitle;

  /// No description provided for @parcelDetailNewAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'Faire une nouvelle analyse'**
  String get parcelDetailNewAnalysis;

  /// No description provided for @parcelDetailNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Parcelle introuvable'**
  String get parcelDetailNotFound;

  /// No description provided for @parcelDetailNoAnalysis.
  ///
  /// In fr, this message translates to:
  /// **'Aucune analyse pour cette parcelle'**
  String get parcelDetailNoAnalysis;

  /// No description provided for @parcelDetailNotAnalyzedYet.
  ///
  /// In fr, this message translates to:
  /// **'Cette parcelle n\'a pas encore été analysée'**
  String get parcelDetailNotAnalyzedYet;

  /// No description provided for @parcelDetailHealthStatus.
  ///
  /// In fr, this message translates to:
  /// **'État de santé'**
  String get parcelDetailHealthStatus;

  /// No description provided for @registerLastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get registerLastNameLabel;

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

  /// No description provided for @registerFieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get registerFieldRequired;

  /// No description provided for @registerPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide'**
  String get registerPhoneInvalid;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 8 caractères'**
  String get registerPasswordTooShort;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get registerPasswordMismatch;

  /// No description provided for @splashLogoSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Logo AgriMada'**
  String get splashLogoSemantics;

  /// No description provided for @syncInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation…'**
  String get syncInProgress;
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
