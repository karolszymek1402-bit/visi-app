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
}
