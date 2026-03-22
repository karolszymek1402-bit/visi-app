# visi — Premium Business Management for Private Healthcare

<p align="center">
  <img src="assets/images/logo.svg" width="300" alt="visi logo">
</p>

---

### O Projekcie
**visi** to luksusowy planer i system zarządczy zaprojektowany specjalnie dla niezależnych opiekunów medycznych oraz sektora prywatnej opieki w Norwegii. Aplikacja łączy w sobie precyzję planowania z potężnym silnikiem finansowym, pozwalając na pełną kontrolę nad grafikiem, klientami i zarobkami w walucie NOK.

---

### Kluczowe Funkcjonalności

* **Inteligentny Kalendarz (Precision Mode):**
    * Zakres pracy 06:00 – 18:00.
    * Precyzja startu co **5 minut** oraz czasu trwania co **15 minut**.
    * System wizualnego skalowania (Visi Zoom) — widok dnia, tygodnia i miesiąca bez przewijania.
* **Silnik RRule (Recurrence Engine):** Zaawansowane planowanie cykliczne (turnusy co 1, 2 lub więcej tygodni) z automatycznym generowaniem wizyt w kalendarzu.
* **Dashboard Finansowy:** Automatyczne przeliczanie przepracowanych godzin na NOK w oparciu o indywidualne stawki klientów. Raporty miesięczne i prognozy zarobków.
* **Client CRM & SMS:** Baza klientów z personalizowanymi szablonami SMS. Automatyczne wstrzykiwanie daty i godziny wizyty do wiadomości.
* **Visi Live Tracker:** Wbudowany stoper rejestrujący rzeczywisty czas pracy u klienta z funkcją zapisu stanu (survival mode).
* **Hybrid Cloud (Firebase + Hive):** Architektura *Offline-first*. Błyskawiczne działanie lokalne z automatyczną synchronizacją w chmurze Google Firebase.
* **AI Orb:** Animowany asystent wizualny (Rive) z pulsowaniem kontekstowym.
* **Wielojęzyczność:** Polski, Norsk (Bokmål), English — przełączanie z poziomu profilu.

---

### Stack Techniczny

| Warstwa | Technologia |
|---|---|
| Framework | Flutter 3.11+ / Dart ^3.11 (Web & Mobile) |
| State Management | Riverpod 3 (NotifierProvider) |
| Database (Local) | Hive (NoSQL, Fast Key-Value) |
| Database (Cloud) | Firebase Firestore |
| Authentication | Firebase Auth (Google & Email) |
| Animacje | Rive (AI Orb), AnimationController |
| Lokalizacja | flutter_localizations + ARB (PL, NB, EN) |
| Powiadomienia | flutter_local_notifications |
| Styling | Material 3 (Custom Dark/Light Theme with Rose & Violet gradients) |

---

### Architektura

```
lib/
├── core/                  # Wspólne: modele, serwisy, providery, theme
│   ├── models/            # VisiUser, Visit, Client (Hive TypeAdapters)
│   ├── services/          # ProfileService, ReminderService, CloudStorage
│   ├── providers/         # AuthProvider, LocaleProvider, ThemeProvider
│   └── database/          # DatabaseService (Hive)
├── features/
│   ├── auth/              # WelcomeScreen, ProfileSetupScreen
│   ├── calendar/          # CalendarScreen, CalendarGrid, VisitBlock, DnD
│   ├── clients/           # ClientsScreen, EditClientSheet
│   └── finance/           # FinanceScreen, FinanceProvider
└── l10n/                  # ARB: pl, nb, en
```

---

### Jakość i Testy (QA)

Projekt realizowany zgodnie z najwyższymi standardami inżynierii oprogramowania. Stabilność systemu gwarantuje:

* **277+ Testów Jednostkowych i Integracyjnych**
* Pokrycie kluczowej logiki biznesowej (RRule, Finance Engine, Database Sync).
* Deterministyczne generowanie ID wizyt eliminujące konflikty danych.
* Wszystkie testy izolowane — `FakeDatabaseService` + `FakeCloudStorage` (zero zależności od filesystemu).

```bash
# Uruchomienie testów
flutter test

# Analiza statyczna (0 issues)
flutter analyze
```

---

### Uruchomienie

```bash
# 1. Sklonuj repozytorium
git clone https://github.com/TwojLogin/visi-app.git
cd visi-app

# 2. Zainstaluj zależności
flutter pub get

# 3. Uruchom na urządzeniu
flutter run

# 4. Uruchom na Chrome
flutter run -d chrome
```

---

### Licencja

Projekt prywatny.
