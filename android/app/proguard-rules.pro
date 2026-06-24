# Add project specific ProGuard rules here.

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Keep SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Keep TTS
-keep class com.google.android.tts.** { *; }

# Keep your app classes
-keep class com.notivaai.notifications.** { *; }
