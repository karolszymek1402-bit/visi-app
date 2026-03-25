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
  String get tagline => 'Planlegg besøk. Tjen mer.';

  @override
  String get loginEmail => 'Logg inn med e-post';

  @override
  String get createAccount => 'Opprett konto';

  @override
  String get continueWithGoogle => 'Fortsett med Google';

  @override
  String get or => 'ELLER';

  @override
  String get login => 'Logg inn';

  @override
  String get rememberMe => 'Husk meg';

  @override
  String get forgotPassword => 'Glemt passord';

  @override
  String get invalidEmail => 'Ugyldig e-post';

  @override
  String get passwordRequired => 'Skriv inn passord';

  @override
  String get passwordTooShort => 'Passordet må ha minst 8 tegn';

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
}
