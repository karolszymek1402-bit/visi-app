// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Visi Plan';

  @override
  String get calendar => 'Kalender';

  @override
  String get finance => 'Økonomi';

  @override
  String get earnings => 'Inntekt';

  @override
  String get total => 'Totalt';

  @override
  String get completeVisit => 'Fullfør besøk';

  @override
  String get save => 'Lagre';

  @override
  String get nok => 'kr';

  @override
  String get clients => 'Klienter';

  @override
  String setupProfileTitle(String name) {
    return 'Hei, $name!';
  }

  @override
  String setupProfileSubtitle(String location) {
    String _temp0 = intl.Intl.selectLogic(location, {
      'empty': '.',
      'other': ' i $location.',
    });
    return 'Velkommen til visi. La oss sette opp jobben din$_temp0';
  }

  @override
  String get labelWorkLocation => 'Hvor jobber du vanligvis?';

  @override
  String get hintWorkLocation => 'f.eks. Bergen, Oslo, Warszawa';

  @override
  String get labelHourlyRate => 'Standard timepris (NOK)';

  @override
  String get hintHourlyRate => 'f.eks. 250';

  @override
  String get errorInvalidRate => 'Vennligst skriv inn en gyldig timepris';

  @override
  String get labelSelectLanguage => 'Velg språk';

  @override
  String get langPolish => 'Polsk';

  @override
  String get langNorwegian => 'Norsk';

  @override
  String get langEnglish => 'Engelsk';

  @override
  String get btnGetStarted => 'Kom i gang';

  @override
  String get btnNext => 'Neste';

  @override
  String get tagline => 'Planlegg besøk. Tjen mer.';

  @override
  String get loginEmail => 'Logg inn med e-post';

  @override
  String get createAccount => 'Opprett konto';

  @override
  String get continueWithGoogle => 'Fortsett med Google';

  @override
  String get signingIn => 'Logger inn...';

  @override
  String get or => 'ELLER';

  @override
  String get login => 'Logg inn';

  @override
  String get welcomeBack => 'Velkommen tilbake';

  @override
  String get loginSubtitle => 'Logg inn for å administrere besøkene dine';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Passord';

  @override
  String get confirmPassword => 'Bekreft passord';

  @override
  String get rememberMe => 'Husk meg';

  @override
  String get forgotPassword => 'Glemt passord?';

  @override
  String get whatsYourName => 'Hva heter du?';

  @override
  String get hintName => 'f.eks. Anna, Kari';

  @override
  String get saveProfile => 'Lagre profil';

  @override
  String get invalidEmail => 'Ugyldig e-post';

  @override
  String get passwordRequired => 'Skriv inn passord';

  @override
  String get passwordTooShort => 'Passordet må ha minst 6 tegn';

  @override
  String get passwordsDoNotMatch => 'Passordene stemmer ikke overens';

  @override
  String get resetPasswordPrompt =>
      'Skriv inn e-post for å tilbakestille passord';

  @override
  String get resetPasswordSent =>
      'Link for tilbakestilling av passord sendt til e-post';

  @override
  String errorSave(String error) {
    return 'Lagringsfeil: $error';
  }

  @override
  String errorAuth(String error) {
    return 'Autentiseringsfeil: $error';
  }

  @override
  String get clientsDatabase => 'Klientdatabase';

  @override
  String get noClients => 'Ingen klienter';

  @override
  String get newClient => 'Ny klient';

  @override
  String get editClient => 'Rediger klient';

  @override
  String get clientName => 'Klientnavn';

  @override
  String get addressOptional => 'Adresse (valgfritt)';

  @override
  String get phoneNumber => 'Telefonnummer';

  @override
  String get smsMessageContent => 'Meldingsinnhold å sende';

  @override
  String get smsHint => 'Hei! Påminnelse om timen din...';

  @override
  String get clientNote => 'Notat om klient (valgfritt)';

  @override
  String get clientNoteHint => 'F.eks. Allergi mot gel, favorittkaffe...';

  @override
  String get rateNokH => 'Timepris (NOK/t)';

  @override
  String get visitCycle => 'Besøkssyklus';

  @override
  String get oneWeek => '1 uke';

  @override
  String get twoWeeks => '2 uker';

  @override
  String workloadDays(int count) {
    return 'Arbeidsmengde: $count dager/uke';
  }

  @override
  String get startTime => 'Starttid';

  @override
  String get duration => 'Varighet';

  @override
  String get invalidNameOrRate => 'Skriv inn navn og gyldig pris';

  @override
  String get delete => 'Slett';

  @override
  String get cancel => 'Avbryt';

  @override
  String get deleteClient => 'Slett klient';

  @override
  String deleteClientConfirm(String name) {
    return 'Er du sikker på at du vil slette \"$name\"?';
  }

  @override
  String get today => 'I dag';

  @override
  String get viewDay => 'Visning: dag';

  @override
  String get viewWeek => 'Visning: uke';

  @override
  String get viewMonth => 'Visning: måned';

  @override
  String get moveVisit => 'Flytt besøk';

  @override
  String get move => 'Flytt';

  @override
  String get disableReminder => 'Deaktiver påminnelse';

  @override
  String get copyReport => 'Kopier rapport';

  @override
  String get reportCopied => 'Rapport kopiert til utklippstavle';

  @override
  String get copy => 'Kopier';

  @override
  String get hue => 'Fargetone';

  @override
  String get brightness => 'Lysstyrke';

  @override
  String get monthProgress => 'Månedsfremdrift';

  @override
  String get percentComplete => '% fullført';

  @override
  String get clientBreakdown => 'Klientfordeling';

  @override
  String get hoursReportPreview => 'Forhåndsvisning av timerapport';

  @override
  String get dayMon => 'Ma';

  @override
  String get dayTue => 'Ti';

  @override
  String get dayWed => 'On';

  @override
  String get dayThu => 'To';

  @override
  String get dayFri => 'Fr';

  @override
  String get daySat => 'Lø';

  @override
  String get daySun => 'Sø';

  @override
  String everyWeek(String days) {
    return 'Hver uke: $days';
  }

  @override
  String get addClient => 'Legg til klient';

  @override
  String get saveChanges => 'Lagre endringer';

  @override
  String get clientColor => 'Klientfarge';

  @override
  String get saturation => 'Metning';

  @override
  String get chooseColor => 'Velg farge';

  @override
  String get reminder => 'Påminnelse';

  @override
  String minBefore(int min) {
    return '$min min før';
  }

  @override
  String hourBefore(int hours) {
    return '$hours time(r) før';
  }

  @override
  String get hoursReport => 'Arbeidstidsrapport';

  @override
  String get visits => 'besøk';

  @override
  String everyNWeeks(int n, String days) {
    return 'Hver $n. uke: $days';
  }

  @override
  String get earned => 'Opptjent';

  @override
  String get planned => 'Planlagt';

  @override
  String get hours => 'Timer';

  @override
  String get daily => 'Daglig';

  @override
  String everyNDays(int n) {
    return 'Hver $n. dag';
  }

  @override
  String get onboardingWelcome => 'Velkommen til Visi!';

  @override
  String get onboardingSubtitle => 'Din personlige besøksplanlegger';

  @override
  String get onboardingStep1Title => 'Planlegg besøk';

  @override
  String get onboardingStep1Desc =>
      'Legg til klienter og planlegg besøk i kalenderen. Sett påminnelser så du aldri går glipp av en avtale.';

  @override
  String get onboardingStep2Title => 'Følg inntektene';

  @override
  String get onboardingStep2Desc =>
      'Sett timepris per klient. Visi beregner automatisk inntektene dine og genererer månedsrapporter.';

  @override
  String get onboardingStep3Title => 'Administrer klienter';

  @override
  String get onboardingStep3Desc =>
      'Lagre notater, kontaktinfo og besøkshistorikk. Send påminnelses-SMS med ett trykk.';

  @override
  String get onboardingLetsGo => 'La oss begynne!';

  @override
  String get onboardingSkip => 'Hopp over';

  @override
  String get onboardingStep4Title => 'Siste steg';

  @override
  String get onboardingStep4Desc =>
      'Dataene dine er bare synlige for deg og hjelper med å beregne inntektene. Du kan endre dem når som helst i innstillingene.';

  @override
  String get onboardingFinish => 'Ferdig, la oss starte!';

  @override
  String get onboardingYourName => 'Ditt navn';

  @override
  String get onboardingOptionalHint => '* Timepris og sted er valgfritt';

  @override
  String get labelActualDuration => 'Faktisk varighet';

  @override
  String get labelEarned => 'Inntekt';

  @override
  String get statusOffline => 'Frakoblet';

  @override
  String get statusOfflineHint => 'Endringer lagres lokalt';

  @override
  String get statusSyncing => 'Synkroniserer...';

  @override
  String get statusSynced => 'Synkronisert';

  @override
  String get authErrorOperationNotAllowed =>
      'E-postinnlogging er deaktivert. Kontakt administratoren.';

  @override
  String get authErrorEmailAlreadyInUse =>
      'Denne e-posten er allerede registrert.';

  @override
  String get authErrorWrongPassword => 'Feil passord.';

  @override
  String get authErrorUserNotFound => 'Ingen konto funnet med denne e-posten.';

  @override
  String get authErrorTooManyRequests => 'For mange forsøk. Prøv igjen senere.';

  @override
  String get authErrorNetworkRequestFailed => 'Ingen internettforbindelse.';

  @override
  String get authErrorUserDisabled => 'Denne kontoen er deaktivert.';

  @override
  String get authErrorUnknown => 'Innloggingsfeil. Prøv igjen.';

  @override
  String get authErrorPopupClosed =>
      'Innloggingsvinduet ble lukket. Prøv igjen.';

  @override
  String get authErrorPopupBlocked =>
      'Nettleseren blokkerte innloggingsvinduet. Tillat popup-vinduer for dette nettstedet.';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navClients => 'Klienter';

  @override
  String get navFinance => 'Økonomi';

  @override
  String get navSettings => 'Innstillinger';

  @override
  String get settingsTitle => 'Innstillinger';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsAppearance => 'Utseende';

  @override
  String get settingsLanguage => 'Språk';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Lyst';

  @override
  String get settingsThemeDark => 'Mørkt';

  @override
  String get settingsSignOut => 'Logg ut';

  @override
  String get settingsSignOutTitle => 'Logg ut';

  @override
  String get settingsSignOutConfirm => 'Er du sikker på at du vil logge ut?';

  @override
  String get settingsSaved => 'Lagret';

  @override
  String get settingsName => 'Fullt navn';

  @override
  String get settingsDefaultRate => 'Standard timepris (NOK/t)';

  @override
  String get settingsWorkLocation => 'Arbeidssted';

  @override
  String get financeTitle => 'Økonomi';

  @override
  String get currentBalance => 'Nåværende saldo';

  @override
  String get addTransaction => 'Legg til transaksjon';

  @override
  String get transactionIncome => 'Inntekt';

  @override
  String get transactionExpense => 'Utgift';

  @override
  String get amountRequired => 'Beløpet må være et positivt tall';

  @override
  String get categoryRequired => 'Kategori er påkrevd';

  @override
  String deleteTransactionConfirm(String category) {
    return 'Slette transaksjon \"$category\"?';
  }

  @override
  String get financeAmountLabel => 'Beløp';

  @override
  String get financeTypeLabel => 'Type';

  @override
  String get financeCategoryLabel => 'Kategori';

  @override
  String get financeNoteLabel => 'Notat';

  @override
  String get financeOptional => 'Valgfritt';

  @override
  String get financeAmountHint => 'f.eks. 1250,00';

  @override
  String get financeCategoryHint => 'f.eks. Besøk, Drivstoff, Utstyr';

  @override
  String get financeSaving => 'Lagrer...';

  @override
  String financeSaveFailed(String error) {
    return 'Lagring feilet: $error';
  }

  @override
  String financeDeleteFailed(String error) {
    return 'Sletting feilet: $error';
  }

  @override
  String financeLoadFailed(String error) {
    return 'Kunne ikke laste transaksjoner: $error';
  }

  @override
  String get financeEmptyState =>
      'Ingen transaksjoner ennå. Trykk + for å legge til.';

  @override
  String get financeCurrency => 'kr';

  @override
  String financeAmountWithCurrency(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String get financeLinkedToVisit => 'Koblet til besøk';

  @override
  String get financeCreateFromVisit => 'Gjør opp besøk';
}
