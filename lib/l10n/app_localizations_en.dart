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

  @override
  String get tagline => 'Plan visits. Earn more.';

  @override
  String get loginEmail => 'Log in with email';

  @override
  String get createAccount => 'Create account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get or => 'OR';

  @override
  String get login => 'Log in';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordRequired => 'Enter password';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get resetPasswordPrompt => 'Enter email to reset password';

  @override
  String get resetPasswordSent => 'Password reset link sent to email';

  @override
  String errorSave(String error) {
    return 'Save error: $error';
  }

  @override
  String errorAuth(String error) {
    return 'Authentication error: $error';
  }

  @override
  String get clientsDatabase => 'Client Database';

  @override
  String get noClients => 'No clients';

  @override
  String get newClient => 'New client';

  @override
  String get editClient => 'Edit client';

  @override
  String get clientName => 'Client name';

  @override
  String get addressOptional => 'Address (optional)';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get smsMessageContent => 'Message to send';

  @override
  String get smsHint => 'Hi! Reminder about your appointment...';

  @override
  String get clientNote => 'Client note (optional)';

  @override
  String get clientNoteHint => 'E.g. Allergy to gel, favorite coffee...';

  @override
  String get rateNokH => 'Rate (NOK/h)';

  @override
  String get visitCycle => 'Visit cycle';

  @override
  String get oneWeek => '1 week';

  @override
  String get twoWeeks => '2 weeks';

  @override
  String workloadDays(int count) {
    return 'Workload: $count days/wk';
  }

  @override
  String get startTime => 'Start time';

  @override
  String get duration => 'Duration';

  @override
  String get invalidNameOrRate => 'Enter a name and valid rate';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteClient => 'Delete client';

  @override
  String deleteClientConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get today => 'Today';

  @override
  String get viewDay => 'View: day';

  @override
  String get viewWeek => 'View: week';

  @override
  String get viewMonth => 'View: month';

  @override
  String get moveVisit => 'Move visit';

  @override
  String get move => 'Move';

  @override
  String get disableReminder => 'Disable reminder';

  @override
  String get copyReport => 'Copy report';

  @override
  String get reportCopied => 'Report copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get hue => 'Hue';

  @override
  String get brightness => 'Brightness';

  @override
  String get monthProgress => 'Month progress';

  @override
  String get percentComplete => '% completed';

  @override
  String get clientBreakdown => 'Client breakdown';

  @override
  String get hoursReportPreview => 'Hours report preview';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String everyWeek(String days) {
    return 'Every week: $days';
  }

  @override
  String get addClient => 'Add client';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get clientColor => 'Client color';

  @override
  String get saturation => 'Saturation';

  @override
  String get chooseColor => 'Choose color';

  @override
  String get reminder => 'Reminder';

  @override
  String minBefore(int min) {
    return '$min min before';
  }

  @override
  String hourBefore(int hours) {
    return '$hours hour(s) before';
  }

  @override
  String get hoursReport => 'Work hours report';

  @override
  String get visits => 'visits';

  @override
  String everyNWeeks(int n, String days) {
    return 'Every $n wk: $days';
  }

  @override
  String get earned => 'Earned';

  @override
  String get planned => 'Planned';

  @override
  String get hours => 'Hours';

  @override
  String get daily => 'Every day';

  @override
  String everyNDays(int n) {
    return 'Every $n days';
  }
}
