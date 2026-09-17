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

  /// Libellé d'accessibilité du logo ISPM sur l'accueil
  ///
  /// In fr, this message translates to:
  /// **'Logo de l\'ISPM'**
  String get homeIspmLogoSemantics;

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

  /// Classe bls du modèle (ADR-014), terme de la fiche FOFIFA
  ///
  /// In fr, this message translates to:
  /// **'Strie bactérienne (BLS)'**
  String get diseaseBacterialLeafStreak;

  /// Classe pyriculariose_feuille du modèle (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Pyriculariose'**
  String get diseaseBlast;

  /// Classe cercosporiose du modèle (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Cercosporiose'**
  String get diseaseNarrowBrownLeafSpot;

  /// Classe echaudure du modèle (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Échaudure des feuilles'**
  String get diseaseLeafScald;

  /// Classe mildiou du modèle (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Mildiou'**
  String get diseaseDownyMildew;

  /// Classe degats_hispa du modèle (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Dégâts d\'hispa (pou du riz)'**
  String get diseaseHispaDamage;

  /// Classe carence_azote du modèle (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Carence en azote'**
  String get diseaseNitrogenDeficiency;

  /// Classe carence_phosphore du modèle (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Carence en phosphore'**
  String get diseasePhosphorusDeficiency;

  /// Classe carence_potassium du modèle (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Carence en potassium'**
  String get diseasePotassiumDeficiency;

  /// Classe de rejet pas_riz du modèle, jamais affichée comme maladie (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas du riz'**
  String get diseaseNotRice;

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
  /// **'Piste à confirmer'**
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
  /// **'Modèle expérimental : il se trompe souvent sur les photos prises au champ. Ce résultat est une piste, pas un diagnostic. Faites-le confirmer par un technicien agricole avant d\'agir.'**
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

  /// No description provided for @exportCsvCertainty.
  ///
  /// In fr, this message translates to:
  /// **'Certitude'**
  String get exportCsvCertainty;

  /// No description provided for @exportCsvOrgans.
  ///
  /// In fr, this message translates to:
  /// **'Parties observées'**
  String get exportCsvOrgans;

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

  /// Titre de la section de recherche parmi toutes les fiches
  ///
  /// In fr, this message translates to:
  /// **'Guide complet'**
  String get guidesKnowledgeSectionTitle;

  /// Sous-titre de la section guide complet
  ///
  /// In fr, this message translates to:
  /// **'Toutes les classes connues, y compris celles que l\'application ne détecte pas encore'**
  String get guidesKnowledgeSectionSubtitle;

  /// Bandeau affiché sur une fiche non validée (ADR-010)
  ///
  /// In fr, this message translates to:
  /// **'Brouillon, non validé par un agronome'**
  String get guidesDraftBadge;

  /// Texte d'aide du champ de recherche des fiches
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une maladie (français ou malgache)…'**
  String get guidesSearchHint;

  /// Message quand la recherche ne trouve aucune fiche
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get guidesNoResults;

  /// Section prévention d'une fiche
  ///
  /// In fr, this message translates to:
  /// **'Prévention'**
  String get guidesPreventionTitle;

  /// Section confusions possibles d'une fiche
  ///
  /// In fr, this message translates to:
  /// **'Peut se confondre avec'**
  String get guidesConfusionTitle;

  /// Section sources d'une fiche
  ///
  /// In fr, this message translates to:
  /// **'Sources'**
  String get guidesSourcesTitle;

  /// Section conditions favorables d'une fiche
  ///
  /// In fr, this message translates to:
  /// **'Conditions favorables'**
  String get guidesConditionsTitle;

  /// Message affiché quand les fiches embarquées ne se chargent pas
  ///
  /// In fr, this message translates to:
  /// **'Le guide complet n\'a pas pu être ouvert'**
  String get guidesLoadError;

  /// Titre du conseiller dans le drawer
  ///
  /// In fr, this message translates to:
  /// **'Conseiller'**
  String get drawerAgentTitle;

  /// Sous-titre du conseiller dans le drawer
  ///
  /// In fr, this message translates to:
  /// **'Poser une question'**
  String get drawerAgentSubtitle;

  /// Titre de l'écran du conseiller (ADR-012)
  ///
  /// In fr, this message translates to:
  /// **'Conseiller AgriMada'**
  String get agentTitle;

  /// Sous-titre de l'écran du conseiller
  ///
  /// In fr, this message translates to:
  /// **'Réponses tirées des fiches et de vos scans'**
  String get agentSubtitle;

  /// Titre de la carte d'accès au conseiller sur l'accueil
  ///
  /// In fr, this message translates to:
  /// **'Une question sur votre riz ?'**
  String get agentHomeCardTitle;

  /// Description de la carte d'accès au conseiller
  ///
  /// In fr, this message translates to:
  /// **'Le conseiller répond à partir des fiches AgriMada et de vos derniers scans (connexion nécessaire).'**
  String get agentHomeCardDescription;

  /// Titre de la demande d'accord
  ///
  /// In fr, this message translates to:
  /// **'Avant de commencer'**
  String get agentConsentTitle;

  /// Bouton d'acceptation de la conservation des échanges
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte'**
  String get agentConsentAccept;

  /// Bouton de refus de la conservation des échanges
  ///
  /// In fr, this message translates to:
  /// **'Non merci'**
  String get agentConsentDecline;

  /// Bandeau permanent de l'écran du conseiller
  ///
  /// In fr, this message translates to:
  /// **'Conseils automatiques tirés de fiches pas encore validées par un agronome. Le conseiller ne pose aucun diagnostic et ne recommande aucun produit : confirmez toujours avec un technicien agricole.'**
  String get agentDisclaimer;

  /// Titre quand la conversation est vide
  ///
  /// In fr, this message translates to:
  /// **'Posez votre question'**
  String get agentEmptyTitle;

  /// Suggestion de question
  ///
  /// In fr, this message translates to:
  /// **'Que dit mon dernier scan ?'**
  String get agentSuggestionScan;

  /// Suggestion de question
  ///
  /// In fr, this message translates to:
  /// **'Comment prévenir la pyriculariose ?'**
  String get agentSuggestionPrevention;

  /// Suggestion de question
  ///
  /// In fr, this message translates to:
  /// **'Mes feuilles jaunissent depuis la pointe, qu\'est-ce que c\'est ?'**
  String get agentSuggestionSymptoms;

  /// Texte d'aide du champ de saisie
  ///
  /// In fr, this message translates to:
  /// **'Votre question…'**
  String get agentInputHint;

  /// Infobulle du bouton d'envoi
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get agentSend;

  /// Indication pendant la réponse
  ///
  /// In fr, this message translates to:
  /// **'Le conseiller consulte les fiches…'**
  String get agentThinking;

  /// Action pour recommencer la conversation
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle conversation'**
  String get agentNewConversation;

  /// Action d'effacement des échanges conservés
  ///
  /// In fr, this message translates to:
  /// **'Effacer mes échanges'**
  String get agentDeleteHistory;

  /// Confirmation de l'effacement
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes vos questions et réponses conservées sur le serveur ?'**
  String get agentDeleteHistoryConfirm;

  /// Bouton de confirmation de l'effacement
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get agentConfirmDelete;

  /// Action de retrait de l'accord (efface aussi les échanges)
  ///
  /// In fr, this message translates to:
  /// **'Retirer mon accord'**
  String get agentWithdrawConsent;

  /// Bandeau hors ligne
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion : le conseiller a besoin d\'internet. Le guide des fiches reste disponible hors ligne.'**
  String get agentOffline;

  /// Titre de la liste des fiches citées
  ///
  /// In fr, this message translates to:
  /// **'Fiches citées'**
  String get agentFichesTitle;

  /// Bouton de partage vers un technicien
  ///
  /// In fr, this message translates to:
  /// **'Demander à un technicien'**
  String get agentAskTechnician;

  /// Début du message partagé au technicien
  ///
  /// In fr, this message translates to:
  /// **'Question posée au conseiller AgriMada, à vérifier :'**
  String get agentTechnicianShareIntro;

  /// Titre d'une réponse d'urgence de santé
  ///
  /// In fr, this message translates to:
  /// **'Urgence'**
  String get agentUrgentTitle;

  /// Avertissement reponse_automatique
  ///
  /// In fr, this message translates to:
  /// **'Réponse automatique : confirmez avec un technicien agricole avant d\'agir.'**
  String get agentWarningAutomatic;

  /// Avertissement fiches_brouillon
  ///
  /// In fr, this message translates to:
  /// **'Tirée de fiches en brouillon, pas encore validées par un agronome.'**
  String get agentWarningDraft;

  /// Avertissement modele_experimental
  ///
  /// In fr, this message translates to:
  /// **'Les pistes de scan viennent d\'un modèle expérimental.'**
  String get agentWarningExperimental;

  /// Avertissement malgache_non_relu
  ///
  /// In fr, this message translates to:
  /// **'Malgache produit automatiquement, pas encore relu par un locuteur natif.'**
  String get agentWarningMalagasy;

  /// Motif d'orientation piste_a_confirmer
  ///
  /// In fr, this message translates to:
  /// **'Piste de scan à confirmer'**
  String get agentReasonScanToConfirm;

  /// Motif d'orientation maladie_a_signaler
  ///
  /// In fr, this message translates to:
  /// **'Maladie qui se propage ou sans remède : à signaler vite'**
  String get agentReasonReport;

  /// Motif d'orientation gravite_elevee
  ///
  /// In fr, this message translates to:
  /// **'Plus d\'un tiers de la parcelle touché'**
  String get agentReasonSevere;

  /// Motif d'orientation scan_sans_nom
  ///
  /// In fr, this message translates to:
  /// **'Scan sans maladie nommée'**
  String get agentReasonUnnamedScan;

  /// Motif d'orientation hors_fiches
  ///
  /// In fr, this message translates to:
  /// **'Question hors des fiches'**
  String get agentReasonOutOfScope;

  /// Motif d'orientation demande_traitement
  ///
  /// In fr, this message translates to:
  /// **'Seul un technicien peut conseiller un traitement'**
  String get agentReasonTreatment;

  /// Erreur réseau
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifiez votre connexion.'**
  String get agentErrorOffline;

  /// Erreur quota atteint
  ///
  /// In fr, this message translates to:
  /// **'Vous avez posé toutes vos questions pour aujourd\'hui. Revenez demain.'**
  String get agentErrorQuota;

  /// Erreur service indisponible
  ///
  /// In fr, this message translates to:
  /// **'Le conseiller est momentanément indisponible. Réessayez plus tard.'**
  String get agentErrorUnavailable;

  /// Erreur session expirée
  ///
  /// In fr, this message translates to:
  /// **'Votre session a expiré : reconnectez-vous.'**
  String get agentErrorSession;

  /// Erreur accord manquant
  ///
  /// In fr, this message translates to:
  /// **'Votre accord est nécessaire pour utiliser le conseiller.'**
  String get agentErrorConsent;

  /// Erreur historique refusé
  ///
  /// In fr, this message translates to:
  /// **'La conversation a été recommencée : renvoyez votre question.'**
  String get agentErrorHistoryReset;

  /// Erreur inconnue
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get agentErrorGeneric;

  /// Texte de la demande d'accord
  ///
  /// In fr, this message translates to:
  /// **'Vos questions et les réponses sont conservées {days} jours pour améliorer le service, puis effacées. Elles sont traitées par Google (Gemini). N\'écrivez ni nom, ni numéro de téléphone, ni adresse. Vous pouvez effacer vos échanges à tout moment.'**
  String agentConsentBody(int days);

  /// Questions restantes
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Plus de question disponible aujourd\'hui} =1{1 question restante aujourd\'hui} other{{count} questions restantes aujourd\'hui}}'**
  String agentQuotaRemaining(int count);

  /// Résultat de l'effacement
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun échange à effacer} =1{1 échange effacé} other{{count} échanges effacés}}'**
  String agentDeleteHistoryDone(int count);

  /// Question dans le message au technicien
  ///
  /// In fr, this message translates to:
  /// **'Question : {question}'**
  String agentShareQuestion(String question);

  /// Réponse dans le message au technicien
  ///
  /// In fr, this message translates to:
  /// **'Réponse du conseiller : {answer}'**
  String agentShareAnswer(String answer);

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

  /// No description provided for @scanAskTechnician.
  ///
  /// In fr, this message translates to:
  /// **'Demander à un technicien'**
  String get scanAskTechnician;

  /// No description provided for @scanAskTechnicianMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, l\'application AgriMada n\'a pas pu identifier avec certitude le problème sur mon riz. Pouvez-vous regarder la photo ?'**
  String get scanAskTechnicianMessage;

  /// Maladies évoquées par le modèle, transmises au technicien
  ///
  /// In fr, this message translates to:
  /// **'Pistes de l\'application, non confirmées : {candidates}'**
  String scanAskTechnicianCandidates(String candidates);

  /// No description provided for @journalFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get journalFilterAll;

  /// No description provided for @journalFilterLastSevenDays.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get journalFilterLastSevenDays;

  /// No description provided for @journalFilterSevere.
  ///
  /// In fr, this message translates to:
  /// **'Plus d\'un tiers touché'**
  String get journalFilterSevere;

  /// No description provided for @journalFilterHealthy.
  ///
  /// In fr, this message translates to:
  /// **'Sains'**
  String get journalFilterHealthy;

  /// No description provided for @journalFilterEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune analyse ne correspond à ce filtre'**
  String get journalFilterEmpty;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone ou mot de passe incorrect'**
  String get errorInvalidCredentials;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez dans quelques minutes.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorPhoneAlreadyUsed.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro de téléphone a déjà un compte'**
  String get errorPhoneAlreadyUsed;

  /// No description provided for @errorInvalidData.
  ///
  /// In fr, this message translates to:
  /// **'Informations invalides. Vérifiez les champs.'**
  String get errorInvalidData;

  /// No description provided for @errorOffline.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet'**
  String get errorOffline;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur met trop de temps à répondre. Réessayez.'**
  String get errorTimeout;

  /// No description provided for @errorSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Reconnectez-vous pour synchroniser vos données'**
  String get errorSessionExpired;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a rencontré un problème. Réessayez plus tard.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get errorUnknown;

  /// No description provided for @syncErrorServerUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Serveur injoignable. Vérifiez la connexion ou l\'adresse du serveur.'**
  String get syncErrorServerUnreachable;

  /// No description provided for @syncErrorFailed.
  ///
  /// In fr, this message translates to:
  /// **'La synchronisation a échoué. Nouvel essai au retour du réseau.'**
  String get syncErrorFailed;

  /// No description provided for @resetPasswordRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Si ce numéro est associé à un compte, des instructions seront envoyées.'**
  String get resetPasswordRequestSent;

  /// No description provided for @journalStatusToConfirm.
  ///
  /// In fr, this message translates to:
  /// **'À confirmer'**
  String get journalStatusToConfirm;

  /// No description provided for @scanOrganTitle.
  ///
  /// In fr, this message translates to:
  /// **'Qu\'observez-vous ?'**
  String get scanOrganTitle;

  /// No description provided for @scanOrganHelp.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la partie de la plante que vous voulez photographier.'**
  String get scanOrganHelp;

  /// No description provided for @scanOrganModelNotice.
  ///
  /// In fr, this message translates to:
  /// **'Seules les feuilles sont analysées par le modèle. Pour les autres parties, vos réponses sont enregistrées et transmises à un technicien.'**
  String get scanOrganModelNotice;

  /// No description provided for @organLeaf.
  ///
  /// In fr, this message translates to:
  /// **'Feuilles'**
  String get organLeaf;

  /// No description provided for @organStemSheath.
  ///
  /// In fr, this message translates to:
  /// **'Tige et gaine'**
  String get organStemSheath;

  /// No description provided for @organCollar.
  ///
  /// In fr, this message translates to:
  /// **'Collet et base des tiges'**
  String get organCollar;

  /// No description provided for @organRoots.
  ///
  /// In fr, this message translates to:
  /// **'Racines'**
  String get organRoots;

  /// No description provided for @organPanicle.
  ///
  /// In fr, this message translates to:
  /// **'Panicule et grains'**
  String get organPanicle;

  /// No description provided for @organWholePlant.
  ///
  /// In fr, this message translates to:
  /// **'Plante entière ou parcelle'**
  String get organWholePlant;

  /// No description provided for @organUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Je ne sais pas'**
  String get organUnknown;

  /// No description provided for @organUnknownHint.
  ///
  /// In fr, this message translates to:
  /// **'L\'application vous guide : la parcelle, puis une feuille, puis le collet.'**
  String get organUnknownHint;

  /// No description provided for @photoQualityBlurred.
  ///
  /// In fr, this message translates to:
  /// **'Photo floue. Tenez le téléphone à deux mains, touchez l\'écran sur la plante pour faire le point, puis reprenez.'**
  String get photoQualityBlurred;

  /// No description provided for @photoQualityTooDark.
  ///
  /// In fr, this message translates to:
  /// **'Photo trop sombre. Cherchez un endroit plus éclairé ou attendez que le soleil monte.'**
  String get photoQualityTooDark;

  /// No description provided for @photoQualityTooBright.
  ///
  /// In fr, this message translates to:
  /// **'Photo trop claire. Évitez le plein soleil sur la feuille, cherchez une ombre légère.'**
  String get photoQualityTooBright;

  /// No description provided for @photoQualityBacklit.
  ///
  /// In fr, this message translates to:
  /// **'Le soleil est derrière la plante. Tournez-vous pour l\'avoir dans le dos.'**
  String get photoQualityBacklit;

  /// No description provided for @photoQualityGood.
  ///
  /// In fr, this message translates to:
  /// **'Photo nette.'**
  String get photoQualityGood;

  /// No description provided for @commonYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get commonNo;

  /// No description provided for @commonDontKnow.
  ///
  /// In fr, this message translates to:
  /// **'Je ne sais pas'**
  String get commonDontKnow;

  /// No description provided for @questionSinceWhen.
  ///
  /// In fr, this message translates to:
  /// **'Depuis combien de temps voyez-vous ce problème ?'**
  String get questionSinceWhen;

  /// No description provided for @questionSinceWhenDays.
  ///
  /// In fr, this message translates to:
  /// **'Moins d\'une semaine'**
  String get questionSinceWhenDays;

  /// No description provided for @questionSinceWhenWeeks.
  ///
  /// In fr, this message translates to:
  /// **'Une à trois semaines'**
  String get questionSinceWhenWeeks;

  /// No description provided for @questionSinceWhenMonth.
  ///
  /// In fr, this message translates to:
  /// **'Plus d\'un mois'**
  String get questionSinceWhenMonth;

  /// No description provided for @questionLeafShape.
  ///
  /// In fr, this message translates to:
  /// **'À quoi ressemblent les taches sur les feuilles ?'**
  String get questionLeafShape;

  /// No description provided for @questionLeafShapeBrownOval.
  ///
  /// In fr, this message translates to:
  /// **'Taches brunes ovales, éparpillées sur la feuille'**
  String get questionLeafShapeBrownOval;

  /// No description provided for @questionLeafShapeYellowEdge.
  ///
  /// In fr, this message translates to:
  /// **'Bandes gris-vert puis jaunes, à partir du bord ou de la pointe'**
  String get questionLeafShapeYellowEdge;

  /// No description provided for @questionLeafShapeBlackAngular.
  ///
  /// In fr, this message translates to:
  /// **'Petites taches noires anguleuses, un peu poudreuses'**
  String get questionLeafShapeBlackAngular;

  /// No description provided for @questionLeafShapeNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tache visible'**
  String get questionLeafShapeNone;

  /// No description provided for @questionLeafExudate.
  ///
  /// In fr, this message translates to:
  /// **'Le matin, voyez-vous des gouttes jaunes collantes sur les feuilles touchées ?'**
  String get questionLeafExudate;

  /// No description provided for @questionLeafSpread.
  ///
  /// In fr, this message translates to:
  /// **'Comment le problème se répand-il dans la parcelle ?'**
  String get questionLeafSpread;

  /// No description provided for @questionLeafSpreadFast.
  ///
  /// In fr, this message translates to:
  /// **'Vite, sur beaucoup de pieds en quelques jours'**
  String get questionLeafSpreadFast;

  /// No description provided for @questionLeafSpreadSlow.
  ///
  /// In fr, this message translates to:
  /// **'Lentement, quelques pieds seulement'**
  String get questionLeafSpreadSlow;

  /// No description provided for @questionStem.
  ///
  /// In fr, this message translates to:
  /// **'Que voyez-vous sur la tige ou la gaine ?'**
  String get questionStem;

  /// No description provided for @questionStemBrownPatches.
  ///
  /// In fr, this message translates to:
  /// **'Taches brunes allongées sur la gaine'**
  String get questionStemBrownPatches;

  /// No description provided for @questionStemSoft.
  ///
  /// In fr, this message translates to:
  /// **'Tige molle qui se casse au ras de l\'eau'**
  String get questionStemSoft;

  /// No description provided for @questionStemHoles.
  ///
  /// In fr, this message translates to:
  /// **'Trous ou galeries dans la tige'**
  String get questionStemHoles;

  /// No description provided for @questionCollar.
  ///
  /// In fr, this message translates to:
  /// **'Que voyez-vous à la base des tiges ?'**
  String get questionCollar;

  /// No description provided for @questionCollarChewed.
  ///
  /// In fr, this message translates to:
  /// **'Base rongée, plants qui se déchaussent'**
  String get questionCollarChewed;

  /// No description provided for @questionCollarRot.
  ///
  /// In fr, this message translates to:
  /// **'Pourriture noire au ras du sol'**
  String get questionCollarRot;

  /// No description provided for @questionCollarRing.
  ///
  /// In fr, this message translates to:
  /// **'Anneau brun autour du nœud'**
  String get questionCollarRing;

  /// No description provided for @questionRoots.
  ///
  /// In fr, this message translates to:
  /// **'À quoi ressemblent les racines ?'**
  String get questionRoots;

  /// No description provided for @questionRootsRusty.
  ///
  /// In fr, this message translates to:
  /// **'Racines brun-orangé, comme rouillées'**
  String get questionRootsRusty;

  /// No description provided for @questionRootsBlack.
  ///
  /// In fr, this message translates to:
  /// **'Racines noires et molles'**
  String get questionRootsBlack;

  /// No description provided for @questionRootsGalls.
  ///
  /// In fr, this message translates to:
  /// **'Petites boules sur les racines'**
  String get questionRootsGalls;

  /// No description provided for @questionPanicle.
  ///
  /// In fr, this message translates to:
  /// **'Que voyez-vous sur la panicule ?'**
  String get questionPanicle;

  /// No description provided for @questionPanicleWhite.
  ///
  /// In fr, this message translates to:
  /// **'Panicule blanche et vide'**
  String get questionPanicleWhite;

  /// No description provided for @questionPanicleStained.
  ///
  /// In fr, this message translates to:
  /// **'Grains tachés ou noircis'**
  String get questionPanicleStained;

  /// No description provided for @questionPanicleNeck.
  ///
  /// In fr, this message translates to:
  /// **'Cou de la panicule brun et cassant'**
  String get questionPanicleNeck;

  /// No description provided for @questionWholePlant.
  ///
  /// In fr, this message translates to:
  /// **'Comment se présente la parcelle ?'**
  String get questionWholePlant;

  /// No description provided for @questionWholePlantYellowPatches.
  ///
  /// In fr, this message translates to:
  /// **'Plants jaunis et rabougris, par taches dans la parcelle'**
  String get questionWholePlantYellowPatches;

  /// No description provided for @questionWholePlantDriedSpots.
  ///
  /// In fr, this message translates to:
  /// **'Foyers de plants desséchés'**
  String get questionWholePlantDriedSpots;

  /// No description provided for @questionWholePlantEvenYellow.
  ///
  /// In fr, this message translates to:
  /// **'Jaunissement régulier sur toute la parcelle'**
  String get questionWholePlantEvenYellow;

  /// No description provided for @scanOrganNoPlotNotice.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez scanner sans parcelle : vous la rattacherez après.'**
  String get scanOrganNoPlotNotice;

  /// No description provided for @captureHintLeaf.
  ///
  /// In fr, this message translates to:
  /// **'Approchez-vous d\'une feuille atteinte, bien à plat, la lumière dans votre dos.'**
  String get captureHintLeaf;

  /// No description provided for @captureHintStem.
  ///
  /// In fr, this message translates to:
  /// **'Tenez le téléphone à la verticale et cadrez la tige du bas vers le haut.'**
  String get captureHintStem;

  /// No description provided for @captureHintCollar.
  ///
  /// In fr, this message translates to:
  /// **'Écartez les feuilles pour montrer la base des tiges, au ras du sol.'**
  String get captureHintCollar;

  /// No description provided for @captureHintRoots.
  ///
  /// In fr, this message translates to:
  /// **'Déterrez un plant, rincez la terre et posez les racines sur un fond clair.'**
  String get captureHintRoots;

  /// No description provided for @captureHintPanicle.
  ///
  /// In fr, this message translates to:
  /// **'Cadrez une panicule entière, du cou jusqu\'aux grains.'**
  String get captureHintPanicle;

  /// No description provided for @captureHintWholePlant.
  ///
  /// In fr, this message translates to:
  /// **'Reculez pour montrer la parcelle et les endroits atteints.'**
  String get captureHintWholePlant;

  /// No description provided for @scanCaptureTake.
  ///
  /// In fr, this message translates to:
  /// **'Prendre la photo'**
  String get scanCaptureTake;

  /// No description provided for @scanCaptureAnother.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une autre photo'**
  String get scanCaptureAnother;

  /// No description provided for @scanCaptureContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get scanCaptureContinue;

  /// No description provided for @scanCapturePhotos.
  ///
  /// In fr, this message translates to:
  /// **'{count} photo(s) sur {max}'**
  String scanCapturePhotos(int count, int max);

  /// No description provided for @scanCameraUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu indisponible sur cet appareil : l\'appareil photo du téléphone s\'ouvrira.'**
  String get scanCameraUnavailable;

  /// No description provided for @scanQuestionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quelques questions'**
  String get scanQuestionsTitle;

  /// No description provided for @scanQuestionsHelp.
  ///
  /// In fr, this message translates to:
  /// **'Vos réponses partent avec les photos. Elles aident le technicien, même quand l\'application ne reconnaît rien.'**
  String get scanQuestionsHelp;

  /// No description provided for @scanSessionResultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résultat du scan'**
  String get scanSessionResultTitle;

  /// No description provided for @scanSessionNoName.
  ///
  /// In fr, this message translates to:
  /// **'L\'application ne nomme aucune maladie'**
  String get scanSessionNoName;

  /// No description provided for @scanSessionNoNameBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette partie de la plante n\'est pas analysée par le modèle. Vos photos et vos réponses sont enregistrées : montrez-les à un technicien.'**
  String get scanSessionNoNameBody;

  /// Session dont la photo a été analysée mais rien retenu : rejet pas_riz, trop peu de végétation ou résultat incertain (ADR-014)
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est peut-être pas du riz, ou la photo est floue ou mal éclairée. Aucune maladie n\'est retenue. Vos photos et vos réponses sont enregistrées : montrez-les à un technicien.'**
  String get scanSessionNotRecognizedBody;

  /// No description provided for @scanSessionPhotosSaved.
  ///
  /// In fr, this message translates to:
  /// **'{count} photo(s) enregistrée(s)'**
  String scanSessionPhotosSaved(int count);

  /// No description provided for @scanSessionAttachPlot.
  ///
  /// In fr, this message translates to:
  /// **'Rattacher à une parcelle'**
  String get scanSessionAttachPlot;

  /// No description provided for @scanSessionAttachPlotHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce scan n\'est rattaché à aucune parcelle.'**
  String get scanSessionAttachPlotHint;

  /// No description provided for @scanSessionAttached.
  ///
  /// In fr, this message translates to:
  /// **'Scan rattaché à la parcelle'**
  String get scanSessionAttached;

  /// No description provided for @scanSessionFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get scanSessionFinish;

  /// No description provided for @journalUnnamedResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat non nommé'**
  String get journalUnnamedResult;

  /// No description provided for @plotContextTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contexte de la parcelle'**
  String get plotContextTitle;

  /// No description provided for @plotContextOptional.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif, mais très utile au technicien.'**
  String get plotContextOptional;

  /// No description provided for @plotEcosystemLabel.
  ///
  /// In fr, this message translates to:
  /// **'Écosystème'**
  String get plotEcosystemLabel;

  /// No description provided for @ecosystemIrrigated.
  ///
  /// In fr, this message translates to:
  /// **'Irrigué'**
  String get ecosystemIrrigated;

  /// No description provided for @ecosystemLowland.
  ///
  /// In fr, this message translates to:
  /// **'Bas-fond'**
  String get ecosystemLowland;

  /// No description provided for @ecosystemUpland.
  ///
  /// In fr, this message translates to:
  /// **'Tanety (pluvial)'**
  String get ecosystemUpland;

  /// No description provided for @plotRegionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Région'**
  String get plotRegionLabel;

  /// No description provided for @plotAltitudeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Altitude'**
  String get plotAltitudeLabel;

  /// No description provided for @altitudeUnder800.
  ///
  /// In fr, this message translates to:
  /// **'Moins de 800 m'**
  String get altitudeUnder800;

  /// No description provided for @altitude800to1200.
  ///
  /// In fr, this message translates to:
  /// **'800 à 1200 m'**
  String get altitude800to1200;

  /// No description provided for @altitude1200to1500.
  ///
  /// In fr, this message translates to:
  /// **'1200 à 1500 m'**
  String get altitude1200to1500;

  /// No description provided for @altitudeOver1500.
  ///
  /// In fr, this message translates to:
  /// **'Plus de 1500 m'**
  String get altitudeOver1500;

  /// No description provided for @plotVarietyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Variété'**
  String get plotVarietyLabel;

  /// No description provided for @varietyLocalUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Locale ou inconnue'**
  String get varietyLocalUnknown;

  /// No description provided for @plotSeasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Saison'**
  String get plotSeasonLabel;

  /// No description provided for @seasonVaryAloha.
  ///
  /// In fr, this message translates to:
  /// **'Vary aloha (riz précoce)'**
  String get seasonVaryAloha;

  /// No description provided for @seasonMain.
  ///
  /// In fr, this message translates to:
  /// **'Saison des pluies'**
  String get seasonMain;

  /// No description provided for @seasonOffSeason.
  ///
  /// In fr, this message translates to:
  /// **'Contre-saison'**
  String get seasonOffSeason;

  /// No description provided for @plotTransplantDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de repiquage'**
  String get plotTransplantDateLabel;

  /// No description provided for @plotTransplantDateHint.
  ///
  /// In fr, this message translates to:
  /// **'Sert à situer le stade de la culture'**
  String get plotTransplantDateHint;

  /// No description provided for @plotTransplantDateChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la date'**
  String get plotTransplantDateChoose;

  /// No description provided for @plotSurfaceUnitHectare.
  ///
  /// In fr, this message translates to:
  /// **'hectares'**
  String get plotSurfaceUnitHectare;

  /// No description provided for @plotSurfaceUnitAre.
  ///
  /// In fr, this message translates to:
  /// **'ares'**
  String get plotSurfaceUnitAre;

  /// No description provided for @stageRecovery.
  ///
  /// In fr, this message translates to:
  /// **'Reprise après repiquage'**
  String get stageRecovery;

  /// No description provided for @stageTillering.
  ///
  /// In fr, this message translates to:
  /// **'Tallage'**
  String get stageTillering;

  /// No description provided for @stageStemElongation.
  ///
  /// In fr, this message translates to:
  /// **'Montaison'**
  String get stageStemElongation;

  /// No description provided for @stageHeading.
  ///
  /// In fr, this message translates to:
  /// **'Épiaison et floraison'**
  String get stageHeading;

  /// No description provided for @stageMaturity.
  ///
  /// In fr, this message translates to:
  /// **'Maturation'**
  String get stageMaturity;

  /// No description provided for @exportNoPlot.
  ///
  /// In fr, this message translates to:
  /// **'Sans parcelle'**
  String get exportNoPlot;

  /// No description provided for @journalPhotoCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} photo(s)'**
  String journalPhotoCount(int count);
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
