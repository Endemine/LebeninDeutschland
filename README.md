# Einbürgerungstest Pro — Leben in Deutschland

Lern-App für den deutschen Einbürgerungstest. Alle 460 amtlichen Fragen aus dem Gesamtkatalog "Leben in Deutschland", mit Quiz-Modus, Lernmodus, Statistik und Übersetzungen auf Englisch und Arabisch.

Das Repository enthält zwei Implementierungen derselben Idee:

- **`project/`** — die native Flutter-App für Android und Web (PWA)
- **`webapp/`** — eine eigenständige Web-App ohne Build-Schritt (HTML/CSS/Vanilla JS), läuft direkt im Browser

## Funktionen

- 460 Fragen aus dem offiziellen Katalog
- Quiz-Modus mit Auswertung und optionalem Timer
- Lernmodus zum gezielten Durcharbeiten einzelner Kategorien
- Lesezeichen für schwierige Fragen
- Fortschritts- und Kategorie-Statistik
- Übersetzung jeder Frage auf Englisch (`en`) und Arabisch (`ar`)
- Installierbar als PWA, funktioniert offline

## Flutter-App starten (`project/`)

Voraussetzung: Flutter SDK ^3.5.0.

```bash
cd project
flutter pub get
flutter run            # auf angeschlossenem Gerät / Emulator
flutter run -d chrome  # im Browser
flutter build apk      # Release-APK
flutter build web      # Web-Build
```

Wichtige Verzeichnisse:

```
project/lib/screens     UI-Screens (Home, Quiz, Lernen, Statistik, …)
project/lib/providers    State Management mit Provider
project/lib/services     Fragen laden, Persistenz (shared_preferences)
project/lib/models       Datenmodelle
project/assets           questions.json
```

## Web-App starten (`webapp/`)

Kein Build nötig. Einen statischen Server im Ordner starten, z. B.:

```bash
cd webapp
python -m http.server 8000
# http://localhost:8000 öffnen
```

`questions.json` und `translations.json` werden zur Laufzeit geladen.

## Daten

`questions.json` hält die 460 Fragen mit Antworten, korrekter Lösung und Kategorie. `translations.json` enthält pro Frage-ID die englische und arabische Übersetzung von Frage und Antworten. Die `batch_*.json`- und `translations_*.json`-Dateien im Root sind die Zwischenstände aus der Erstellung der Übersetzungen.

## Technik

Flutter 3, Provider für State Management, `shared_preferences` für lokale Persistenz, `fl_chart` für Statistiken, `google_fonts`. Die Web-App kommt ohne Framework und ohne Build-Pipeline aus.

`SPEC.md` beschreibt Design-System, Architektur und Screen-Spezifikationen im Detail.
