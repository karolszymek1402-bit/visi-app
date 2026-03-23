// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Visi Planer';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get finance => 'Finanse';

  @override
  String get earnings => 'Zarobki';

  @override
  String get total => 'Razem';

  @override
  String get completeVisit => 'Zakończ wizytę';

  @override
  String get save => 'Zapisz';

  @override
  String get nok => 'NOK';

  @override
  String get clients => 'Klienci';

  @override
  String setupProfileTitle(String name) {
    return 'Hei, $name!';
  }

  @override
  String setupProfileSubtitle(String location) {
    String _temp0 = intl.Intl.selectLogic(location, {
      'empty': '.',
      'other': ' w $location.',
    });
    return 'Witaj w visi. Skonfigurujmy Twoją pracę$_temp0';
  }

  @override
  String get labelWorkLocation => 'Gdzie zazwyczaj pracujesz?';

  @override
  String get hintWorkLocation => 'np. Bergen, Oslo, Warszawa';

  @override
  String get labelHourlyRate => 'Domyślna stawka godzinowa (NOK)';

  @override
  String get hintHourlyRate => 'np. 250';

  @override
  String get errorInvalidRate => 'Wpisz poprawną stawkę';

  @override
  String get labelSelectLanguage => 'Wybierz język';

  @override
  String get langPolish => 'Polski';

  @override
  String get langNorwegian => 'Norweski';

  @override
  String get langEnglish => 'Angielski';

  @override
  String get btnGetStarted => 'Zaczynamy';
}
