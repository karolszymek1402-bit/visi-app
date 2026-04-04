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

  @override
  String get btnNext => 'Dalej';

  @override
  String get tagline => 'Planuj wizyty. Zarabiaj więcej.';

  @override
  String get loginEmail => 'Zaloguj się e-mailem';

  @override
  String get createAccount => 'Stwórz konto';

  @override
  String get continueWithGoogle => 'Kontynuuj z Google';

  @override
  String get signingIn => 'Trwa logowanie...';

  @override
  String get or => 'LUB';

  @override
  String get login => 'Zaloguj się';

  @override
  String get welcomeBack => 'Witaj ponownie';

  @override
  String get loginSubtitle => 'Zaloguj się, aby zarządzać wizytami';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Hasło';

  @override
  String get confirmPassword => 'Potwierdź hasło';

  @override
  String get rememberMe => 'Zapamiętaj mnie';

  @override
  String get forgotPassword => 'Zapomniałeś hasła?';

  @override
  String get whatsYourName => 'Jak masz na imię?';

  @override
  String get hintName => 'np. Anna, Kari';

  @override
  String get saveProfile => 'Zapisz profil';

  @override
  String get invalidEmail => 'Nieprawidłowy e-mail';

  @override
  String get passwordRequired => 'Podaj hasło';

  @override
  String get passwordTooShort => 'Hasło musi mieć min. 6 znaków';

  @override
  String get passwordsDoNotMatch => 'Hasła się nie zgadzają';

  @override
  String get resetPasswordPrompt => 'Wpisz e-mail, aby zresetować hasło';

  @override
  String get resetPasswordSent => 'Link do resetowania hasła wysłany na e-mail';

  @override
  String errorSave(String error) {
    return 'Błąd zapisu: $error';
  }

  @override
  String errorAuth(String error) {
    return 'Błąd autoryzacji: $error';
  }

  @override
  String get clientsDatabase => 'Baza Klientów';

  @override
  String get noClients => 'Brak klientów';

  @override
  String get newClient => 'Nowy klient';

  @override
  String get editClient => 'Edytuj klienta';

  @override
  String get clientName => 'Nazwa klienta';

  @override
  String get addressOptional => 'Adres (opcjonalnie)';

  @override
  String get phoneNumber => 'Numer telefonu';

  @override
  String get smsMessageContent => 'Treść wiadomości do wysłania';

  @override
  String get smsHint => 'Cześć! Przypominam o wizycie...';

  @override
  String get clientNote => 'Notatka o kliencie (opcjonalnie)';

  @override
  String get clientNoteHint => 'Np. Uczulenie na hybrydę, ulubiona kawa...';

  @override
  String get rateNokH => 'Stawka (NOK/h)';

  @override
  String get visitCycle => 'Cykl wizyt';

  @override
  String get oneWeek => '1 tydzień';

  @override
  String get twoWeeks => '2 tygodnie';

  @override
  String workloadDays(int count) {
    return 'Obciążenie: $count dni/tyg.';
  }

  @override
  String get startTime => 'Godzina rozpoczęcia';

  @override
  String get duration => 'Czas trwania';

  @override
  String get invalidNameOrRate => 'Podaj nazwę i prawidłową stawkę';

  @override
  String get delete => 'Usuń';

  @override
  String get cancel => 'Anuluj';

  @override
  String get deleteClient => 'Usuń klienta';

  @override
  String deleteClientConfirm(String name) {
    return 'Czy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String get today => 'Dziś';

  @override
  String get viewDay => 'Widok: dzień';

  @override
  String get viewWeek => 'Widok: tydzień';

  @override
  String get viewMonth => 'Widok: miesiąc';

  @override
  String get moveVisit => 'Przenieś wizytę';

  @override
  String get move => 'Przenieś';

  @override
  String get disableReminder => 'Wyłącz przypomnienie';

  @override
  String get copyReport => 'Kopiuj raport';

  @override
  String get reportCopied => 'Raport skopiowany do schowka';

  @override
  String get copy => 'Kopiuj';

  @override
  String get hue => 'Odcień';

  @override
  String get brightness => 'Jasność';

  @override
  String get monthProgress => 'Postęp miesiąca';

  @override
  String get percentComplete => '% ukończono';

  @override
  String get clientBreakdown => 'Podział na klientów';

  @override
  String get hoursReportPreview => 'Podgląd raportu godzin';

  @override
  String get dayMon => 'Pn';

  @override
  String get dayTue => 'Wt';

  @override
  String get dayWed => 'Śr';

  @override
  String get dayThu => 'Cz';

  @override
  String get dayFri => 'Pt';

  @override
  String get daySat => 'So';

  @override
  String get daySun => 'Nd';

  @override
  String everyWeek(String days) {
    return 'Co tydzień: $days';
  }

  @override
  String get addClient => 'Dodaj klienta';

  @override
  String get saveChanges => 'Zapisz zmiany';

  @override
  String get clientColor => 'Kolor klienta';

  @override
  String get saturation => 'Nasycenie';

  @override
  String get chooseColor => 'Wybierz kolor';

  @override
  String get reminder => 'Przypomnienie';

  @override
  String minBefore(int min) {
    return '$min min przed';
  }

  @override
  String hourBefore(int hours) {
    return '$hours godz. przed';
  }

  @override
  String get hoursReport => 'Raport godzin pracy';

  @override
  String get visits => 'wizyt';

  @override
  String everyNWeeks(int n, String days) {
    return 'Co $n tyg.: $days';
  }

  @override
  String get earned => 'Zarobione';

  @override
  String get planned => 'Planowane';

  @override
  String get hours => 'Godziny';

  @override
  String get daily => 'Codziennie';

  @override
  String everyNDays(int n) {
    return 'Co $n dni';
  }

  @override
  String get onboardingWelcome => 'Witaj w Visi!';

  @override
  String get onboardingSubtitle => 'Twój osobisty planer wizyt';

  @override
  String get onboardingStep1Title => 'Planuj wizyty';

  @override
  String get onboardingStep1Desc =>
      'Dodawaj klientów i planuj wizyty w kalendarzu. Ustaw przypomnienia, żeby nigdy nie przegapić spotkania.';

  @override
  String get onboardingStep2Title => 'Śledź zarobki';

  @override
  String get onboardingStep2Desc =>
      'Ustaw stawki godzinowe per klient. Visi automatycznie liczy Twoje przychody i generuje raporty miesięczne.';

  @override
  String get onboardingStep3Title => 'Zarządzaj klientami';

  @override
  String get onboardingStep3Desc =>
      'Przechowuj notatki, dane kontaktowe i historię wizyt. Wysyłaj SMS-y z przypomnieniami jednym kliknięciem.';

  @override
  String get onboardingLetsGo => 'Zaczynamy!';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingStep4Title => 'Ostatni krok';

  @override
  String get onboardingStep4Desc =>
      'Twoje dane są widoczne tylko dla Ciebie i pomagają liczyć zarobki. Możesz je zmienić w ustawieniach.';

  @override
  String get onboardingFinish => 'Gotowe, startujemy!';

  @override
  String get onboardingYourName => 'Twoje imię';

  @override
  String get onboardingOptionalHint => '* Stawka i lokalizacja są opcjonalne';

  @override
  String get labelActualDuration => 'Faktyczny czas trwania';

  @override
  String get labelEarned => 'Zarobek';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOfflineHint => 'Zmiany zapisywane lokalnie';

  @override
  String get statusSyncing => 'Synchronizuję...';

  @override
  String get statusSynced => 'Zsynchronizowano';

  @override
  String get authErrorOperationNotAllowed =>
      'Logowanie e-mailem jest wyłączone. Skontaktuj się z administratorem.';

  @override
  String get authErrorEmailAlreadyInUse =>
      'Ten e-mail jest już zarejestrowany.';

  @override
  String get authErrorWrongPassword => 'Nieprawidłowe hasło.';

  @override
  String get authErrorUserNotFound => 'Nie znaleziono konta z tym e-mailem.';

  @override
  String get authErrorTooManyRequests =>
      'Zbyt wiele prób. Spróbuj ponownie za chwilę.';

  @override
  String get authErrorNetworkRequestFailed => 'Brak połączenia z internetem.';

  @override
  String get authErrorUserDisabled => 'To konto zostało zablokowane.';

  @override
  String get authErrorUnknown => 'Błąd logowania. Spróbuj ponownie.';

  @override
  String get authErrorPopupClosed =>
      'Okno logowania zostało zamknięte. Spróbuj ponownie.';

  @override
  String get authErrorPopupBlocked =>
      'Przeglądarka zablokowała okno logowania. Odblokuj wyskakujące okna dla tej strony.';

  @override
  String get navCalendar => 'Kalendarz';

  @override
  String get navClients => 'Klienci';

  @override
  String get navFinance => 'Finanse';

  @override
  String get navSettings => 'Opcje';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsSignOut => 'Wyloguj się';

  @override
  String get settingsSignOutTitle => 'Wylogowanie';

  @override
  String get settingsSignOutConfirm => 'Czy na pewno chcesz się wylogować?';

  @override
  String get settingsSaved => 'Zapisano';

  @override
  String get settingsName => 'Imię i nazwisko';

  @override
  String get settingsDefaultRate => 'Domyślna stawka (NOK/h)';

  @override
  String get settingsWorkLocation => 'Lokalizacja pracy';

  @override
  String get financeTitle => 'Finanse';

  @override
  String get currentBalance => 'Aktualne saldo';

  @override
  String get addTransaction => 'Dodaj transakcję';

  @override
  String get transactionIncome => 'Przychód';

  @override
  String get transactionExpense => 'Wydatek';

  @override
  String get amountRequired => 'Kwota musi być dodatnią liczbą';

  @override
  String get categoryRequired => 'Kategoria jest wymagana';

  @override
  String deleteTransactionConfirm(String category) {
    return 'Usunąć transakcję \"$category\"?';
  }

  @override
  String get financeAmountLabel => 'Kwota';

  @override
  String get financeTypeLabel => 'Typ';

  @override
  String get financeCategoryLabel => 'Kategoria';

  @override
  String get financeNoteLabel => 'Notatka';

  @override
  String get financeOptional => 'Opcjonalnie';

  @override
  String get financeAmountHint => 'np. 1250,00';

  @override
  String get financeCategoryHint => 'np. Wizyta, Paliwo, Sprzęt';

  @override
  String get financeSaving => 'Zapisywanie...';

  @override
  String financeSaveFailed(String error) {
    return 'Błąd zapisu: $error';
  }

  @override
  String financeDeleteFailed(String error) {
    return 'Błąd usuwania: $error';
  }

  @override
  String financeLoadFailed(String error) {
    return 'Nie udało się wczytać transakcji: $error';
  }

  @override
  String get financeEmptyState =>
      'Brak transakcji. Kliknij +, aby dodać pierwszą.';

  @override
  String get financeCurrency => 'zł';

  @override
  String financeAmountWithCurrency(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String get financeLinkedToVisit => 'Powiązane z wizytą';

  @override
  String get financeCreateFromVisit => 'Rozlicz wizytę';
}
