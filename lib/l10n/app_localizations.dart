import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_pl.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('nb'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Visi Planer'**
  String get appTitle;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @completeVisit.
  ///
  /// In en, this message translates to:
  /// **'Complete Visit'**
  String get completeVisit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @nok.
  ///
  /// In en, this message translates to:
  /// **'NOK'**
  String get nok;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String setupProfileTitle(String name);

  /// Subtitle with optional location
  ///
  /// In en, this message translates to:
  /// **'Welcome to visi. Let\'s set up your work{location, select, empty{.} other{ in {location}.}}'**
  String setupProfileSubtitle(String location);

  /// No description provided for @labelWorkLocation.
  ///
  /// In en, this message translates to:
  /// **'Where do you usually work?'**
  String get labelWorkLocation;

  /// No description provided for @hintWorkLocation.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bergen, Oslo, Warsaw'**
  String get hintWorkLocation;

  /// No description provided for @labelHourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Default hourly rate (NOK)'**
  String get labelHourlyRate;

  /// No description provided for @hintHourlyRate.
  ///
  /// In en, this message translates to:
  /// **'e.g. 250'**
  String get hintHourlyRate;

  /// No description provided for @errorInvalidRate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid hourly rate'**
  String get errorInvalidRate;

  /// No description provided for @labelSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get labelSelectLanguage;

  /// No description provided for @langPolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get langPolish;

  /// No description provided for @langNorwegian.
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get langNorwegian;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @btnGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get btnGetStarted;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Plan visits. Earn more.'**
  String get tagline;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Log in with email'**
  String get loginEmail;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your visits'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @whatsYourName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get whatsYourName;

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Anna, Kari'**
  String get hintName;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter email to reset password'**
  String get resetPasswordPrompt;

  /// No description provided for @resetPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to email'**
  String get resetPasswordSent;

  /// No description provided for @errorSave.
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String errorSave(String error);

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {error}'**
  String errorAuth(String error);

  /// No description provided for @clientsDatabase.
  ///
  /// In en, this message translates to:
  /// **'Client Database'**
  String get clientsDatabase;

  /// No description provided for @noClients.
  ///
  /// In en, this message translates to:
  /// **'No clients'**
  String get noClients;

  /// No description provided for @newClient.
  ///
  /// In en, this message translates to:
  /// **'New client'**
  String get newClient;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit client'**
  String get editClient;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client name'**
  String get clientName;

  /// No description provided for @addressOptional.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get addressOptional;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @smsMessageContent.
  ///
  /// In en, this message translates to:
  /// **'Message to send'**
  String get smsMessageContent;

  /// No description provided for @smsHint.
  ///
  /// In en, this message translates to:
  /// **'Hi! Reminder about your appointment...'**
  String get smsHint;

  /// No description provided for @clientNote.
  ///
  /// In en, this message translates to:
  /// **'Client note (optional)'**
  String get clientNote;

  /// No description provided for @clientNoteHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Allergy to gel, favorite coffee...'**
  String get clientNoteHint;

  /// No description provided for @rateNokH.
  ///
  /// In en, this message translates to:
  /// **'Rate (NOK/h)'**
  String get rateNokH;

  /// No description provided for @visitCycle.
  ///
  /// In en, this message translates to:
  /// **'Visit cycle'**
  String get visitCycle;

  /// No description provided for @oneWeek.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get oneWeek;

  /// No description provided for @twoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 weeks'**
  String get twoWeeks;

  /// No description provided for @workloadDays.
  ///
  /// In en, this message translates to:
  /// **'Workload: {count} days/wk'**
  String workloadDays(int count);

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @invalidNameOrRate.
  ///
  /// In en, this message translates to:
  /// **'Enter a name and valid rate'**
  String get invalidNameOrRate;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteClient.
  ///
  /// In en, this message translates to:
  /// **'Delete client'**
  String get deleteClient;

  /// No description provided for @deleteClientConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteClientConfirm(String name);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @viewDay.
  ///
  /// In en, this message translates to:
  /// **'View: day'**
  String get viewDay;

  /// No description provided for @viewWeek.
  ///
  /// In en, this message translates to:
  /// **'View: week'**
  String get viewWeek;

  /// No description provided for @viewMonth.
  ///
  /// In en, this message translates to:
  /// **'View: month'**
  String get viewMonth;

  /// No description provided for @moveVisit.
  ///
  /// In en, this message translates to:
  /// **'Move visit'**
  String get moveVisit;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @disableReminder.
  ///
  /// In en, this message translates to:
  /// **'Disable reminder'**
  String get disableReminder;

  /// No description provided for @copyReport.
  ///
  /// In en, this message translates to:
  /// **'Copy report'**
  String get copyReport;

  /// No description provided for @reportCopied.
  ///
  /// In en, this message translates to:
  /// **'Report copied to clipboard'**
  String get reportCopied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hue;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @monthProgress.
  ///
  /// In en, this message translates to:
  /// **'Month progress'**
  String get monthProgress;

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'% completed'**
  String get percentComplete;

  /// No description provided for @clientBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Client breakdown'**
  String get clientBreakdown;

  /// No description provided for @hoursReportPreview.
  ///
  /// In en, this message translates to:
  /// **'Hours report preview'**
  String get hoursReportPreview;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @everyWeek.
  ///
  /// In en, this message translates to:
  /// **'Every week: {days}'**
  String everyWeek(String days);

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add client'**
  String get addClient;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @clientColor.
  ///
  /// In en, this message translates to:
  /// **'Client color'**
  String get clientColor;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @chooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose color'**
  String get chooseColor;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @minBefore.
  ///
  /// In en, this message translates to:
  /// **'{min} min before'**
  String minBefore(int min);

  /// No description provided for @hourBefore.
  ///
  /// In en, this message translates to:
  /// **'{hours} hour(s) before'**
  String hourBefore(int hours);

  /// No description provided for @hoursReport.
  ///
  /// In en, this message translates to:
  /// **'Work hours report'**
  String get hoursReport;

  /// No description provided for @visits.
  ///
  /// In en, this message translates to:
  /// **'visits'**
  String get visits;

  /// No description provided for @everyNWeeks.
  ///
  /// In en, this message translates to:
  /// **'Every {n} wk: {days}'**
  String everyNWeeks(int n, String days);

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get daily;

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String everyNDays(int n);

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Visi!'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal visit planner'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Plan your visits'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Add clients and schedule visits in the calendar. Set reminders so you never miss an appointment.'**
  String get onboardingStep1Desc;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Track your earnings'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Set hourly rates per client. Visi automatically calculates your income and generates monthly reports.'**
  String get onboardingStep2Desc;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Manage clients'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Keep notes, contact info and visit history. Send SMS reminders with one tap.'**
  String get onboardingStep3Desc;

  /// No description provided for @onboardingLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go!'**
  String get onboardingLetsGo;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in is disabled. Contact the administrator.'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get authErrorEmailAlreadyInUse;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetworkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get authErrorNetworkRequestFailed;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Sign-in error. Please try again.'**
  String get authErrorUnknown;

  /// No description provided for @authErrorPopupClosed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in window was closed. Please try again.'**
  String get authErrorPopupClosed;

  /// No description provided for @authErrorPopupBlocked.
  ///
  /// In en, this message translates to:
  /// **'Browser blocked the sign-in popup. Allow popups for this site.'**
  String get authErrorPopupBlocked;
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
      <String>['en', 'nb', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
