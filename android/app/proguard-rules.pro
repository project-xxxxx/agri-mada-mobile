# Règles ProGuard pour AgriMada (Flutter)
# Nécessaire pour éviter que R8 ne casse les dépendances en Release (Isar, TFLite, etc)

# Isar DB
-keep class isar.** { *; }
-keep class dev.isar.** { *; }

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }

# Flutter Wrapper / JNI
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Android Lifecycle
-keep class androidx.lifecycle.** { *; }

# Google Play Core (referenced by Flutter embedding engine but might be absent)
-dontwarn com.google.android.play.core.**
