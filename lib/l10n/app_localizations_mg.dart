// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get splashSubtitle => 'Mamorona aretina vary, tsy misy aterineto';

  @override
  String get loginForgotPasswordTitle => 'Hadino ny teny miafina ?';

  @override
  String get loginEmailLabel => 'Mailaka';

  @override
  String get loginEmailHint => 'anarana@ohatra.com';

  @override
  String get loginEmailRequired => 'Ampidiro azafady ny mailakao';

  @override
  String get loginEmailInvalid => 'Mailaka tsy manan-kery';

  @override
  String get commonCancel => 'Hanafoana';

  @override
  String get commonSend => 'Alefa';

  @override
  String get featureComingSoon => 'Tsy ho ela dia ho azo ampiasaina';

  @override
  String get registerComingSoon => 'Fisoratana anarana tsy ho ela';

  @override
  String get loginTitle => 'Fidirana';

  @override
  String get loginPasswordLabel => 'Teny miafina';

  @override
  String get loginPasswordRequired => 'Ampidiro azafady ny teny miafina';

  @override
  String get loginForgotPassword => 'Hadino ny teny miafina ?';

  @override
  String get loginSubmit => 'Hiditra';

  @override
  String get loginNoAccount => 'Tsy mbola manana kaonty ?';

  @override
  String get loginRegister => 'Hisoratra anarana';

  @override
  String get loginHello => 'Miarahaba !';

  @override
  String get loginWelcome => 'Tongasoa eto amin\'ny AgriMada';

  @override
  String get welcomeHeadline => 'Ny faharanitan-tsaina ho an\'ny tanimbary';

  @override
  String get welcomeBody =>
      'Vary salama sy voaaro miaraka amin\'ny fahaiza-manaon\'i AgriMada.';

  @override
  String get welcomeStart => 'Hanomboka';

  @override
  String get homeSoonMessage => 'Tsy ho ela dia ho tonga';

  @override
  String get homeServicesTitle => 'Tolotra';

  @override
  String get homeMenuSemantics => 'Hanokatra menio';

  @override
  String homeHelloUser(String name) {
    return 'Miarahaba, $name!';
  }

  @override
  String get homeFarmerDefault => 'Mpamboly';

  @override
  String get homeReadyForAnalysis => 'Vonona hanao fanadihadiana ?';

  @override
  String get homeOfflineMode => 'Fomba ivelan\'ny tambajotra';

  @override
  String get homeSearchPlaceholder => 'mitady...';

  @override
  String get homeSummaryTitle => 'Topi-maso ny toeram-pamokaranao';

  @override
  String get homeSystemReady => 'Vonona ny rafitra';

  @override
  String homeRegisteredPlots(int count) {
    return '$count tanim-bary voasoratra';
  }

  @override
  String get homeServicePlotsTitle => 'Tanimbary';

  @override
  String get homeServicePlotsDescription =>
      'Araho ny tanimbary, ny velarana volena ary ny sata ara-pahasalamany';

  @override
  String get homeServiceCropsTitle => 'Satan\'ny voly';

  @override
  String get homeServiceCropsDescription =>
      'Jereo ny sata ankapobeny sy ny haavon\'ny loza amin\'izao fotoana';

  @override
  String get homeServiceSolutionsTitle => 'Vahaolana ara-pambolena';

  @override
  String get homeServiceSolutionsDescription =>
      'Fantaro ireo fitsaboana biolojika sy vahaolana eo an-toerana soso-kevitra';

  @override
  String get homeServicePreventionTitle => 'Fisorohana aretina';

  @override
  String get homeServicePreventionDescription =>
      'Ianaro ny fanao tsara hiarovana ny tanimbary sy hisorohana fatiantoka';

  @override
  String get homeScanPlantSemantics => 'Hanadihady zavamaniry';

  @override
  String get homeTabHome => 'Fandraisana';

  @override
  String get homeTabJournal => 'Boky';

  @override
  String get scanIaUnavailable =>
      'Tsy misy ny diagnostika IA, andramo indray azafady';

  @override
  String get scanSelectPlot => 'Hisafidy parcelle (parcelle)';

  @override
  String get scanNoPlotTitle => 'Tsy misy parcelle (parcelle)';

  @override
  String get scanNoPlotDescription =>
      'Mamorona parcelle (parcelle) aloha ao amin\'ny boky ara-pambolena vao manao scan.';

  @override
  String get commonOk => 'OK';

  @override
  String get scanGoToJournal => 'Handeha any amin\'ny boky';

  @override
  String get scanLoading => 'Mandeha ny fanadihadiana...';

  @override
  String get scanPointCamera => 'Tondroy ny fakan-tsary\namin\'ny ravin-bary';

  @override
  String get scanOfflineAnalysis => 'Atao eto an-toerana ny fanadihadiana';

  @override
  String get scanHeaderTitle => 'Hijery ravina';

  @override
  String get scanCancel => 'HANAFOANA';

  @override
  String get scanResultSaveFailed => 'Tsy afaka mitahiry ny diagnostika';

  @override
  String get scanResultSaved => 'Voatahiry ny diagnostika';

  @override
  String get scanResultBackSemantics => 'Miverina';

  @override
  String get scanResultTitle => 'Vokatry ny fanadihadiana';

  @override
  String get scanResultSubtitle =>
      'Vita ny fanadihadiana ivelan\'ny tambajotra';

  @override
  String get diseaseBacterialLeafBlight =>
      'May bakteria amin\'ny ravina (Brulure bacterienne)';

  @override
  String get diseaseBrownSpot => 'Tasy volontany (Tache brune)';

  @override
  String get diseaseLeafSmut => 'Arina amin\'ny ravina (Charbon foliaire)';

  @override
  String get diseaseHealthy => 'Zavamaniry salama';

  @override
  String scanResultConfidence(String value) {
    return '$value% fitokisana';
  }

  @override
  String get scanShareTitle => 'Diagnostika AgriMada';

  @override
  String get scanShareCulture => 'Voly: Vary';

  @override
  String scanShareDisease(String disease) {
    return 'Aretina: $disease';
  }

  @override
  String scanShareConfidence(String value) {
    return 'Fitokisana: $value%';
  }

  @override
  String scanShareDate(String date) {
    return 'Daty: $date';
  }

  @override
  String get scanSeverityTitle => 'Haavon\'ny hamafin\'ny aretina';

  @override
  String get scanSeverityLow => 'Ambany';

  @override
  String get scanSeverityMedium => 'Antonony';

  @override
  String get scanSeverityHigh => 'Avo';

  @override
  String get scanSeverityNoneStatus => 'Tsy misy - Zavamaniry salama';

  @override
  String get scanSeverityLowStatus => 'Ambany - Araho maso';

  @override
  String get scanSeverityMediumStatus =>
      'Antonony - Mila fandraisana andraikitra';

  @override
  String get scanSeverityHighStatus => 'Avo - Mila vonjy maika';

  @override
  String get scanRecommendationsTitle => 'Soso-kevitra mifanaraka';

  @override
  String get scanRecommendationItemTitle => 'Soso-kevitra';

  @override
  String get scanRecBlbEvacuateWater =>
      'Avoahy ny rano ao amin\'ny tanimbary misy aretina';

  @override
  String get scanRecBlbApplyCopper => 'Ampiharo hydroxyde de cuivre (2-3 g/L)';

  @override
  String get scanRecBlbAvoidNitrogen => 'Hialao ny azota be loatra';

  @override
  String get scanRecBlbUseResistantVarieties =>
      'Ampiasao karazana vary mafy orina amin\'ny fiainana manaraka';

  @override
  String get scanRecBrownSpotFertilize =>
      'Hamafiso ny fanatsarana ny fertilisation (potassium)';

  @override
  String get scanRecBrownSpotApplyFungicide =>
      'Ampiharo fongicide mifototra amin\'ny mancozèbe';

  @override
  String get scanRecBrownSpotDrainage => 'Antoka ny drainage tsara';

  @override
  String get scanRecBrownSpotAvoidStress => 'Hialao ny stress hydrique';

  @override
  String get scanRecLeafSmutTreatSeeds =>
      'Tsabohy ny voan-bary alohan\'ny fambolena';

  @override
  String get scanRecLeafSmutApplyFungicide => 'Ampiharo fongicide systémique';

  @override
  String get scanRecLeafSmutRemovePlants =>
      'Esory ary doavy ny zavamaniry misy aretina';

  @override
  String get scanRecLeafSmutRotation => 'Soso-kevitr\'ny fihodinana voly';

  @override
  String get scanRecHealthy =>
      'Zavamaniry salama. Tohizy ny fanao tsara amin\'ny fambolena.';

  @override
  String get scanTip =>
      'Torohevitra : aza manondraka be loatra mandritra ny 3 andro';

  @override
  String get scanRescanSemantics => 'Hanao scan indray';

  @override
  String get scanRescan => 'Hanao scan indray';

  @override
  String get scanSaveJournalSemantics => 'Hotehirizina ao amin\'ny boky';

  @override
  String get commonSave => 'Tehirizo';

  @override
  String get scanShareSemantics => 'Hizara ny vokatra';

  @override
  String get scanShare => 'Hizara ny vokatra';

  @override
  String journalError(String error) {
    return 'Hadisoana: $error';
  }

  @override
  String get journalNewPlot => 'Parcelle vaovao (parcelle)';

  @override
  String get journalTitle => 'Boky ara-pambolena';

  @override
  String get journalSubtitle => 'Fanaraha-maso ny parcelle (parcelle)';

  @override
  String get journalTotal => 'Fitambarany';

  @override
  String get journalHealthyPlural => 'Salama';

  @override
  String get journalSickPlural => 'Marary';

  @override
  String get journalStatusSick => 'Marary';

  @override
  String get journalStatusHealthy => 'Salama';

  @override
  String get journalStatusNotAnalyzed => 'Tsy nohadihadiana';

  @override
  String journalAreaHa(String surface) {
    return '$surface ha';
  }

  @override
  String journalAnalysesCount(int count) {
    return 'Fanadihadiana $count';
  }

  @override
  String journalLastDiagnostic(String disease, String date) {
    return 'Farany : $disease - $date';
  }

  @override
  String get journalScan => 'Hijery';

  @override
  String get journalNoDiagnosticYet => 'Tsy mbola misy diagnostika';

  @override
  String get journalScanNow => 'Hijery izao';

  @override
  String get journalEmptyTitle => 'Tsy misy parcelle (parcelle)';

  @override
  String get journalEmptyDescription =>
      'Ampio ny parcelle (parcelle) voalohany\nhanombohana ny fanaraha-maso.';

  @override
  String get journalAddPlot => 'Hanampy parcelle (parcelle)';

  @override
  String get journalPlotNameLabel => 'Anaran\'ny parcelle (parcelle) *';

  @override
  String get journalDescriptionOptional => 'Fanazavana (tsy voatery)';

  @override
  String get journalSurfaceOptional => 'Velarana (ha, tsy voatery)';

  @override
  String get journalNameRequired => 'Ilaina ny anarana';

  @override
  String get registerTitle => 'Mamorona kaonty';

  @override
  String get registerHeadline => 'Fisoratana anarana mpamboly';

  @override
  String get registerDescription =>
      'Fenoy ny mombamomba anao mba hamoronana fidirana.';

  @override
  String get registerNameLabel => 'Anarana';

  @override
  String get registerFirstNameLabel => 'Fanampin\'anarana';

  @override
  String get registerRegionLabel => 'Faritra';

  @override
  String get registerPhoneLabel => 'Finday';

  @override
  String get registerPasswordLabel => 'Teny miafina';

  @override
  String get registerSubmit => 'Hamorona kaontiko';

  @override
  String get registerAlreadyAccount => 'Efa manana kaonty aho';

  @override
  String get registerSuccess => 'Vita ny fisoratana anarana';

  @override
  String get validationRequired => 'Tsy maintsy fenoina';

  @override
  String get validationPhoneInvalid => 'Tsy mety ny laharana';

  @override
  String get validationPasswordMin => 'Farafahakeliny tarehintsoratra 6';

  @override
  String get resetTitle => 'Hadino ny teny miafina';

  @override
  String get resetHeadline => 'Avereno ny teny miafina';

  @override
  String get resetDescription =>
      'Ampidiro ny laharan-telefaoninao hahazoana toromarika.';

  @override
  String get resetBackToLogin => 'Hiverina amin\'ny fidirana';

  @override
  String get resetSuccessMessage =>
      'Raha mifandray amin\'ny kaonty io laharana io dia halefa ny toromarika.';

  @override
  String get splashInitializing => 'Eo am-piomanana...';

  @override
  String get splashPartialInit => 'Fiomanana ampahany, fomba mihena.';

  @override
  String get splashAiReady => 'Vonona ny IA';

  @override
  String get splashAiUnavailable => 'Tsy misy IA';

  @override
  String get splashSessionActive => 'Session mavitrika';

  @override
  String get splashSessionGuest => 'Session vahiny';

  @override
  String splashStatus(String mode, String session) {
    return '$mode • $session';
  }

  @override
  String welcomeGreeting(String name) {
    return 'Miarahaba $name';
  }

  @override
  String get welcomeAiReady => 'Vonona ny IA ivelan\'ny aterineto';

  @override
  String get welcomeAiUnavailable => 'Fomba mihena tsy misy IA';

  @override
  String welcomeAiModelStatus(String status, String version) {
    return '$status • Modely v$version';
  }

  @override
  String get onboardingSlide1Title => 'Alaivo sary ny ravina marary';

  @override
  String get onboardingSlide1Description =>
      'Ataovy ao anaty efijery ny ravina. Tazomy 20-30 sm ary hazavana voajanahary tsara.';

  @override
  String get onboardingSlide2Title => 'Manadihady ivelan\'ny aterineto ny IA';

  @override
  String get onboardingSlide2Description =>
      'Tsy mila internet. Miasa mivantana amin\'ny findainao ny diagnostika.';

  @override
  String get onboardingSlide3Title => 'Jereo ny diagnostika';

  @override
  String get onboardingSlide3Description =>
      'Jereo ny hamafin\'ny aretina, ny fitokisana ary ny soso-kevitra mifanaraka.';

  @override
  String get onboardingSlide4Title => 'Araho ny parcelle-nao';

  @override
  String get onboardingSlide4Description =>
      'Jereo ao amin\'ny journal agricole ny tantaran\'ny fanadihadiana isaky ny parcelle.';

  @override
  String get onboardingNext => 'Manaraka';

  @override
  String get onboardingClose => 'Akatona';

  @override
  String get onboardingSkip => 'Hitsambikina';

  @override
  String get onboardingHelpTitle => 'Fanampiana AgriMada';

  @override
  String get onboardingWelcomeTitle => 'Tongasoa';

  @override
  String get onboardingModelVersionTitle => 'Kinovan\'ny modely IA';

  @override
  String onboardingSupportedDiseases(String diseases) {
    return 'Aretina tohanana: $diseases';
  }

  @override
  String get onboardingAppStatusTitle => 'Satan\'ny rindranasa';

  @override
  String get onboardingAiAvailable => 'Misy IA amin\'ity fitaovana ity';

  @override
  String get onboardingAiUnavailable => 'Tsy misy IA, fomba mihena';

  @override
  String onboardingActiveVersion(String version) {
    return 'Kinova miasa: v$version';
  }
}
