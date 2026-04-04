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

### Flutter Web i Firebase — rozwiązywanie problemów

Jeśli aplikacja startuje w Chrome (`flutter run -d chrome`), ale nie przechodzi logowania lub onboardingu:

#### 1. Konfiguracja Firebase Console

Upewnij się, że lokalny host jest na liście **Authorized domains** (OAuth / Auth):

1. [Firebase Console](https://console.firebase.google.com) → projekt → **Authentication** → **Settings** → **Authorized domains**.
2. Dodaj **`localhost`** oraz **`127.0.0.1`**, jeśli ich brakuje (origin z dowolnym portem, np. `http://localhost:64651`, nadal jest hostem `localhost` — wpis `localhost` zwykle wystarcza na wszystkie porty).

#### 2. Renderer Web i warstwy UI

Niektóre efekty (np. `BackdropFilter`, złożone przejścia `Hero`) mogą na starszych konfiguracjach zachowywać się inaczej w zależności od silnika web.

- **Flutter 3.41+ (stable):** przy `flutter run` **nie ma już** opcji `--web-renderer` — użyj po prostu:

  ```bash
  flutter run -d chrome
  ```

- Na aktualnym **stable** domyślna ścieżka web jest zorientowana na **CanvasKit** (renderer HTML jest wycofywany). Jeśli w dokumentacji widzisz `flutter run -d chrome --web-renderer canvaskit`, to polecenie może zwrócić błąd *„Could not find an option named --web-renderer”* — wtedy pomijasz tę flagę.

- Przy problemach z UI sprawdź też **DevTools → Console / Network** (CORS, `auth/*`, Firestore) oraz logi `GoRouter` w trybie debug (`debugLogDiagnostics` w routerze).

#### 3. Checklista DevTools (Chrome)

Gdy przycisk „nie reaguje” lub ekran stoi w miejscu — **DevTools przeglądarki** (macOS: **Cmd + Option + J**; Windows/Linux: **F12** lub **Ctrl + Shift + J**):

| Gdzie patrzeć | Co szukać |
|---------------|-----------|
| **Console** | Błędy **CORS** (często związane z domeną / konfiguracją Firebase lub hostingiem). Komunikaty **Hive / IndexedDB** przy starcie. |
| **Application** → **Storage** → **IndexedDB** | Czy po starcie aplikacji pojawiają się bazy/boxy Hive (inicjalizacja `Hive.initFlutter()` w `main.dart`, potem `DatabaseService.init()`). |
| **Network** | Żądania do **Firebase Auth** i **Firestore**: status **403**, **401**, lub **(canceled)** — podpowiedź do rules / tokenów / przerwanego requestu. |

#### 4. Asynchroniczność na Webie (auth i router)

Przy **0 błędów** z `flutter analyze` i **zielonych testach** „zamrożenie” na Webie bardzo często wynika z **timingów async**, a nie z syntaktyki.

- Główna aplikacja używa **GoRouter** (`lib/app/router/app_router.dart`) i **`authProvider`** (Riverpod), a nie już `MaterialApp(home: AuthWrapper)` — przy debugowaniu patrz na **redirect** routera i stan **`AsyncValue`** auth (w debug buildzie są też logi `GoRouter redirect: …`).
- Na **Webie** pierwsze zdarzenie ze **streamu Firebase Auth** może przyjść **wolniej** niż na urządzeniu mobilnym. Kod nie powinien zakładać natychmiastowego pierwszego emisji ani blokować nawigacji **nieskończonym `await`** na „pierwszym evencie” bez **ekranu ładowania** (u nas start z **`/` splash** do momentu ustabilizowania `authProvider`).

**Co zrobić w praktyce:** najpierw **Firebase Console → Authorized domains** (jeśli problem dotyczy logowania OAuth), równolegle **DevTools** według tabeli powyżej — to nie wyklucza się z commitem dokumentacji do repo.

---

### Licencja

Projekt prywatny.
