// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Visi Planer';

  @override
  String get calendar => 'Calendar';

  @override
  String get finance => 'Finance';

  @override
  String get earnings => 'Earnings';

  @override
  String get total => 'Total';

  @override
  String get completeVisit => 'Complete Visit';

  @override
  String get save => 'Save';

  @override
  String get nok => 'NOK';

  @override
  String get clients => 'Clients';

  @override
  String setupProfileTitle(String name) {
    return 'Hi, $name!';
  }

  @override
  String setupProfileSubtitle(String location) {
    String _temp0 = intl.Intl.selectLogic(location, {
      'empty': '.',
      'other': ' in $location.',
    });
    return 'Welcome to visi. Let\'s set up your work$_temp0';
  }

  @override
  String get labelWorkLocation => 'Where do you usually work?';

  @override
  String get hintWorkLocation => 'e.g. Bergen, Oslo, Warsaw';

  @override
  String get labelHourlyRate => 'Default hourly rate (NOK)';

  @override
  String get hintHourlyRate => 'e.g. 250';

  @override
  String get errorInvalidRate => 'Please enter a valid hourly rate';

  @override
  String get labelSelectLanguage => 'Select language';

  @override
  String get langPolish => 'Polish';

  @override
  String get langNorwegian => 'Norwegian';

  @override
  String get langEnglish => 'English';

  @override
  String get btnGetStarted => 'Get started';
}
