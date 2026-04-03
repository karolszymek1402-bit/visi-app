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
  String get btnNext => 'Next';

  @override
  String get tagline => 'Plan visits. Earn more.';

  @override
  String get loginEmail => 'Log in with email';

  @override
  String get createAccount => 'Create account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get or => 'OR';

  @override
  String get login => 'Log in';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage your visits';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get whatsYourName => 'What\'s your name?';

  @override
  String get hintName => 'e.g. Anna, Kari';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordRequired => 'Enter password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

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

  @override
  String get onboardingWelcome => 'Welcome to Visi!';

  @override
  String get onboardingSubtitle => 'Your personal visit planner';

  @override
  String get onboardingStep1Title => 'Plan your visits';

  @override
  String get onboardingStep1Desc =>
      'Add clients and schedule visits in the calendar. Set reminders so you never miss an appointment.';

  @override
  String get onboardingStep2Title => 'Track your earnings';

  @override
  String get onboardingStep2Desc =>
      'Set hourly rates per client. Visi automatically calculates your income and generates monthly reports.';

  @override
  String get onboardingStep3Title => 'Manage clients';

  @override
  String get onboardingStep3Desc =>
      'Keep notes, contact info and visit history. Send SMS reminders with one tap.';

  @override
  String get onboardingLetsGo => 'Let\'s go!';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStep4Title => 'One last step';

  @override
  String get onboardingStep4Desc =>
      'Your data is only visible to you and helps calculate earnings. You can change it anytime in Settings.';

  @override
  String get onboardingFinish => 'Done, let\'s start!';

  @override
  String get onboardingYourName => 'Your name';

  @override
  String get onboardingOptionalHint => '* Rate and location are optional';

  @override
  String get labelActualDuration => 'Actual duration';

  @override
  String get labelEarned => 'Earned';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOfflineHint => 'Changes saved locally';

  @override
  String get statusSyncing => 'Syncing...';

  @override
  String get statusSynced => 'Synced';

  @override
  String get authErrorOperationNotAllowed =>
      'Email sign-in is disabled. Contact the administrator.';

  @override
  String get authErrorEmailAlreadyInUse => 'This email is already registered.';

  @override
  String get authErrorWrongPassword => 'Incorrect password.';

  @override
  String get authErrorUserNotFound => 'No account found with this email.';

  @override
  String get authErrorTooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get authErrorNetworkRequestFailed => 'No internet connection.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorUnknown => 'Sign-in error. Please try again.';

  @override
  String get authErrorPopupClosed =>
      'Sign-in window was closed. Please try again.';

  @override
  String get authErrorPopupBlocked =>
      'Browser blocked the sign-in popup. Allow popups for this site.';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navClients => 'Clients';

  @override
  String get navFinance => 'Finance';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutTitle => 'Sign out';

  @override
  String get settingsSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get settingsName => 'Full name';

  @override
  String get settingsDefaultRate => 'Default rate (NOK/h)';

  @override
  String get settingsWorkLocation => 'Work location';
}
