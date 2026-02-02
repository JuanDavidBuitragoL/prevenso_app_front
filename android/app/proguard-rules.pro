
# =============================================================================
# ARCHIVO: android/app/proguard-rules.pro (VERSIÓN CORREGIDA)
# FUNCIÓN: Reglas de ofuscación para Flutter sin dependencias innecesarias
# =============================================================================

# Reglas estándar de Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantener anotaciones básicas (SIN Gson)
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# ✅ Plugins específicos de tu app
-keep class com.crazecoder.openfile.** { *; }
-keep class com.crazecoder.openfilex.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }

# Reglas para HTTP (nativo de Flutter)
-keep class io.flutter.plugin.http.** { *; }

# Google Play Core (si usas app bundles)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Mantener métodos nativos
-keepclasseswithmembernames class * {
    native <methods>;
}

# Optimizaciones seguras para Flutter
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 3
-allowaccessmodification
-dontpreverify

# Evitar warnings de librerías externas
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**