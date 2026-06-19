# SPEC.md — Einbuergerungstest Pro: Leben in Deutschland

> **Flutter App Specification Document**  
> **Version:** 1.0.0  
> **Date:** 2025-01-20  
> **Platform Targets:** Android (APK), Web (PWA)  
> **Architecture:** Clean Architecture with Provider State Management

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Design System](#2-design-system)
3. [App Architecture](#3-app-architecture)
4. [Data Layer](#4-data-layer)
5. [Screen Specifications](#5-screen-specifications)
6. [UI Component Library](#6-ui-component-library)
7. [Navigation & Routing](#7-navigation--routing)
8. [State Management](#8-state-management)
9. [Localization](#9-localization)
10. [Asset Structure](#10-asset-structure)
11. [Implementation Roadmap](#11-implementation-roadmap)
12. [Appendix](#12-appendix)

---

## 1. Project Overview

### 1.1 App Identity

| Property | Value |
|----------|-------|
| **App Name** | Einbuergerungstest Pro — Leben in Deutschland |
| **Package Name** | `de.einbuergerungstest.pro` |
| **Version** | 1.0.0 |
| **Min SDK** | Android 21 (API 21), Web (Chrome 90+) |
| **Target SDK** | Android 34 (API 34) |
| **Flutter SDK** | >=3.16.0 |

### 1.2 Core Purpose

Interactive preparation tool for the German naturalization test (*Einbuergerungstest*). The app contains:
- **300 general questions** valid nationwide (from the official catalog)
- **160 state-specific questions** (10 questions per each of Germany's 16 federal states)
- **460 total unique questions** across all categories

### 1.3 Target Audience

- Foreign nationals preparing for German citizenship
- Language learners studying German civics
- Users aged 18–65, varying technical proficiency

### 1.4 Key Value Propositions

1. **Realistic Exam Simulation** — 33 questions, 60-minute timer, official scoring (17/33 to pass)
2. **Structured Learning** — Categorized learning with progress tracking
3. **Personalized Experience** — State selection adapts quiz content to user's Bundesland
4. **Offline First** — All questions bundled; no internet required after install

### 1.5 Success Metrics (Definition of Done)

- [ ] User can complete a full 33-question exam simulation
- [ ] User can browse and learn all 300 general + 160 state questions
- [ ] Progress persists across app restarts (shared_preferences)
- [ ] Score tracking shows quiz history with pass/fail status
- [ ] All 16 Bundeslander selectable with correct state-specific questions
- [ ] App works offline after first launch
- [ ] Responsive layout works on phones (320dp–600dp) and tablets (600dp+)

---

## 2. Design System

### 2.1 Design Philosophy

**Xiaomi-inspired minimalism**: Clean white surfaces, generous whitespace, rounded geometric forms, and a single vibrant orange accent color. The design prioritizes clarity and focus — the content (questions and answers) is the hero.

### 2.2 Color Palette

#### Light Theme (Default)

| Token | Hex | Usage |
|-------|-----|-------|
| `--color-primary` | `#FF6B00` | Primary buttons, active states, progress indicators, icons |
| `--color-primary-light` | `#FF8533` | Hover states, secondary accents |
| `--color-primary-dark` | `#CC5500` | Pressed states |
| `--color-background` | `#FFFFFF` | App background, scaffold |
| `--color-surface` | `#F5F5F5` | Cards, elevated surfaces |
| `--color-surface-variant` | `#FAFAFA` | Subtle backgrounds inside cards |
| `--color-text-primary` | `#1A1A1A` | Headlines, question text |
| `--color-text-secondary` | `#8E8E93` | Subtitles, hints, metadata |
| `--color-text-tertiary` | `#C7C7CC` | Disabled states, placeholders |
| `--color-success` | `#34C759` | Correct answers, pass status, learned indicators |
| `--color-error` | `#FF3B30` | Wrong answers, fail status, errors |
| `--color-warning` | `#FF9500` | Timer warnings (< 5 min remaining) |
| `--color-border` | `#E5E5EA` | Card borders, dividers |
| `--color-overlay` | `rgba(0,0,0,0.4)` | Modals, bottom sheets backdrop |

#### Dark Theme

| Token | Hex | Usage |
|-------|-----|-------|
| `--color-background` | `#1C1C1E` | App background |
| `--color-surface` | `#2C2C2E` | Cards |
| `--color-surface-variant` | `#3A3A3C` | Subtle backgrounds |
| `--color-text-primary` | `#FFFFFF` | Primary text |
| `--color-text-secondary` | `#98989D` | Secondary text |
| `--color-border` | `#38383A` | Borders |

### 2.3 Typography

**Font Family:** `Inter` (primary), fallback to `Roboto`

| Style | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| `displayLarge` | 32px | 700 | 40px | -0.5px | Splash title, exam result score |
| `displayMedium` | 24px | 700 | 32px | -0.5px | Section headers, modal titles |
| `headlineLarge` | 20px | 600 | 28px | 0px | Screen titles (AppBar) |
| `headlineMedium` | 18px | 600 | 26px | 0px | Card titles, question numbers |
| `titleLarge` | 16px | 600 | 24px | 0px | Subsection headers |
| `bodyLarge` | 16px | 400 | 24px | 0px | Question text, answer options |
| `bodyMedium` | 14px | 400 | 20px | 0.25px | Explanations, descriptions |
| `bodySmall` | 12px | 400 | 16px | 0.4px | Metadata, timestamps, badges |
| `labelLarge` | 14px | 600 | 20px | 0.5px | Button text |
| `labelMedium` | 12px | 600 | 16px | 0.5px | Small button, chip text |

### 2.4 Spacing & Layout

**Base Unit:** 8px

| Token | Value | Usage |
|-------|-------|-------|
| `space-xs` | 4px | Tight gaps, icon padding |
| `space-sm` | 8px | Default internal padding |
| `space-md` | 16px | Card padding, section gaps |
| `space-lg` | 24px | Section spacing |
| `space-xl` | 32px | Major section dividers |
| `space-xxl` | 48px | Screen-level padding |

**Screen Padding:** 16px horizontal (mobile), 24px (tablet)
**Max Content Width:** 600px (centered on tablet/web)

### 2.5 Shape & Elevation

| Component | Corner Radius | Elevation (Light) | Elevation (Dark) |
|-----------|--------------|-------------------|------------------|
| Cards | 16px | 0px (border only) | 0px (border only) |
| Buttons (filled) | 12px | 0px | 0px |
| Buttons (outlined) | 12px | 0px | 0px |
| FAB | 16px | 2px | 2px |
| Bottom Sheet | 24px top | 2px | 2px |
| Dialog | 20px | 3px | 3px |
| Input Fields | 12px | 0px | 0px |
| Chips | 20px (pill) | 0px | 0px |
| Progress Indicator | 8px | 0px | 0px |

**Border Style:** Cards use 1px solid `--color-border` instead of shadow for a flatter, Xiaomi-style look.

### 2.6 Animation Tokens

| Animation | Duration | Easing | Usage |
|-----------|----------|--------|-------|
| `transition-fast` | 150ms | `ease-out` | Button presses, toggles |
| `transition-medium` | 250ms | `ease-in-out` | Page transitions, card reveals |
| `transition-slow` | 350ms | `ease-in-out` | Bottom sheets, dialogs |
| `spring-bounce` | 400ms | `spring()` | Success animations, celebratory |

---

## 3. App Architecture

### 3.1 High-Level Architecture

```
lib/
├── main.dart                          # Entry point, MultiProvider setup
├── app.dart                           # MaterialApp, theme, routing
├── core/                              # Core utilities
│   ├── constants/
│   │   ├── app_colors.dart            # All color definitions
│   │   ├── app_theme.dart             # LightTheme + DarkTheme
│   │   ├── app_typography.dart        # TextTheme definitions
│   │   ├── app_dimensions.dart        # Spacing, radius, breakpoints
│   │   └── app_constants.dart         # App-level constants (question counts, etc.)
│   ├── extensions/
│   │   ├── context_extensions.dart    # BuildContext helpers
│   │   └── string_extensions.dart     # String formatting helpers
│   └── utils/
│       ├── debouncer.dart
│       └── validators.dart
├── data/                              # Data layer
│   ├── models/                        # Data models
│   │   ├── question.dart
│   │   ├── question.g.dart            # Generated (if using json_serializable)
│   │   ├── quiz_state.dart
│   │   ├── quiz_result.dart
│   │   ├── user_progress.dart
│   │   ├── category_stat.dart
│   │   └── app_settings.dart
│   ├── repositories/
│   │   ├── question_repository.dart   # Question loading & filtering
│   │   ├── progress_repository.dart   # UserProgress CRUD via shared_preferences
│   │   └── settings_repository.dart   # AppSettings CRUD
│   └── datasources/
│       ├── questions_all.dart         # 300 general questions (const list)
│       ├── questions_bw.dart          # Baden-Wuerttemberg questions
│       ├── questions_by.dart          # Bayern questions
│       ├── questions_be.dart          # Berlin questions
│       ├── questions_bb.dart          # Brandenburg questions
│       ├── questions_hb.dart          # Bremen questions
│       ├── questions_hh.dart          # Hamburg questions
│       ├── questions_he.dart          # Hessen questions
│       ├── questions_mv.dart          # Mecklenburg-Vorpommern questions
│       ├── questions_ni.dart          # Niedersachsen questions
│       ├── questions_nw.dart          # Nordrhein-Westfalen questions
│       ├── questions_rp.dart          # Rheinland-Pfalz questions
│       ├── questions_sl.dart          # Saarland questions
│       ├── questions_sn.dart          # Sachsen questions
│       ├── questions_st.dart          # Sachsen-Anhalt questions
│       ├── questions_sh.dart          # Schleswig-Holstein questions
│       ├── questions_th.dart          # Thueringen questions
│       └── local_storage.dart         # SharedPreferences wrapper
├── presentation/                      # UI layer
│   ├── providers/                     # ChangeNotifiers (Provider)
│   │   ├── quiz_provider.dart
│   │   ├── learning_provider.dart
│   │   ├── statistics_provider.dart
│   │   └── settings_provider.dart
│   ├── screens/                       # One folder per screen
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── welcome_header.dart
│   │   │       ├── progress_overview_card.dart
│   │   │       ├── quick_actions_grid.dart
│   │   │       ├── state_selector_card.dart
│   │   │       └── recent_activity_list.dart
│   │   ├── quiz/
│   │   │   ├── quiz_screen.dart
│   │   │   ├── quiz_result_screen.dart
│   │   │   └── widgets/
│   │   │       ├── quiz_timer.dart
│   │   │       ├── question_card.dart
│   │   │       ├── answer_option.dart
│   │   │       ├── quiz_navigation_bar.dart
│   │   │       ├── progress_dots.dart
│   │   │       ├── result_summary.dart
│   │   │       └── question_review_item.dart
│   │   ├── learning/
│   │   │   ├── learning_screen.dart
│   │   │   ├── learning_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── category_filter_chips.dart
│   │   │       ├── question_list_item.dart
│   │   │       ├── learning_progress_bar.dart
│   │   │       └── bookmark_button.dart
│   │   ├── statistics/
│   │   │   ├── statistics_screen.dart
│   │   │   └── widgets/
│   │   │       ├── overall_progress_chart.dart
│   │   │       ├── quiz_history_list.dart
│   │   │       ├── weak_categories_card.dart
│   │   │       └── streak_card.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── widgets/
│   │           ├── setting_tile.dart
│   │           ├── language_selector.dart
│   │           └── state_selector.dart
│   ├── widgets/                       # Shared reusable widgets
│   │   ├── app_button.dart            # Primary/Secondary/Outlined buttons
│   │   ├── app_card.dart              # Styled container card
│   │   ├── circular_progress.dart     # Animated circular progress
│   │   ├── linear_progress.dart       # Animated linear progress
│   │   ├── empty_state.dart           # Empty state illustration + text
│   │   ├── loading_indicator.dart     # Custom loading spinner
│   │   ├── app_bar.dart               # Custom app bar
│   │   ├── bottom_nav_bar.dart        # Bottom navigation
│   │   ├── animated_counter.dart      # Number animation
│   │   ├── confetti_overlay.dart      # Success celebration
│   │   └── toast_message.dart         # In-app toast notifications
│   └── navigation/
│       └── app_router.dart            # Route definitions & navigation
└── l10n/                              # Localization
    ├── app_de.arb                     # German (default)
    ├── app_en.arb                     # English
    ├── app_tr.arb                     # Turkish
    └── app_ar.arb                     # Arabic
```

### 3.2 State Management Pattern

**Provider** with `ChangeNotifier` for all feature-level state.

Each screen has a dedicated Provider that:
- Holds mutable UI state
- Exposes computed getters (e.g., `progressPercentage`, `isQuizComplete`)
- Persists data through Repository layer
- Notifies listeners on state changes

**Provider Hierarchy (root level in main.dart):**

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => LearningProvider()),
    ChangeNotifierProvider(create: (_) => QuizProvider()),
    ChangeNotifierProvider(create: (_) => StatisticsProvider()),
  ],
  child: const EinbuergerungstestApp(),
)
```

### 3.3 Dependency Flow

```
UI (Screens/Widgets)
    |
    v
Presentation (Providers - ChangeNotifiers)
    |
    v
Data (Repositories)
    |
    v
Data Sources (Local: questions_*.dart files + SharedPreferences)
```

**Rules:**
- Providers never import Flutter UI widgets
- Repositories never import Providers
- Models are pure Dart classes with no external dependencies
- Data source files (questions_*.dart) contain only `const` question data

---

## 4. Data Layer

### 4.1 Data Models

#### Question

```dart
@immutable
class Question {
  final int id;                        // Unique ID (1-460)
  final String question;               // Question text
  final List<String> answers;          // 4 answer options (index 0-3)
  final int correctAnswer;             // Index of correct answer (0-3)
  final String category;               // e.g., "Verfassung", "Geschichte", "Recht", "Gesellschaft"
  final String? state;                 // null = general question; e.g., "Bayern", "Berlin"
  final String? explanation;           // Optional explanation for learning mode

  const Question({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.category,
    this.state,
    this.explanation,
  });

  bool get isStateQuestion => state != null;
  bool get isGeneralQuestion => state == null;

  Question copyWith({...});            // Standard copyWith
  Map<String, dynamic> toJson();       // For caching
  factory Question.fromJson(...);      // From cache
}
```

**Validation:**
- `answers.length` must be exactly 4
- `correctAnswer` must be 0, 1, 2, or 3
- `id` must be unique across all questions
- `category` must be one of the predefined category constants

#### QuizState

```dart
@immutable
class QuizState {
  final List<Question> questions;           // 33 questions (30 general + 3 state)
  final int currentQuestionIndex;           // 0-32
  final List<int?> userAnswers;             // null = unanswered, 0-3 = selected answer
  final DateTime startTime;
  final DateTime? endTime;                  // null while quiz is active
  final bool isFinished;
  final int remainingSeconds;               // Countdown timer value

  const QuizState({
    required this.questions,
    this.currentQuestionIndex = 0,
    required this.userAnswers,
    required this.startTime,
    this.endTime,
    this.isFinished = false,
    this.remainingSeconds = 3600,            // 60 minutes = 3600 seconds
  });

  // Computed properties
  int get answeredCount => userAnswers.where((a) => a != null).length;
  int get correctCount {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctAnswer) count++;
    }
    return count;
  }
  int get wrongCount => answeredCount - correctCount;
  int get unansweredCount => questions.length - answeredCount;
  double get progressPercent => (currentQuestionIndex + 1) / questions.length;
  bool get hasPassed => correctCount >= 17;
  bool get isTimerExpired => remainingSeconds <= 0;
  Duration get elapsedTime => DateTime.now().difference(startTime);

  QuizState copyWith({...});
}
```

#### QuizResult

```dart
@immutable
class QuizResult {
  final String id;                          // UUID
  final DateTime date;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;
  final Duration duration;                  // Actual time taken
  final bool passed;
  final String stateCode;                   // Which Bundesland was selected
  final List<QuestionResult> questionResults;

  const QuizResult({...});

  double get scorePercent => (correctAnswers / totalQuestions) * 100;
  String get formattedDate => // e.g., "15. Jan 2025"

  Map<String, dynamic> toJson();
  factory QuizResult.fromJson(...);
}

@immutable
class QuestionResult {
  final int questionId;
  final int? userAnswer;                    // null if unanswered
  final int correctAnswer;
  final bool isCorrect;

  const QuestionResult({...});

  Map<String, dynamic> toJson();
  factory QuestionResult.fromJson(...);
}
```

#### UserProgress

```dart
@immutable
class UserProgress {
  final Set<int> learnedQuestionIds;        // IDs marked as "learned"
  final Set<int> bookmarkedQuestionIds;     // Bookmarked for review
  final Map<String, CategoryStat> categoryStats;  // Per-category stats
  final List<QuizResult> quizHistory;       // Last 50 quiz results (capped)
  final DateTime? lastStudyDate;            // For streak calculation
  final int currentStreak;                  // Consecutive days studied

  const UserProgress({...});

  // Computed
  int get totalLearned => learnedQuestionIds.length;
  int get totalBookmarked => bookmarkedQuestionIds.length;
  double get overallProgressPercent => totalLearned / 460;
  List<QuizResult> get recentResults => quizHistory.take(10).toList();

  Map<String, dynamic> toJson();
  factory UserProgress.fromJson(...);
}
```

#### CategoryStat

```dart
@immutable
class CategoryStat {
  final String categoryName;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int learnedCount;

  const CategoryStat({...});

  double get accuracyPercent => 
    totalAnswered > 0 ? (correctAnswers / totalAnswered) * 100 : 0;
  double get learnedPercent => 
    totalQuestions > 0 ? (learnedCount / totalQuestions) * 100 : 0;
  int get totalAnswered => correctAnswers + wrongAnswers;

  Map<String, dynamic> toJson();
  factory CategoryStat.fromJson(...);
}
```

#### AppSettings

```dart
@immutable
class AppSettings {
  final String selectedStateCode;           // e.g., "BY" for Bayern
  final ThemeMode themeMode;                // system, light, dark
  final Locale locale;                      // de, en, tr, ar
  final bool showExplanations;              // Auto-show explanations in learning mode
  final bool soundEnabled;                  // Sound effects on/off
  final bool timerEnabled;                  // Show timer in quiz mode

  const AppSettings({...});

  AppSettings copyWith({...});
  Map<String, dynamic> toJson();
  factory AppSettings.fromJson(...);
}
```

### 4.2 Question Categories

```dart
class QuestionCategories {
  static const String verfassung = 'Verfassung';
  static const String geschichte = 'Geschichte';
  static const String recht = 'Recht';
  static const String gesellschaft = 'Gesellschaft';
  static const String politik = 'Politik';
  static const String kultur = 'Kultur';
  static const String religion = 'Religion';
  static const String wirtschaft = 'Wirtschaft';
  static const String europa = 'Europa';
  static const String allgemein = 'Allgemein';

  static const List<String> all = [
    verfassung, geschichte, recht, gesellschaft,
    politik, kultur, religion, wirtschaft, europa, allgemein,
  ];
}
```

### 4.3 Bundesland Model

```dart
@immutable
class Bundesland {
  final String code;         // e.g., "BY"
  final String name;         // e.g., "Bayern"
  final String nameLocalized; // Localized display name

  const Bundesland({
    required this.code,
    required this.name,
    required this.nameLocalized,
  });
}

class BundeslandData {
  static const List<Bundesland> all = [
    Bundesland(code: 'BW', name: 'Baden-Wuerttemberg', nameLocalized: 'Baden-Württemberg'),
    Bundesland(code: 'BY', name: 'Bayern', nameLocalized: 'Bayern'),
    Bundesland(code: 'BE', name: 'Berlin', nameLocalized: 'Berlin'),
    Bundesland(code: 'BB', name: 'Brandenburg', nameLocalized: 'Brandenburg'),
    Bundesland(code: 'HB', name: 'Bremen', nameLocalized: 'Bremen'),
    Bundesland(code: 'HH', name: 'Hamburg', nameLocalized: 'Hamburg'),
    Bundesland(code: 'HE', name: 'Hessen', nameLocalized: 'Hessen'),
    Bundesland(code: 'MV', name: 'Mecklenburg-Vorpommern', nameLocalized: 'Mecklenburg-Vorpommern'),
    Bundesland(code: 'NI', name: 'Niedersachsen', nameLocalized: 'Niedersachsen'),
    Bundesland(code: 'NW', name: 'Nordrhein-Westfalen', nameLocalized: 'Nordrhein-Westfalen'),
    Bundesland(code: 'RP', name: 'Rheinland-Pfalz', nameLocalized: 'Rheinland-Pfalz'),
    Bundesland(code: 'SL', name: 'Saarland', nameLocalized: 'Saarland'),
    Bundesland(code: 'SN', name: 'Sachsen', nameLocalized: 'Sachsen'),
    Bundesland(code: 'ST', name: 'Sachsen-Anhalt', nameLocalized: 'Sachsen-Anhalt'),
    Bundesland(code: 'SH', name: 'Schleswig-Holstein', nameLocalized: 'Schleswig-Holstein'),
    Bundesland(code: 'TH', name: 'Thueringen', nameLocalized: 'Thüringen'),
  ];
}
```

### 4.4 Question Data Format (DataSource)

Each `questions_*.dart` file exports a `const List<Question>`:

```dart
// lib/data/datasources/questions_all.dart
const List<Question> generalQuestions = [
  Question(
    id: 1,
    question: 'Was ist die Hauptstadt der Bundesrepublik Deutschland?',
    answers: ['Muenchen', 'Berlin', 'Hamburg', 'Koeln'],
    correctAnswer: 1,
    category: 'Allgemein',
    explanation: 'Berlin ist seit 1990 die Hauptstadt Deutschlands.',
  ),
  // ... 299 more questions
];
```

**State-specific files** follow the same pattern with `state` field populated:

```dart
// lib/data/datasources/questions_by.dart
const List<Question> bavariaQuestions = [
  Question(
    id: 301,
    question: 'Welches Wappen gehoert zum Freistaat Bayern?',
    answers: ['...', '...', '...', '...'],
    correctAnswer: 0,
    category: 'Allgemein',
    state: 'Bayern',
    explanation: 'Das bayerische Staatswappen zeigt ...',
  ),
  // ... 9 more Bayern questions (IDs 301-310)
];
```

**ID Allocation:**
- IDs 1–300: General questions
- IDs 301–310: Baden-Wuerttemberg
- IDs 311–320: Bayern
- IDs 321–330: Berlin
- IDs 331–340: Brandenburg
- IDs 341–350: Bremen
- IDs 351–360: Hamburg
- IDs 361–370: Hessen
- IDs 371–380: Mecklenburg-Vorpommern
- IDs 381–390: Niedersachsen
- IDs 391–400: Nordrhein-Westfalen
- IDs 401–410: Rheinland-Pfalz
- IDs 411–420: Saarland
- IDs 421–430: Sachsen
- IDs 431–440: Sachsen-Anhalt
- IDs 441–450: Schleswig-Holstein
- IDs 451–460: Thueringen

### 4.5 Local Storage (SharedPreferences)

**Storage Keys:**

| Key | Type | Description |
|-----|------|-------------|
| `user_progress` | JSON String | Serialized UserProgress |
| `app_settings` | JSON String | Serialized AppSettings |
| `quiz_state_backup` | JSON String | Auto-saved active quiz state |
| `first_launch` | bool | Whether app has been launched before |
| `last_sync_date` | String | ISO 8601 date for streak calculation |

**Storage Interface:**

```dart
abstract class LocalStorage {
  Future<void> init();
  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic>) fromJson);
  Future<void> setObject<T>(String key, T object, Map<String, dynamic> Function(T) toJson);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
  Future<void> clearAll();
}
```

### 4.6 Repository Interfaces

```dart
abstract class QuestionRepository {
  List<Question> getAllGeneralQuestions();
  List<Question> getQuestionsForState(String stateCode);
  List<Question> getQuestionsByCategory(String category);
  Question? getQuestionById(int id);
  List<String> getAllCategories();
  List<Question> generateQuizQuestions(String stateCode);  // 30 random general + 3 state-specific
}

abstract class ProgressRepository {
  Future<UserProgress> getProgress();
  Future<void> saveProgress(UserProgress progress);
  Future<void> toggleLearned(int questionId);
  Future<void> toggleBookmarked(int questionId);
  Future<void> addQuizResult(QuizResult result);
  Future<void> resetProgress();
  Future<bool> hasLearnedToday();
  Future<void> updateStreak();
}

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> setStateCode(String code);
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> setLocale(Locale locale);
  Future<void> resetToDefaults();
}
```

---

## 5. Screen Specifications

---

### 5.1 Splash Screen

**Screen ID:** `splash_screen`  
**Route:** `/splash`  
**Duration:** 2000ms (auto-navigate to Home)

#### Layout

```
+--------------------------------------------------+
|                                                  |
|                                                  |
|                                                  |
|              [App Icon - 120x120]                |
|                                                  |
|          Einbuergerungstest Pro                  |
|          Leben in Deutschland                    |
|                                                  |
|              [Loading Dots]                      |
|                                                  |
|                                                  |
|           [v1.0.0]                               |
+--------------------------------------------------+
```

#### Visual Details

- **Background:** `--color-background` (#FFFFFF)
- **Icon:** Custom app icon — orange (#FF6B00) rounded square with white checkmark inside circle (Material Icons: `check_circle` styled)
- **Title Text:** `displayLarge` style, `--color-text-primary`
- **Subtitle Text:** `bodyMedium`, `--color-text-secondary`
- **Version Text:** `bodySmall`, `--color-text-tertiary`, bottom 32px
- **Loading Indicator:** Three pulsing dots (orange), scale animation with staggered delays

#### Animation Sequence

```
t=0ms:    Screen appears, icon at 0.8 opacity, scale 0.9
t=200ms:  Icon fades in to 1.0 opacity, scales to 1.0 (spring animation, 400ms)
t=400ms:  Title fades in + slides up 20px (250ms)
t=600ms:  Subtitle fades in + slides up 20px (250ms)
t=800ms:  Loading dots appear, start pulsing animation
t=2000ms: Auto-navigate to /home with fade transition
```

#### Behavior

- On first launch: navigate to `HomeScreen` (state selection will be prompted there)
- Checks for saved quiz state — if exists, shows "Resume last quiz?" dialog before navigating
- No AppBar, no BottomNav

---

### 5.2 Home Screen

**Screen ID:** `home_screen`  
**Route:** `/home`  
**Bottom Nav Index:** 0

#### Layout (Scrollable)

```
+--------------------------------------------------+
| [AppBar: "Einbuergerungstest" + Settings Icon]    |
+--------------------------------------------------+
| 16px padding                                       |
| +------------------------------------------------+ |
| | Welcome Header                                 | |
| | "Guten Tag! Bereit zum Lernen?"               | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | Progress Overview Card                         | |
| | [Circle Chart]  [X von 300 Fragen gelernt]     | |
| | [Fortschritt ansehen ->]                       | |
| +------------------------------------------------+ |
|                                                    |
| +------------------+  +-------------------------+  |
| | [Quiz Start]     |  | [Lernmodus]             |  |
| | Icon: assignment |  | Icon: school            |  |
| | "Test starten"   |  | "Lernmodus"             |  |
| +------------------+  +-------------------------+  |
| +------------------+  +-------------------------+  |
| | [Statistiken]    |  | [Bookmarks]             |  |
| | Icon: bar_chart  |  | Icon: bookmark          |  |
| | "Statistiken"    |  | "Markierte"             |  |
| +------------------+  +-------------------------+  |
|                                                    |
| +------------------------------------------------+ |
| | Bundesland-Auswahl                             | |
| | [Dropdown/Selector: aktuell: Bayern]            | |
| | "Fragen werden fuer {Bundesland} angezeigt"     | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | Letzte Aktivitaeten                            | |
| | [List of recent quiz results or learning]      | |
| | - "Quiz: 24/33 richtig - Bestanden"            | |
| | - "10 Fragen gelernt"                          | |
| +------------------------------------------------+ |
|                                                    |
| [48px bottom padding for scroll clearance]         |
+--------------------------------------------------+
```

#### Component: Welcome Header

| Property | Value |
|----------|-------|
| Container | No card, just text block |
| Greeting | Dynamic based on time: "Guten Morgen!", "Guten Tag!", "Guten Abend!" |
| Subtitle | "Bereit fuer den Einbuergerungstest?" |
| Typography | Greeting: `headlineLarge`; Subtitle: `bodyMedium`, `--color-text-secondary` |
| Padding | 16px all sides |

**Greeting Logic:**
```dart
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Guten Morgen!';
  if (hour < 18) return 'Guten Tag!';
  return 'Guten Abend!';
}
```

#### Component: Progress Overview Card

| Property | Value |
|----------|-------|
| Card | `app_card` style, white background, 16px radius |
| Layout | Horizontal row: Circle chart (left) + Text info (right) |
| Circle Chart | Diameter 80px, stroke width 8px, track color `--color-surface`, progress color `--color-primary`, center text: "X%" in `headlineMedium` |
| Info Text | "245 von 300 Fragen gelernt" in `bodyLarge` + subtitle "Weiter so!" in `bodySmall`, `--color-text-secondary` |
| Action Link | Text button "Fortschritt ansehen ->", `--color-primary` |
| Tap Behavior | Navigates to Statistics Screen |
| Animation | Circle chart animates from 0 to actual value on first appear (800ms) |

#### Component: Quick Actions Grid

| Property | Value |
|----------|-------|
| Layout | 2x2 grid, equal width cards, 12px gap |
| Card Style | `app_card`, 12px radius, centered icon + label |
| Icon Size | 32px, `--color-primary` |
| Label | `labelMedium`, `--color-text-primary` |
| Card Height | 96px |
| Press Feedback | Scale to 0.96 + `--color-primary` at 10% opacity overlay |

**Card Specs:**

| Card | Icon | Label | Navigation |
|------|------|-------|------------|
| Quiz | `assignment` / `quiz` | l10n.startQuiz | `/quiz/setup` |
| Learning | `school` / `menu_book` | l10n.learningMode | `/learning` |
| Statistics | `bar_chart` / `insights` | l10n.statistics | `/statistics` |
| Bookmarks | `bookmark` / `bookmark_border` | l10n.bookmarks | `/learning?filter=bookmarks` |

#### Component: Bundesland Selector Card

| Property | Value |
|----------|-------|
| Card | `app_card`, full width |
| Header Row | "Dein Bundesland" + currently selected state |
| Selector | Bottom sheet popup with searchable list of 16 states |
| Selected State Display | State flag icon (circle) + state name + chevron_down icon |
| Info Text | Small text: "Die 3 Bundesland-Fragen im Test werden aus {State} ausgewaehlt" |
| Divider | 1px `--color-border` below header |

**Bottom Sheet Content:**
- Search bar at top (filters states)
- List of 16 Bundeslander as radio list tiles
- Each item: Circle avatar with state abbreviation + full name + radio button
- Selected item highlighted with `--color-primary` radio fill

#### Component: Recent Activity List

| Property | Value |
|----------|-------|
| Header | "Letzte Aktivitaeten" in `titleLarge` |
| Empty State | "Noch keine Aktivitaeten. Starte dein erstes Quiz!" with illustration |
| List Items | Max 5 most recent activities |
| Item Layout | Icon (left, in colored circle) + Title + Subtitle + Timestamp |
| Quiz Item | Icon: `assignment`, color `--color-primary`, title: "Quiz absolviert", subtitle: "24/33 richtig", timestamp: "Vor 2 Stunden" |
| Learning Item | Icon: `school`, color `--color-success`, title: "Fragen gelernt", subtitle: "10 neue Fragen", timestamp: "Gestern" |
| Divider | 1px between items, 16px indent |

#### AppBar

| Property | Value |
|----------|-------|
| Background | Transparent (scrolled: white with subtle border) |
| Title | "Einbuergerungstest" in `headlineLarge`, left-aligned |
| Actions | Settings icon button (right, navigates to `/settings`) |
| Elevation | 0 (always flat) |

#### Behavior

- **On State Change:** When user selects a different Bundesland, the progress card updates (progress shows general questions only, state questions shown separately)
- **First Launch:** If no state selected, show a prominent orange banner: "Waehle dein Bundesland aus, um mit dem richtigen Fragenkatalog zu starten"
- **Pull-to-Refresh:** Refreshes data from repositories (mainly updates progress)

---

### 5.3 Quiz Mode — Setup Screen

**Screen ID:** `quiz_setup_screen`  
**Route:** `/quiz/setup`  
**Parent:** Navigated from Home quick action

#### Layout

```
+--------------------------------------------------+
| [AppBar: Back Arrow + "Pruefungssimulation"]      |
+--------------------------------------------------+
| 16px padding                                       |
| +------------------------------------------------+ |
| | Info Card                                       | |
| | Icon: info_outline                              | |
| | "So funktioniert der echte Test:"              | |
| | - 33 Fragen (30 Allgemein + 3 Bundesland)      | |
| | - 60 Minuten Zeit                               | |
| | - 17 richtige Antworten = Bestanden             | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | Voraussetzungen                                 | |
| | [x] Bundesland ausgewaehlt: Bayern              | |
| | [ ] Genug Fragen gelernt (empfohlen: 100+)      | |
| +------------------------------------------------+ |
|                                                    |
| [        TEST STARTEN (Primary Button)           ] |
|                                                    |
| [  FRAGEN AUSWAHL ANSEHEN  (Text Button)        ] |
+--------------------------------------------------+
```

#### Visual Details

- **Info Card:** `app_card`, icon `--color-primary` in circle background
- **Checklist:** Green check for met conditions, gray dash for unmet (informational only, not blocking)
- **Start Button:** Full-width filled button, `--color-primary`, height 52px, `labelLarge` white text
- **Secondary Button:** Full-width text button, `--color-text-secondary`

#### Behavior

- **Start Button Tap:**
  1. Generate 33 questions (30 random from general + 3 from selected state)
  2. Initialize `QuizState` with start time
  3. Save initial state to local storage (backup)
  4. Navigate to `/quiz/active`
- **Question Preview:** Opens bottom sheet showing list of question categories that will appear
- **Back Button:** Returns to `/home`

---

### 5.4 Quiz Mode — Active Screen

**Screen ID:** `quiz_active_screen`  
**Route:** `/quiz/active`  
**Parent:** Entered from quiz setup

#### Layout

```
+--------------------------------------------------+
| [Timer Bar: Orange background, white text]        |
| "56:42 verbleibend"                               |
+--------------------------------------------------+
| [Linear Progress Bar: X of 33 questions]          |
+--------------------------------------------------+
| 16px padding                                       |
|                                                    |
| +------------------------------------------------+ |
| | Frage X von 33                                  | |
| | [Category Chip: Verfassung]                     | |
| |                                                  | |
| | Wie viele Bundeslaender hat die                 | |
| | Bundesrepublik Deutschland?                     | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | A) 14                                           | |
| +------------------------------------------------+ |
| +------------------------------------------------+ |
| | B) 15                                           | |
| +------------------------------------------------+ |
| +------------------------------------------------+ |
| | C) 16  <- selected                              | |
| +------------------------------------------------+ |
| +------------------------------------------------+ |
| | D) 17                                           | |
| +------------------------------------------------+ |
|                                                    |
| [  ZURUECK  ]          [  WEITER  ]                |
|                                                    |
| [   ABBRECHEN   ]                                  |
+--------------------------------------------------+
| [Question Navigation Dots: o o o * o ...]         |
+--------------------------------------------------+
```

#### Component: Timer Bar

| Property | Value |
|----------|-------|
| Position | Fixed at top, below AppBar |
| Height | 44px |
| Background | `--color-primary` normally; `--color-warning` when < 5 min; `--color-error` when < 1 min |
| Text | "MM:SS verbleibend" centered, white, `bodyLarge` |
| Behavior | Counts down every second; at 0, auto-submits quiz |
| Visibility | Can be hidden via settings (but timer still runs in background) |

#### Component: Linear Progress Bar

| Property | Value |
|----------|-------|
| Height | 4px |
| Track | `--color-surface` |
| Fill | `--color-primary` |
| Value | `(currentIndex + 1) / 33` |

#### Component: Question Card

| Property | Value |
|----------|-------|
| Container | `app_card`, 16px radius |
| Header | "Frage {X} von 33" in `bodySmall`, `--color-text-secondary` |
| Category Chip | Pill-shaped chip with category name, `--color-primary` at 10% opacity bg |
| Question Text | `bodyLarge`, `--color-text-primary`, 16px top padding |
| State Badge | If state question: small orange badge "{State}" |

#### Component: Answer Option

| Property | Value |
|----------|-------|
| Container | `app_card` with 12px radius, full width |
| Layout | Radio circle (left) + Answer text |
| Default State | White bg, `--color-border` border |
| Selected State | `--color-primary` border (2px), light orange background tint |
| Correct State (review) | `--color-success` border, light green background |
| Wrong State (review) | `--color-error` border, light red background |
| Disabled State | 50% opacity, no interaction |
| Tap Area | Entire card is tappable |
| Animation | 150ms color transition on selection |

**Answer Labels:** A), B), C), D) — displayed in bold before each option text.

#### Component: Navigation Buttons

| Property | Value |
|----------|-------|
| Layout | Row with space between |
| Back Button | Outlined button, disabled on first question |
| Next Button | Filled button (`--color-primary`); changes to "ABGEBEN" on last question |
| Submit on Last | If last question and answered, "ABGEBEN" in green (`--color-success`) |

#### Component: Question Dots Navigation

| Property | Value |
|----------|-------|
| Position | Bottom of screen, fixed |
| Height | 48px |
| Layout | Horizontally scrollable row of 33 dots |
| Dot Size | 8px diameter (current: 10px) |
| Answered Dot | `--color-primary` filled |
| Current Dot | `--color-primary` with ring border |
| Unanswered Dot | `--color-border` filled |
| Tap | Navigates directly to tapped question |
| Scroll | Auto-scrolls to keep current dot visible |

#### Behavior

- **Answer Selection:**
  1. User taps answer option
  2. Option visually selected (orange highlight)
  3. `userAnswers[currentIndex]` set to selected index
  4. Auto-save quiz state to local storage
  5. 500ms delay, then auto-advance to next question (if not last)
- **Back Navigation:** Warns if quiz in progress — "Moechtest du den Test wirklich verlassen? Fortschritt wird gespeichert."
- **Timer Expiry:** Auto-submit quiz, navigate to result screen
- **Question Jump:** Tapping a dot navigates to that question; answers can be changed anytime before submit
- **Auto-Advance:** Enabled by default, can be disabled in settings

#### Edge Cases

- User leaves app mid-quiz → state auto-saved, resume prompt on next launch
- All questions answered before timer ends → "ABGEBEN" button highlighted in green
- 5 minutes remaining → timer bar turns orange, subtle pulse animation
- 1 minute remaining → timer bar turns red, stronger pulse animation
- User taps back button → confirmation dialog with "Verlassen" / "Weitermachen"

---

### 5.5 Quiz Mode — Result Screen

**Screen ID:** `quiz_result_screen`  
**Route:** `/quiz/result`  
**Parent:** Shown after quiz submission

#### Layout (Scrollable)

```
+--------------------------------------------------+
| [Confetti Overlay (if passed)]                    |
+--------------------------------------------------+
| [AppBar: "Testergebnis" + Close (X) Button]       |
+--------------------------------------------------+
| 16px padding                                       |
|                                                    |
| +------------------------------------------------+ |
| | Result Card                                     | |
| |                                                 | |
| |          [Large Score Circle]                   | |
| |              24 / 33                            | |
| |                                                 | |
| |        *** BESTANDEN ***                        | |
| |        "Glueckwunsch!"                         | |
| |                                                 | |
| |   Zeit: 34:12  |  Richtig: 24  |  Falsch: 9   | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | Ergebnisverteilung                              | |
| | [Bar: Richtig #######] 24                       | |
| | [Bar: Falsch   ###] 9                           | |
| | [Bar: Unbeantwortet] 0                          | |
| +------------------------------------------------+ |
|                                                    |
| [  FRAGEN UEBERPRUEFEN  ]                         |
| [  NEUER TEST STARTEN  ]                          |
| [  ZUR STARTSEITE  ]                               |
|                                                    |
+--------------------------------------------------+
```

#### Component: Result Score Card

| Property | Value |
|----------|-------|
| Container | `app_card`, full width, centered content |
| Score Circle | 150px diameter, thick border (12px); `--color-success` if passed, `--color-error` if failed |
| Score Text | "24" in `displayLarge` + "/33" in `headlineMedium` |
| Status Label | "BESTANDEN" in `displayMedium`, `--color-success`; "NICHT BESTANDEN" in `--color-error` |
| Subtitle | "Glueckwunsch! Du hast den Test bestanden." OR "Uebung macht den Meister. Versuche es erneut!" |
| Stats Row | Three equal columns: Time taken, Correct count, Wrong count |

**Pass Animation:**
```
t=0ms:   Card appears with scale 0.8, opacity 0
t=300ms: Card scales to 1.0, opacity 1.0 (spring, 500ms)
t=600ms: Score circle border animates from 0 to final value (800ms)
t=1000ms: Score number counts up from 0 to actual score (1000ms)
t=1200ms: Status label fades in + slides up
```

**Confetti (Pass Only):**  
- 50-80 particles fall from top of screen
- Colors: `--color-primary`, `--color-success`, gold, white
- Duration: 3 seconds
- Fade out over last 500ms

#### Component: Result Breakdown Bars

| Property | Value |
|----------|-------|
| Container | `app_card` |
| Bars | Horizontal bars, 24px height, 8px radius |
| Correct Bar | `--color-success`, width proportional to count |
| Wrong Bar | `--color-error`, width proportional to count |
| Unanswered Bar | `--color-warning`, width proportional |
| Labels | Left: label text, Right: count number |
| Animation | Bars grow from 0 to final width (600ms, staggered 150ms) |

#### Actions

| Button | Style | Action |
|--------|-------|--------|
| Fragen ueberpruefen | Filled, `--color-primary` | Navigate to `/quiz/review` |
| Neuer Test starten | Outlined, `--color-primary` | Generate new quiz, navigate to `/quiz/active` |
| Zur Startseite | Text button | Navigate to `/home` |

#### Behavior

- Result is automatically saved to quiz history
- User can review each question with correct/wrong indication
- Share button (optional): Share score as text

---

### 5.6 Quiz Mode — Review Screen

**Screen ID:** `quiz_review_screen`  
**Route:** `/quiz/review`  
**Parent:** Entered from result screen

#### Layout

```
+--------------------------------------------------+
| [AppBar: Back + "Fragen ueberpruefen"]            |
+--------------------------------------------------+
| [Filter Chips: Alle | Richtig | Falsch]           |
+--------------------------------------------------+
| 16px padding                                       |
| [Scrollable list of question review cards]        |
|                                                    |
| +------------------------------------------------+ |
| | Frage 5  [FALSCH Badge - red]                  | |
| | Wie heisst der deutsche Bundeskanzler?         | |
| |                                                  | |
| | A) Olaf Scholz  [CORRECT - green check]        | |
| | B) Frank-Walter Steinmeier  [YOUR ANSWER - red]| |
| | C) Annalena Baerbock                            | |
| | D) Friedrich Merz                               | |
| |                                                  | |
| | [Erklaerung aufklappen]                         | |
| +------------------------------------------------+ |
| ... more questions ...                             |
+--------------------------------------------------+
```

#### Component: Review Question Card

| Property | Value |
|----------|-------|
| Container | `app_card`, 16px radius |
| Header | "Frage {X}" + Status badge ("RICHTIG" green / "FALSCH" red / "UNBEANTWORTET" orange) |
| Question | `bodyLarge` |
| Answers | All 4 options shown with indicators |
| Correct Answer | Green checkmark icon + green text |
| User Wrong Answer | Red X icon + red text + "Deine Antwort" label |
| Explanation | Collapsible section, shown after tapping "Erklaerung anzeigen" |
| Divider | Between cards, 12px spacing |

#### Filter Chips

| Chip | Action |
|------|--------|
| Alle | Show all 33 questions |
| Richtig | Show only correctly answered |
| Falsch | Show only wrong/unanswered |

---

### 5.7 Learning Mode — Overview Screen

**Screen ID:** `learning_screen`  
**Route:** `/learning`  
**Bottom Nav Index:** 1 (if using bottom nav, otherwise accessed from Home)

#### Layout (Scrollable)

```
+--------------------------------------------------+
| [AppBar: "Lernmodus" + Filter Icon + Search]      |
+--------------------------------------------------+
| [Horizontal Filter Chips Row]                     |
| [Alle] [Verfassung] [Geschichte] [Recht] [Mehr v]| 
+--------------------------------------------------+
| 16px padding                                       |
| +------------------------------------------------+ |
| | Lernfortschritt                                 | |
| | [Linear Progress] 142 / 460 Fragen (31%)       | |
| +------------------------------------------------+ |
|                                                    |
| [Category Cards — Grid or List]                   |
|                                                    |
| +------------------------------------------------+ |
| | [icon] Verfassung                               | |
| | 45 / 60 Fragen                                  | |
| | [=======-----] 75%                              | |
| +------------------------------------------------+ |
| +------------------------------------------------+ |
| | [icon] Geschichte                               | |
| | 30 / 50 Fragen                                  | |
| | [======------] 60%                              | |
| +------------------------------------------------+ |
| ... more categories ...                            |
|                                                    |
| [FAB: "Zufaellig lernen" - shuffle icon]          |
+--------------------------------------------------+
```

#### Component: Filter Chips Row

| Property | Value |
|----------|-------|
| Scroll | Horizontally scrollable |
| First Chip | "Alle" — resets filter |
| Category Chips | One per question category |
| Active State | `--color-primary` bg, white text |
| Inactive State | `--color-surface` bg, `--color-text-secondary` |
| Extra Chip | "Mehr v" — opens dropdown with remaining categories |

#### Component: Learning Progress Card

| Property | Value |
|----------|-------|
| Container | `app_card` |
| Content | "X von Y Fragen gelernt (Z%)" |
| Progress Bar | Full-width linear progress, `--color-primary` fill |
| Percentage | Animated counter |

#### Component: Category Card

| Property | Value |
|----------|-------|
| Container | `app_card`, full width |
| Layout | Icon (left, in colored circle) + Info (center) + Chevron (right) |
| Icon | Material icon per category, `--color-primary` |
| Title | Category name, `bodyLarge` bold |
| Subtitle | "X von Y Fragen gelernt" |
| Progress Bar | Category-specific progress |
| Tap | Navigates to learning detail for that category |

**Category Icons:**

| Category | Icon | Color |
|----------|------|-------|
| Verfassung | `gavel` / `account_balance` | #FF6B00 |
| Geschichte | `history` / `museum` | #5856D6 |
| Recht | `balance` / `policy` | #007AFF |
| Gesellschaft | `people` / `groups` | #34C759 |
| Politik | `account_balance` / `flag` | #FF9500 |
| Kultur | `palette` / `theater_comedy` | #AF52DE |
| Religion | `church` / `temple_buddhist` | #8E8E93 |
| Wirtschaft | `trending_up` / `show_chart` | #5AC8FA |
| Europa | `public` / `language` | #5856D6 |
| Allgemein | `quiz` / `help_outline` | #FF3B30 |

#### FAB (Floating Action Button)

| Property | Value |
|----------|-------|
| Icon | `shuffle` |
| Label | "Zufaellig lernen" |
| Style | Extended FAB, `--color-primary` |
| Action | Opens a random unanswered question in learning detail view |

#### Behavior

- **Search:** AppBar search icon opens search field; filters questions by text content
- **Filter:** Chip selection filters displayed categories
- **Tap Category:** Navigates to `/learning/detail?category=X`
- **Swipe Category Card:** Quick actions — "Alle als gelernt markieren" / "Nicht gelernte anzeigen"

---

### 5.8 Learning Mode — Detail Screen

**Screen ID:** `learning_detail_screen`  
**Route:** `/learning/detail`  
**Parent:** Entered from learning overview

#### Layout

```
+--------------------------------------------------+
| [AppBar: Back + "Verfassung" + Bookmark + More]   |
+--------------------------------------------------+
| [Progress Bar: Question X of Y in category]       |
+--------------------------------------------------+
| 16px padding                                       |
| +------------------------------------------------+ |
| | Frage 23 von 60                                 | |
| |                                                  | |
| | Was bedeutet die Abkuerzung CDU?               | |
| |                                                  | |
| | A) Christlich Demokratische Union               | |
| | B) Christlich Deutsche Union                    | |
| | C) Christlich Demokratischer Umbruch            | |
| | D) Christlich Deutsche Umgebung                 | |
| +------------------------------------------------+ |
|                                                    |
| [  VORHERIGE  ]          [  NAECHSTE  ]           |
|                                                    |
| [    ALS GELEhRT MARKIEREN    ]                    |
+--------------------------------------------------+
```

#### Answer Selection & Feedback

**Immediate Feedback Mode (Default):**

```
1. User taps an answer option
2. All options immediately show:
   - Correct answer: Green background + checkmark
   - Wrong answer (if selected): Red background + X
   - Other options: Disabled gray
3. Explanation appears below answers:
   +------------------------------------------------+
   | Erklaerung                                      |
   | CDU steht fuer "Christlich Demokratische        |
   | Union". Es ist eine der großen politischen      |
   | Parteien in Deutschland.                        |
   +------------------------------------------------+
4. "NAECHSTE" button becomes primary action
```

#### Component: Explanation Card

| Property | Value |
|----------|-------|
| Container | `app_card` with `--color-surface` bg |
| Header | "Erklaerung" in `titleLarge` with `info_outline` icon |
| Body | Explanation text in `bodyMedium` |
| Border Left | 4px `--color-primary` left border |
| Animation | Slides up + fades in (250ms) |

#### Component: Learned Toggle

| Property | Value |
|----------|-------|
| Default State | Outlined button, "Als gelernt markieren" |
| Active State | Filled green button, "Gelernt ✓" |
| Action | Toggles learned status in UserProgress |
| Feedback | Brief green toast: "Als gelernt markiert" |

#### Navigation

| Button | Action |
|--------|--------|
| VORHERIGE | Previous question in filtered list |
| NAECHSTE | Next question; wraps around at end |
| Bookmark | Toggle bookmark status (icon: outlined ↔ filled) |
| Swipe Left | Next question gesture |
| Swipe Right | Previous question gesture |

#### Filter Persistence

- Questions shown respect active filters from overview screen
- Category filter + learned/unlearned/bookmarked filters apply
- Question order: By ID (default), can shuffle

---

### 5.9 Statistics Screen

**Screen ID:** `statistics_screen`  
**Route:** `/statistics`  
**Bottom Nav Index:** 2

#### Layout (Scrollable)

```
+--------------------------------------------------+
| [AppBar: "Statistiken" + Period Selector]         |
+--------------------------------------------------+
| 16px padding                                       |
| +------------------------------------------------+ |
| | Gesamtfortschritt                               | |
| | [Large Circular Progress] 142/460               | |
| | 31% der Fragen gelernt                          | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | Lernstreak                                      | |
| | [Flame Icon] 5 Tage                             | |
| | "Du lernst 5 Tage am Stueck!"                   | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | Quiz-Ergebnisse (letzte 10 Tests)               | |
| | [Line Chart: Score over time]                   | |
| | [List: Date | Score | Status]                   | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | Schwaechste Kategorien                          | |
| | [Horizontal Bar Chart per category]             | |
| | Verfassung  [====60%====]                       | |
| | Geschichte  [====55%====]                       | |
| | Recht       [=====70%====]                      | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | Lernaktivitaet                                  | |
| | [Weekly Heatmap: Mon-Sun activity dots]         | |
| +------------------------------------------------+ |
+--------------------------------------------------+
```

#### Component: Overall Progress Card

| Property | Value |
|----------|-------|
| Container | `app_card`, centered |
| Chart | Circular progress ring, 120px diameter |
| Center | "142/460" in `headlineLarge` + "Fragen gelernt" in `bodySmall` |
| Percentage | "31%" below chart in `displayMedium` |
| Animation | Ring animates on appear |

#### Component: Streak Card

| Property | Value |
|----------|-------|
| Container | `app_card` with subtle orange gradient (left to right, 5% to 15% opacity) |
| Icon | Flame icon, 40px, `--color-primary` |
| Number | Current streak in `displayMedium` |
| Subtitle | Encouragement text based on streak length |
| States | 0 days: "Starte heute deinen Lernstreak!" / 1-3: "Gut angefangen!" / 4-6: "Du bist im Flow!" / 7+: "Beeindruckend!" |

#### Component: Quiz History Chart

| Property | Value |
|----------|-------|
| Container | `app_card` |
| Chart Type | Line chart (CustomPainter or simple_flutter_chart) |
| X-Axis | Last 10 quiz dates |
| Y-Axis | Score (0-33) |
| Pass Line | Horizontal dashed line at y=17 (`--color-success`) |
| Data Points | Filled circles, `--color-primary` |
| Tap | Shows tooltip with exact score and date |
| Below Chart | Scrollable list of recent quiz results |

#### Component: Weak Categories Card

| Property | Value |
|----------|-------|
| Container | `app_card` |
| Title | "Schwaechste Kategorien" |
| Bars | Horizontal bars, sorted ascending by accuracy |
| Bar Colors | Gradient from `--color-error` (low) to `--color-success` (high) |
| Max Shown | 5 categories |
| Action | "Alle Kategorien" text button → full breakdown |

#### Component: Weekly Activity Heatmap

| Property | Value |
|----------|-------|
| Container | `app_card` |
| Layout | 7 columns (Mon-Sun), each with activity dots |
| Dots | 4 rows representing learning intensity (0, 25%, 50%, 75%, 100%) |
| Colors | Gray (none) → Light orange → `--color-primary` |
| Week Navigation | Left/right arrows to view previous weeks |

#### Behavior

- **Period Selector:** "Letzte Woche" / "Letzter Monat" / "Alle Zeit" — filters quiz history
- **Empty State:** If no quizzes taken, show illustration + "Noch keine Tests absolviert. Starte deinen ersten Test!"
- **Pull-to-Refresh:** Recalculates all statistics

---

### 5.10 Settings Screen

**Screen ID:** `settings_screen`  
**Route:** `/settings`  
**Navigation:** From Home AppBar settings icon

#### Layout (Scrollable)

```
+--------------------------------------------------+
| [AppBar: Back + "Einstellungen"]                  |
+--------------------------------------------------+
| 16px padding                                       |
| +------------------------------------------------+ |
| | APPEREANCE                                      | |
| | [  Dark Mode  ]          [System v]              | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | SPRACHE                                         | |
| | [  Deutsch  ]          [Deutsch >]               | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | DEIN BUNDESLAND                                 | |
| | [  Bayern   ]          [Bayern >]                | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | LERNMODUS                                       | |
| | [  Erklaerungen anzeigen  ]      [Toggle ON]    | |
| | [  Soundeffekte           ]      [Toggle ON]    | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | TEST                                              | |
| | [  Timer anzeigen         ]      [Toggle ON]    | |
| | [  Auto-Weiter            ]      [Toggle ON]    | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | DATEN                                             | |
| | [  Fortschritt zuruecksetzen ]    [>]            | |
| | [  Alle Daten exportieren    ]    [>]            | |
| +------------------------------------------------+ |
|                                                    |
| +------------------------------------------------+ |
| | INFO                                              | |
| | [  Ueber die App           ]    [>]              | |
| | [  Datenschutz             ]    [>]              | |
| | [  App-Version             ]    v1.0.0           | |
| +------------------------------------------------+ |
+--------------------------------------------------+
```

#### Setting Tile Component

| Property | Value |
|----------|-------|
| Container | Full width, 56px height, 16px horizontal padding |
| Layout | Leading icon (24px, `--color-text-secondary`) + Title + optional Subtitle (left) + Trailing widget (right) |
| Divider | 1px `--color-border`, full width indent 56px (after icon) |
| Tap | Entire row tappable; ripple effect from leading edge |
| Group Header | `labelMedium`, `--color-text-secondary`, 8px top padding, all-caps |

#### Settings Details

| Setting | Type | Options | Default |
|---------|------|---------|---------|
| Dark Mode | Dropdown | System / Light / Dark | System |
| Sprache | Selection Sheet | Deutsch / English / Turkce / العربية | Deutsch |
| Bundesland | Selection Sheet | 16 Bundeslander | None (prompt on first launch) |
| Erklaerungen | Toggle | ON / OFF | ON |
| Soundeffekte | Toggle | ON / OFF | ON |
| Timer anzeigen | Toggle | ON / OFF | ON |
| Auto-Weiter | Toggle | ON / OFF | ON |

#### Danger Zone

**"Fortschritt zuruecksetzen":**
- Tap opens confirmation dialog:
  - Title: "Fortschritt zuruecksetzen?"
  - Content: "Dies loescht alle deine Lernfortschritte, Lesezeichen und Testergebnisse. Diese Aktion kann nicht rueckgaengig gemacht werden."
  - Actions: "ABBRECHEN" (text) / "ZURUECKSETZEN" (red filled)
- On confirm: Clears all shared preferences data, shows toast "Fortschritt zurueckgesetzt", navigates to home

---

## 6. UI Component Library

### 6.1 AppButton

```dart
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;       // primary, secondary, outlined, text, danger
  final AppButtonSize size;       // small, medium, large
  final IconData? icon;
  final bool isFullWidth;
  final bool isLoading;
}
```

| Type | Background | Text | Border |
|------|-----------|------|--------|
| primary | `--color-primary` | White | None |
| secondary | `--color-surface` | `--color-primary` | None |
| outlined | Transparent | `--color-primary` | 1.5px `--color-primary` |
| text | Transparent | `--color-primary` | None |
| danger | `--color-error` | White | None |

### 6.2 AppCard

```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final double? radius;        // default 16
  final Color? backgroundColor; // default surface/background
  final EdgeInsets? padding;    // default 16
  final VoidCallback? onTap;
  final bool hasBorder;        // default true (1px border)
}
```

### 6.3 CircularProgress

```dart
class CircularProgress extends StatelessWidget {
  final double value;           // 0.0 to 1.0
  final double size;            // default 80
  final double strokeWidth;     // default 8
  final Color? trackColor;
  final Color? progressColor;
  final Widget? centerWidget;   // Optional center content
  final Duration animationDuration;
}
```

### 6.4 LinearProgress

```dart
class LinearProgress extends StatelessWidget {
  final double value;           // 0.0 to 1.0
  final double height;          // default 8
  final Color? trackColor;
  final Color? progressColor;
  final double? borderRadius;   // default 4
  final Duration animationDuration;
}
```

### 6.5 EmptyState

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
}
```

Default: Icon in large circle with `--color-surface` bg, title in `headlineMedium`, subtitle in `bodyMedium` secondary.

### 6.6 ConfettiOverlay

```dart
class ConfettiOverlay extends StatefulWidget {
  final bool isActive;          // When true, starts animation
  final int particleCount;      // default 60
  final Duration duration;      // default 3 seconds
  final VoidCallback? onComplete;
}
```

Uses `CustomPainter` with `AnimationController`. Particles are colored circles/squares with randomized:
- Start X position (0 to screen width)
- Fall speed (gravity simulation)
- Horizontal drift (sine wave)
- Rotation speed
- Size (4px to 12px)
- Color (from predefined palette)

### 6.7 AnimatedCounter

```dart
class AnimatedCounter extends StatefulWidget {
  final int targetValue;
  final Duration duration;      // default 1 second
  final TextStyle? textStyle;
  final String? suffix;         // e.g., "%" or "/33"
}
```

Animates from 0 to target using `AnimationController` + `IntTween`.

---

## 7. Navigation & Routing

### 7.1 Route Definitions

```dart
class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String quizSetup = '/quiz/setup';
  static const String quizActive = '/quiz/active';
  static const String quizResult = '/quiz/result';
  static const String quizReview = '/quiz/review';
  static const String learning = '/learning';
  static const String learningDetail = '/learning/detail';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
}
```

### 7.2 Route Table

| Route | Screen | Arguments | Transition |
|-------|--------|-----------|------------|
| `/splash` | SplashScreen | None | None (entry point) |
| `/home` | HomeScreen | None | Fade (from splash) |
| `/quiz/setup` | QuizSetupScreen | None | Slide from right |
| `/quiz/active` | QuizActiveScreen | None | Slide from bottom |
| `/quiz/result` | QuizResultScreen | QuizResult | Fade |
| `/quiz/review` | QuizReviewScreen | QuizState | Slide from right |
| `/learning` | LearningScreen | None | Slide from right |
| `/learning/detail` | LearningDetailScreen | `{category, questionId}` | Slide from right |
| `/statistics` | StatisticsScreen | None | Slide from right |
| `/settings` | SettingsScreen | None | Slide from right |

### 7.3 Navigation Rules

1. **No Bottom Navigation Bar** on: Quiz screens, Settings
2. **Back Button Behavior:**
   - Quiz active → Show "Leave quiz?" confirmation dialog
   - Quiz result → Navigate to `/home` (clear back stack)
   - All others → Standard pop
3. **Deep Linking:** Not required for MVP
4. **State Restoration:** Not required for MVP

### 7.4 First Launch Flow

```
[Splash] → [Home]
              ↓
    [Check: State selected?]
              ↓
    No → [Show State Selection Bottom Sheet]
    Yes → Show normal Home screen
```

---

## 8. State Management

### 8.1 QuizProvider

```dart
class QuizProvider extends ChangeNotifier {
  // State
  QuizState _quizState;
  bool _isLoading;
  String? _error;

  // Getters
  QuizState get quizState => _quizState;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  
  // Actions
  Future<void> startNewQuiz(String stateCode);
  void selectAnswer(int questionIndex, int answerIndex);
  void navigateToQuestion(int index);
  void nextQuestion();
  void previousQuestion();
  Future<void> submitQuiz();
  Future<void> resumeQuiz();  // From local storage backup
  Future<void> abandonQuiz();
  
  // Private
  Future<void> _saveQuizState();
  Future<void> _clearQuizBackup();
}
```

### 8.2 LearningProvider

```dart
class LearningProvider extends ChangeNotifier {
  // State
  List<Question> _filteredQuestions;
  String? _activeCategory;
  String? _searchQuery;
  FilterMode _filterMode;        // all, learned, unlearned, bookmarked
  Question? _currentQuestion;
  int _currentIndex;
  
  // Getters
  List<Question> get filteredQuestions => _filteredQuestions;
  Question? get currentQuestion => _currentQuestion;
  
  // Actions
  void setCategory(String? category);
  void setSearchQuery(String query);
  void setFilterMode(FilterMode mode);
  void goToQuestion(int index);
  void nextQuestion();
  void previousQuestion();
  Future<void> toggleLearned(int questionId);
  Future<void> toggleBookmarked(int questionId);
  void shuffleQuestions();
  
  // Computed
  int get learnedCount => // from progress repository
  int get totalInCategory => _filteredQuestions.length;
}
```

### 8.3 StatisticsProvider

```dart
class StatisticsProvider extends ChangeNotifier {
  // State
  UserProgress? _userProgress;
  List<QuizResult> _filteredResults;
  StatisticsPeriod _period;
  
  // Getters
  UserProgress get progress => _userProgress;
  double get overallProgressPercent;
  int get currentStreak;
  List<CategoryStat> get weakCategories;
  List<QuizResult> get recentResults;
  Map<String, double> get weeklyActivity;
  
  // Actions
  Future<void> loadStatistics();
  void setPeriod(StatisticsPeriod period);
  Future<void> resetProgress();
  
  // Computed
  List<QuizResult> getQuizHistoryForPeriod();
  List<CategoryStat> get categoriesSortedByWeakness;
}
```

### 8.4 SettingsProvider

```dart
class SettingsProvider extends ChangeNotifier {
  // State
  AppSettings _settings;
  
  // Getters
  AppSettings get settings => _settings;
  String get selectedStateCode => _settings.selectedStateCode;
  ThemeMode get themeMode => _settings.themeMode;
  Locale get locale => _settings.locale;
  bool get showExplanations => _settings.showExplanations;
  bool get soundEnabled => _settings.soundEnabled;
  bool get timerEnabled => _settings.timerEnabled;
  
  // Actions
  Future<void> loadSettings();
  Future<void> setStateCode(String code);
  Future<void> setThemeMode(ThemeMode mode);
  Future<void> setLocale(Locale locale);
  Future<void> toggleExplanations();
  Future<void> toggleSound();
  Future<void> toggleTimer();
  Future<void> resetToDefaults();
}
```

---

## 9. Localization

### 9.1 Supported Locales

| Locale Code | Language | Status | Completeness |
|-------------|----------|--------|-------------|
| `de` | Deutsch | Default | 100% |
| `en` | English | Supported | 100% |
| `tr` | Turkce | Supported | 100% |
| `ar` | Arabic | Supported | 100% |

### 9.2 ARB File Structure

All user-facing strings externalized in `.arb` files under `lib/l10n/`.

```json
{
  "@@locale": "de",
  "appTitle": "Einbuergerungstest Pro",
  "appSubtitle": "Leben in Deutschland",
  "startQuiz": "Test starten",
  "learningMode": "Lernmodus",
  "statistics": "Statistiken",
  "bookmarks": "Markierte Fragen",
  "settings": "Einstellungen",
  "questionOfTotal": "Frage {current} von {total}",
  "correctAnswer": "Richtig!",
  "wrongAnswer": "Falsch!",
  "explanation": "Erklaerung",
  "passed": "Bestanden",
  "failed": "Nicht bestanden",
  "scoreOfTotal": "{score} von {total}",
  "timeRemaining": "{minutes}:{seconds} verbleibend",
  "learned": "Gelernt",
  "notLearned": "Nicht gelernt",
  "markAsLearned": "Als gelernt markieren",
  "removeLearned": "Als ungelernt markieren",
  "cancel": "Abbrechen",
  "confirm": "Bestaetigen",
  "next": "Weiter",
  "previous": "Zurueck",
  "submit": "Abgeben",
  "selectState": "Bundesland auswaehlen",
  "stateRequired": "Bitte waehle ein Bundesland aus",
  "resetProgress": "Fortschritt zuruecksetzen",
  "resetConfirm": "Moechtest du wirklich alle Daten loeschen?",
  "yes": "Ja",
  "no": "Nein",
  "congratulations": "Glueckwunsch!",
  "tryAgain": "Uebung macht den Meister. Versuche es erneut!",
  "days": "Tage",
  "streak": "Lernstreak",
  "emptyQuizHistory": "Noch keine Tests absolviert",
  "emptyBookmarks": "Keine markierten Fragen",
  "emptyActivity": "Noch keine Aktivitaeten",
  "darkMode": "Dunkelmodus",
  "lightMode": "Hellmodus",
  "systemDefault": "System",
  "language": "Sprache",
  "timer": "Timer",
  "autoAdvance": "Auto-Weiter",
  "soundEffects": "Soundeffekte",
  "showExplanations": "Erklaerungen anzeigen",
  "about": "Ueber die App",
  "privacy": "Datenschutz",
  "version": "Version",
  "categories_all": "Alle",
  "categories_verfassung": "Verfassung",
  "categories_geschichte": "Geschichte",
  "categories_recht": "Recht",
  "categories_gesellschaft": "Gesellschaft",
  "categories_politik": "Politik",
  "categories_kultur": "Kultur",
  "categories_religion": "Religion",
  "categories_wirtschaft": "Wirtschaft",
  "categories_europa": "Europa",
  "categories_allgemein": "Allgemein",
  "minutes": "Minuten",
  "seconds": "Sekunden"
}
```

### 9.3 RTL Support (Arabic)

- All layouts must support RTL mirroring
- Use `Directionality` widget with `TextDirection.rtl` for Arabic locale
- Answer option labels (A, B, C, D) remain left-aligned even in RTL
- Icons with directional meaning (arrows, chevrons) auto-flip
- Ensure `flutter_localizations` is configured with `GlobalCupertinoLocalizations` and `GlobalMaterialLocalizations`

### 9.4 Setup

```yaml
# pubspec.yaml
flutter:
  generate: true
  
flutter_intl:
  enabled: true
  arb_dir: lib/l10n
  template_arb_file: app_de.arb
  output_dir: lib/generated
  output_localization_file: app_localizations.dart
```

```dart
// main.dart
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('de'),
  Locale('en'),
  Locale('tr'),
  Locale('ar'),
],
locale: settingsProvider.locale,
```

---

## 10. Asset Structure

### 10.1 Directory Layout

```
assets/
├── icons/
│   └── app_icon.png              # 1024x1024 app icon source
├── images/
│   ├── illustrations/
│   │   ├── empty_quiz.svg        # Empty quiz history illustration
│   │   ├── empty_bookmarks.svg   # Empty bookmarks illustration
│   │   ├── empty_activity.svg    # Empty activity illustration
│   │   ├── start_learning.svg    # Welcome/first launch illustration
│   │   └── success_celebration.svg # Pass celebration illustration
│   └── flags/                    # Optional: Bundesland flag icons
│       ├── bw.png
│       ├── by.png
│       └── ... (16 flags, 128x128)
├── audio/
│   ├── correct.mp3               # Correct answer sound (soft chime)
│   ├── wrong.mp3                 # Wrong answer sound (soft buzz)
│   ├── quiz_complete.mp3         # Quiz completion fanfare
│   └── click.mp3                 # Button click feedback
└── fonts/
    └── Inter/                    # Inter font family (if not using Google Fonts)
        ├── Inter-Regular.ttf
        ├── Inter-Medium.ttf
        ├── Inter-SemiBold.ttf
        └── Inter-Bold.ttf
```

### 10.2 pubspec.yaml Assets Section

```yaml
flutter:
  assets:
    - assets/images/illustrations/
    - assets/audio/
  
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter/Inter-Bold.ttf
          weight: 700
```

### 10.3 Image Requirements

| Asset | Format | Size | Background | Style |
|-------|--------|------|------------|-------|
| Empty states | SVG | 200x200dp | Transparent | Flat illustration, monochrome orange accent |
| App icon | PNG | 1024x1024 | White | Orange circle with white checkmark |
| Sound files | MP3 | < 50KB each | — | Short (< 1s for feedback, < 3s for completion) |

---

## 11. Implementation Roadmap

### Phase 1: Foundation (Week 1)

| Task | Priority | Est. Hours |
|------|----------|------------|
| Flutter project setup with folder structure | P0 | 2 |
| Design system: Colors, Typography, Theme | P0 | 4 |
| Shared widgets: AppButton, AppCard, AppBar | P0 | 4 |
| Data models (Question, QuizState, UserProgress, etc.) | P0 | 3 |
| SharedPreferences wrapper + Repository interfaces | P0 | 3 |
| Question data: 300 general questions (first 100) | P0 | 6 |
| Localization setup + German ARB file | P0 | 2 |
| **Phase 1 Total** | | **24h** |

### Phase 2: Core Features (Week 2)

| Task | Priority | Est. Hours |
|------|----------|------------|
| QuestionRepository + all question data (300 general + 160 state) | P0 | 10 |
| Splash Screen + Home Screen | P0 | 6 |
| Quiz Setup Screen | P0 | 3 |
| Quiz Active Screen (timer, navigation, answer selection) | P0 | 8 |
| Quiz Result Screen | P0 | 4 |
| Quiz Review Screen | P0 | 3 |
| QuizProvider implementation | P0 | 4 |
| **Phase 2 Total** | | **38h** |

### Phase 3: Learning & Statistics (Week 3)

| Task | Priority | Est. Hours |
|------|----------|------------|
| Learning Overview Screen | P0 | 5 |
| Learning Detail Screen | P0 | 6 |
| LearningProvider implementation | P0 | 4 |
| Statistics Screen with charts | P1 | 6 |
| StatisticsProvider implementation | P1 | 3 |
| Progress persistence (shared_preferences) | P0 | 3 |
| **Phase 3 Total** | | **27h** |

### Phase 4: Polish & Settings (Week 4)

| Task | Priority | Est. Hours |
|------|----------|------------|
| Settings Screen | P1 | 4 |
| SettingsProvider implementation | P1 | 2 |
| Dark theme implementation | P1 | 3 |
| Localization (EN, TR, AR) | P2 | 6 |
| RTL support for Arabic | P2 | 3 |
| Animations + micro-interactions | P2 | 4 |
| Sound effects integration | P2 | 2 |
| App icon + launch screen | P1 | 2 |
| **Phase 4 Total** | | **26h** |

### Phase 5: Testing & Release (Week 5)

| Task | Priority | Est. Hours |
|------|----------|------------|
| Widget tests for core components | P1 | 6 |
| Integration tests for quiz flow | P1 | 4 |
| Android build (APK + AAB) | P0 | 2 |
| Web build (PWA) | P1 | 2 |
| Performance optimization | P2 | 3 |
| Bug fixes + polish | P0 | 4 |
| **Phase 5 Total** | | **21h** |

**Total Estimated Effort: ~136 hours (~4-5 weeks at 70% capacity)**

### Milestones

| Milestone | Deliverable | Target |
|-----------|-------------|--------|
| M1 | Design system + Data layer + First 100 questions | End of Week 1 |
| M2 | Full quiz mode (setup → active → result → review) | End of Week 2 |
| M3 | Learning mode + Statistics + Progress persistence | End of Week 3 |
| M4 | Settings + Dark mode + Localization + Animations | End of Week 4 |
| M5 | Tested, optimized Android APK + Web PWA | End of Week 5 |

---

## 12. Appendix

### 12.1 pubspec.yaml Dependencies

```yaml
name: einbuergerungstest_pro
description: Einbuergerungstest Pro - Leben in Deutschland
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.16.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  provider: ^6.1.1

  # Local Storage
  shared_preferences: ^2.2.2

  # Internationalization
  intl: ^0.18.1
  flutter_intl: ^0.0.1

  # UI Components
  google_fonts: ^6.1.0           # Inter font via Google Fonts
  flutter_svg: ^2.0.9            # SVG illustration support

  # Charts & Visualization (choose one)
  fl_chart: ^0.66.0              # For statistics charts

  # Utilities
  collection: ^1.18.0
  equatable: ^2.0.5              # Value equality for models
  uuid: ^4.3.3                   # UUID generation for QuizResult IDs

  # Audio (optional)
  audioplayers: ^5.2.1           # Sound effects

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  generate: true
  
  assets:
    - assets/images/illustrations/
    - assets/audio/
```

### 12.2 Question Count Summary

| Category | General Questions | State Questions | Total |
|----------|-------------------|-----------------|-------|
| Verfassung | ~60 | — | 60 |
| Geschichte | ~50 | — | 50 |
| Recht | ~45 | — | 45 |
| Gesellschaft | ~40 | — | 40 |
| Politik | ~35 | — | 35 |
| Europa | ~25 | — | 25 |
| Wirtschaft | ~20 | — | 20 |
| Kultur | ~10 | — | 10 |
| Religion | ~8 | — | 8 |
| Allgemein | ~7 | — | 7 |
| **General Total** | **300** | **—** | **300** |
| **State Questions** | **—** | **160** (10 x 16) | **160** |
| **GRAND TOTAL** | **300** | **160** | **460** |

### 12.3 Performance Budget

| Metric | Target |
|--------|--------|
| App Launch (cold) | < 2 seconds |
| Question navigation | < 100ms |
| Screen transitions | < 300ms |
| Quiz generation | < 500ms |
| APK size | < 25 MB |
| Web PWA initial load | < 3 seconds (fast 3G) |
| Memory usage (peak) | < 150 MB |

### 12.4 Accessibility Requirements

- All interactive elements minimum 48x48dp touch target
- Color contrast ratio >= 4.5:1 for all text
- Screen reader labels for all icons and images (`semanticLabel`)
- Support system font size scaling (`MediaQuery.textScaleFactor`)
- Focus indicators visible for keyboard navigation
- Timer announcements for screen readers (remaining time)

### 12.5 Edge Cases Checklist

- [ ] User closes app during quiz → resume on next launch
- [ ] Timer reaches 0 → auto-submit
- [ ] All questions answered before time → highlight submit
- [ ] No state selected → prompt on home screen
- [ ] Only 1 question in filtered learning list → hide prev/next
- [ ] Progress reset during active quiz → clear backup
- [ ] Device rotation during quiz → preserve state
- [ ] Dark mode toggle while in quiz → smooth transition
- [ ] Language change while learning → preserve position
- [ ] Bookmarked question deleted (edge case) → gracefully handle
- [ ] SharedPreferences corruption → reset to defaults + toast
- [ ] First launch with no data → show welcome state
- [ ] Quiz with 0 correct answers → show encouraging message
- [ ] Quiz with 33 correct answers → show maximum celebration

### 12.6 File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Screens | `{feature}_screen.dart` | `home_screen.dart` |
| Widgets | Descriptive noun | `progress_overview_card.dart` |
| Providers | `{feature}_provider.dart` | `quiz_provider.dart` |
| Models | Singular noun | `question.dart` |
| Repositories | `{feature}_repository.dart` | `question_repository.dart` |
| Data sources | `questions_{code}.dart` | `questions_by.dart` |
| Constants | `app_{category}.dart` | `app_colors.dart` |
| Tests | `{file}_test.dart` | `quiz_provider_test.dart` |

### 12.7 Code Style Guide

- Follow official Dart style guide
- Use `const` constructors wherever possible
- Prefer `StatelessWidget` over `StatefulWidget`
- Use `Consumer` or `Selector` for granular rebuilds (not full `context.watch`)
- Extract magic numbers to constants
- Maximum method length: 50 lines
- Maximum widget nesting: 7 levels (extract sub-widgets)
- Documentation comments for all public APIs
- Trailing commas for multi-line parameter lists

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2025-01-20 | AI Assistant | Initial specification |

---

*End of SPEC.md — Einbuergerungstest Pro: Leben in Deutschland*
