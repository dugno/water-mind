# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.firebase.** { *; }

# Awesome Notifications
-keep class com.awesome_notifications.** { *; }

# Drift
-keep class vie.tech.water.mind.data.** { *; }

# Freezed models
-keep class vie.tech.water.mind.domain.models.** { *; }
-keep class vie.tech.water.mind.domain.entities.** { *; }

# Keep your model classes if you're using JSON serialization
-keepattributes *Annotation*
-keepattributes Signature
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
