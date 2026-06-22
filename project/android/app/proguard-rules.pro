# Flutter spezifische ProGuard Regeln
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Keep shared_preferences
-keep class com.shared_preferences.** { *; }

# Keep url_launcher
-keep class com.url_launcher.** { *; }

# Keep Provider / ChangeNotifier
-keep class * extends androidx.lifecycle.ViewModel { *; }
-dontwarn androidx.lifecycle.**

# Play Core (Deferred Component Management)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# R8 allgemein: keine Missing-Class-Warnings zu Fehlern machen
-dontwarn **
