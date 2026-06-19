# Code Review — Leben in Deutschland (Einbuergerungstest)

**Projekt:** `LebeninDeutschland` auf USB-Stick
**Komponenten:** Flutter App (project/) + Standalone PWA (webapp/)
**Gesamt:** ~30 Dart-Dateien + 6 Web-Dateien + JSON-Daten + Konfig
**Stand:** 19.06.2026

---

## 🚨 CRITICAL — Must fix before production

### Flutter App

| # | File | Issue | Fix |
|---|------|-------|-----|
| 1 | lib/providers/learning_provider.dart:196 | **Fragen-Loading ist ein stub.** _loadQuestionsFromAsset() gibt [] zurück statt aus assets/questions.json zu laden. Die ganze App funktioniert nur mit hardcoded Demo-Daten. | rootBundle.loadString('assets/questions.json') + jsonDecode + Question.fromJson() |
| 2 | lib/services/question_service.dart:72 | **loadQuestions() early-return Guard blockiert Retry.** Wenn Fragen beim ersten Laden fehlschlagen, macht if (_isLoaded) return; alle folgenden Aufrufe wirkungslos — getAllQuestions() wirft dann StateError. | _isLoaded = false setzen bei Fehler, damit nächster Aufruf retryt |
| 3 | **Alle Screens (7 Stück)** | **Jeder Screen hat eigene hardcodierte Demo-Daten** statt die Provider zu konsumieren. HomeScreen: 225/300 learned (fake). QuizScreen: 3 Demo-Fragen + modulo indexing. LearningScreen: 5 Demo-Fragen. QuizResultScreen: 28/33 fake. StatisticsScreen: 4 fake Tests. BookmarksScreen: 4 fake Bookmarks. SettingsScreen: dupliziert SettingsProvider lokal. | Jeder Screen muss context.watch<Provider>() nutzen statt lokaler _questions, _userAnswers, _recentTests etc. |
| 4 | lib/models/quiz_result.dart:277 | **Type-Mismatch in isCorrect.** userAnswer == question.correctAnswer vergleicht int? (userAnswer) mit String (correctAnswer getter gibt answers[correctAnswerIndex] zurück = String). Immer false. | userAnswer == question.correctAnswerIndex (int zu int) |
| 5 | lib/app_router.dart | **AppRouter.generateRoute() wird nie aufgerufen.** main.dart nutzt routes: Map-Syntax statt onGenerateRoute. Der ganze Router ist dead code, SplashScreen wird nie angezeigt. | Entweder onGenerateRoute: AppRouter.generateRoute in MaterialApp oder AppRouter löschen |
| 6 | lib/providers/statistics_provider.dart:133 | **Datenverlust nach App-Neustart.** fromJsonSimple() verwirft alle questionAnswers (setzt []). categoryStats und Trends sind nach Restart leer. | question-Daten serialisieren oder aus questions.json rekonstruieren |

### Webapp (PWA)

| # | File | Issue | Fix |
|---|------|-------|-----|
| 7 | webapp/app.js:693,865,881,1110 | **4× innerHTML mit unescaped Question-Text.** translatedQuestion, getAText(q,i) und answerText werden direkt in innerHTML-Template-Literals injiziert — stored XSS wenn questions.json bösartigen HTML enthält. | DOM mit document.createElement() + .textContent aufbauen statt innerHTML |
| 8 | webapp/index.html | **Kein Content-Security-Policy Meta-Tag.** Bei 4+ innerHTML-Injektionspunkten kein Schutz gegen XSS. | CSP-Meta-Tag mit default-src 'self'; script-src 'self'; |
| 9 | webapp/index.html | **Kein HTTPS-Enforcement.** Kann über HTTP ausgeliefert werden (MITM auf Fragen-Daten). | upgrade-insecure-requests CSP oder HSTS im Server |

### Build/Release

| # | File | Issue | Fix |
|---|------|-------|-----|
| 10 | android/app/build.gradle:37 | **Release APK wird mit Debug-Keystore signiert.** signingConfig = signingConfigs.debug — kann nicht im Play Store veröffentlicht werden. | Release-Keystore konfigurieren via keystore.properties + env vars |
| 11 | test/widget_test.dart | **Test ist broken.** Referenziert MyApp (gibt's nicht — Klasse heißt EinbuergerungApp) und testet Counter/Icons die nicht existieren. | Mock-SharedPreferences + EinbuergerungApp(sharedPreferences: ...) als Smoketest |

---

## ⚠️ HIGH — Strongly recommended

### Flutter

| # | File | Issue | Fix |
|---|------|-------|-----|
| 12 | lib/providers/quiz_provider.dart:141 | **Mögliche doppelte Fragen im Quiz.** generalQuestions.where() + stateQuestions könnten Überlappungen haben. Kein uniqueness-check. | .toSet() vor dem Shuffle und ggf. auffüllen |
| 13 | android/app/build.gradle | **minSdk/compileSdk nicht gepinnt.** flutter.minSdkVersion kann sich mit SDK-Update ändern. Java 1.8 ist veraltet. | minSdk = 21, targetSdk = 34, JavaVersion.VERSION_11 |
| 14 | android/app/build.gradle | **Kein ProGuard/R8.** APK wird nicht obfuskiert/minified — reverse engineering + größere APK. | minifyEnabled true, proguardFiles + proguard-rules.pro |
| 15 | android/settings.gradle | **AGP 7.3.0 + Kotlin 1.7.10 veraltet.** AGP 7.3 ist von Aug 2022. | AGP 8.2.2+, Kotlin 1.9.22+, Gradle 8.4+ |
| 16 | android/app/src/main/AndroidManifest.xml | **android:allowBackup nicht gesetzt.** Default = true — User-Daten via ADB exportierbar. | android:allowBackup="false" oder dataExtractionRules |
| 17 | **iOS** | **Kein Podfile, keine PrivacyInfo.xcprivacy, keine AppIcon Assets.** iOS kann nicht gebaut werden. | cd ios && pod init && pod install, Privacy Manifest, Icons in Assets.xcassets |
| 18 | lib/providers/settings_provider.dart:179 | **Settings.save() fire-and-forget.** Wird nicht awaited — Fehler werden geschluckt. | await saveSettings() in allen Settern |
| 19 | lib/providers/learning_provider.dart:279 | **Persistence fire-and-forget.** _persistLearnedIds() und _persistBookmarkedIds() werden nicht awaited. | await + error handling |
| 20 | lib/widgets/timer_widget.dart:83 | **Timer ruft onTimeUp nicht auf wenn Zeit = 0.** Der Callback wird nie gefeuert. | Timer-Timeout-Callback implementieren |
| 21 | lib/widgets/question_card.dart:96 | **Image.network() unsicher.** Holt Bilder übers Netz — für Offline-Quiz-App falsch. Sollten als Assets gebündelt werden. | AssetImage statt Image.network |

### Webapp

| # | File | Issue | Fix |
|---|------|-------|-----|
| 22 | webapp/app.js:527 | **Auto-advance bei Antwort.** Nach 500ms automatisch nächste Frage — User kann Antwort nicht reviewen. Timer läuft währenddessen weiter. | Auto-advance entfernen oder in Settings verschiebbar machen |
| 23 | webapp/app.js:564 | **Timer pausiert nicht bei Tab-Wechsel.** Kein Page Visibility API — User verliert Zeit wenn Browser-Tab in Hintergrund geht. | visibilitychange Listener + Timer pausieren/resume |
| 24 | webapp/app.js:470 | **Event-Listener-Lecks.** Jeder render-Durchlauf bindet neue Click-Listener (4× pro Frage = 132+ nach 33 Fragen). Keine cleanup. | Event-Delegation auf Container-Ebene |
| 25 | webapp/sw.js:15 | **SW-Installation ohne error handling.** cache.addAll() Fehler lassen SW silent failen — kein Offline-Support. | try/catch + self.skipWaiting() |
| 26 | webapp/sw.js:22 | **Cache-first ohne Update-Mechanismus.** Fragen werden nie aktualisiert bis Cache manuell geleert wird. | stale-while-revalidate + Cache-Versioning + activate-Handler |
| 27 | webapp/app.js:147 | **localStorage-Quota-Risiko.** saveProgress() serialisiert gesamtes quizHistory (20 Einträge) + learned + bookmarks (je bis 460 IDs). Frequente saves ohne throttling. | Debounce (500ms) + IndexedDB für große Datasets |

---

## 🟡 MEDIUM — Should fix

### Flutter (15 items)
- **28.** lib/screens/quiz_setup_screen.dart:139 — Bundesland "Ändern" Button ist TODO ohne Implementation
- **29.** lib/screens/quiz_setup_screen.dart:196 — Navigiert zu '/quiz' ohne QuizProvider.startQuiz() aufzurufen
- **30.** lib/main.dart:29 — SharedPreferences.getInstance() wird genommen aber nie benutzt (Parameter to waste)
- **31.** lib/screens/home_screen.dart:29 — Bundesland-Liste ohne Umlaute: 'Baden-Wuerttemberg' ≠ 'Baden-Württemberg'
- **32.** lib/providers/settings_provider.dart:309 — resetProgress() löscht SharedPreferences Keys, aber LearningProvider hat noch alte Werte im Memory
- **33.** lib/models/app_settings.dart:95 — Default-Bundesland = 'Bayern' — sollte beim ersten Start abfragen
- **34.** lib/services/storage_service.dart:55 — Singleton ohne Reset-Möglichkeit für Tests
- **35.** lib/services/storage_service.dart:215 — int.parse() ohne try-catch — ein korrupter Wert killt alle Daten
- **36.** lib/models/quiz_result.dart:101 — ID = DateTime.now().millisecondsSinceEpoch — kein UUID, mögliche Kollision bei schnellem Quiz
- **37.** lib/models/category_stats.dart:252 — Chained null-aware cast as int? kann TypeError werfen wenn Wert anderen Type hat
- **38.** lib/screens/learning_screen.dart:237 — Searchfeld ohne Debounce — rebuild bei jedem Keystroke
- **39.** lib/screens/quiz_screen.dart:224 — Frage-Indikatoren rerendern jeden Tick wegen Timer (kein const Builder)
- **40.** pubspec.yaml — flutter_timer_countdown: ^1.0.7 ist obskur, wenig Adoption, potentiell unmaintained
- **41.** analysis_options.yaml — Keine strict lints aktiviert (prefer_const_constructors, avoid_print, etc.)
- **42.** .gitignore — .vscode/ ist auskommentiert → könnte committed werden

### Webapp (8 items)
- **43.** webapp/app.js:1228 — console.log('Fragen geladen:', ...) und 'Q1 EN:' Debug-Logs in Production
- **44.** webapp/app.js:1221 — questions.json URL ohne Base-Path — bricht in Subdirectory-Deployment
- **45.** webapp/app.js:384 — Shuffle zerstört Reihenfolge (General → State-spezifisch). Quiz fühlt sich chaotisch an
- **46.** webapp/app.js:863 — renderLearnQuestions() rendert ALLE 460 Fragen bei jedem Toggle/Filter — kein virtual scrolling
- **47.** webapp/manifest.json — SVG-Icons in Data-URI werden von vielen Mobile-Browsern nicht unterstützt — PNG-Fallback fehlt
- **48.** webapp/index.html — Kein Favicon, kein apple-touch-icon
- **49.** webapp/index.html — Kein Splash-Screen für iOS/Android PWA
- **50.** webapp/test.html — Static Mockup shipped in Production — sollte gelöscht werden

---

## 🟢 LOW — Polish

- **51.** Doppelte Farbdefinitionen — Jeder Screen definiert _primary, _textPrimary etc. (~30×). Sollte AppTheme nutzen.
- **52.** lib/screens/quiz_result_screen.dart:60 — pushNamedAndRemoveUntil löscht gesamte NAV-History — kein Zurück möglich
- **53.** lib/services/storage_service.dart:93 — saveProgress() Doc sagt "wirft StateError" aber loadProgress() schluckt alle Fehler
- **54.** DMG-Build-Konfigurationen für Linux/macOS/Windows im Flutter-Projekt — vermutlich unnötig (nur Android + Web relevant?)
- **55.** android/app/src/main/AndroidManifest.xml — android:taskAffinity="" ungewöhnlich, sollte weggelassen werden
- **56.** pubspec.yaml — cupertino_icons als Dependency obwohl App Material-only ist
- **57.** README.md — Generischer Flutter-Template-README ohne Projektbeschreibung
- **58.** webapp/app.js:11 — Globaler window.app export — jeder injected Script kann State manipulieren

---

## ✅ What's GOOD

### Flutter
- Saubere MVVM-Architektur mit Models → Providers → Services → Screens → Widgets
- Provider-Pattern richtig genutzt (MultiProvider, ChangeNotifier)
- Ausführliche Deutsch-sprachige Doc-Comments auf jeder Klasse/Methode
- Models mit const constructors, copyWith(), unmodifiable collections
- Timer-Lifecycle korrekt mit dispose() in QuizProvider und TimerWidget
- QuizState hat nützliche Helper-Getter (progressPercent, formattedTime)
- CategoryStats hat sophisticated Trend-Analyse (first-half/second-half comparison)
- Consistent Xiaomi-Design (Orange #FF6B00, runde Ecken, saubere Typografie)
- Confetti-Animation für bestandene Tests
- Dark Mode + Multi-Language vorbereitet (SettingsProvider, AppLanguage)
- SharedPreferences-basierte Persistenz für alle User-Daten
- Keine Netzwerk-Permissions in Release-Manifest (minimal attack surface)
- publish_to: 'none' korrekt gesetzt
- Null Safety im gesamten Codebase

### Webapp
- Voll funktionsfähige PWA mit Service Worker + Offline-Support
- Multi-Language (DE/EN/AR) + RTL-Support für Arabisch
- Responsive Design, Dark Mode, saubere CSS Custom Properties
- Timer mit visueller Progress-Bar + Farbwarnungen (< 5min)
- Confetti bei bestandenem Test (17/33 = realer Threshold)
- QuizHistory mit 20 Einträgen capped → kein unbeschränktes localStorage-Wachstum
- Bestätigungsdialoge vor kritischen Aktionen (Quiz abbrechen, Progress reset)
- Fragen-Navigation mit Circle-Indikatoren + Statusfarben
- Kategorie-Filter + Search im Lernmodus
- Keine externe JS-Abhängigkeit — reines Vanilla JS
- Cache-Busting auf questions.json (Date.now())
- Graceful Error Handling für localStorage-Unavailability

---

## 📊 Summary

| Category | Flutter App | Webapp (PWA) | Total |
|----------|-------------|--------------|-------|
| 🔴 Critical | 6 | 3 | **11** |
| ⚠️ High | 10 | 6 | **21** |
| 🟡 Medium | 15 | 8 | **23** |
| 🟢 Low | 8 | 1 | **9** |
| **Total** | **39** | **18** | **57** |

**Severity Score: 6/10**
**Production Readiness: ❌ Needs fixes before production**

### Wichtigstes Problem
Die Flutter App ist funktional unvollständig — alle Screens nutzen Demo-Daten statt die Provider. Ein echter Quiz-Durchlauf ist nicht möglich bis learning_provider.dart die Fragen tatsächlich aus der JSON lädt und die Screens an die Provider angebunden werden.

### Empfohlene nächste Schritte (priorisiert)
1. **Fragen-Loading fixen** — _loadQuestionsFromAsset() in learning_provider.dart implementieren
2. **Screens an Provider anbinden** — Alle Demo-Daten durch Provider-Konsumption ersetzen (QuizProvider, LearningProvider, StatisticsProvider)
3. **QuizResult.isCorrect-Fix** — String vs int Vergleich korrigieren
4. **Release-Keystore konfigurieren** + ProGuard aktivieren
5. **Webapp XSS fix** — innerHTML durch textContent ersetzen + CSP einbauen
6. **iOS Build vorbereiten** — Podfile, Privacy Manifest, Icons
7. **Widget-Test fixen** — Smoketest der funktioniert
8. **Service Worker verbessern** — Error Handling + Cache-Update-Strategie
