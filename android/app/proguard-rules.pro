# =============================================================================
# ARCHIVO: android/app/proguard-rules.pro (VERSIÓN DEFINITIVA Y COMPLETA)
# FUNCIÓN:   Contiene las reglas para "proteger" el código de los plugins y
#            las librerías de Google Play Core necesarias para Flutter.
# =============================================================================

# Reglas estándar de Flutter.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- REGLAS ESPECÍFICAS PARA LOS PLUGINS (LA PARTE MÁS IMPORTANTE) ---

# Regla para open_file y open_filex (protege el canal 'open_file')
-keep class com.crazecoder.openfile.** { *; }
-keep class com.crazecoder.openfilex.** { *; }

# Regla para path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Regla para flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Regla para permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# Reglas para las librerías de Google Play Core (soluciona errores de R8)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# --- Reglas generales de buena práctica ---
-keepattributes Signature
-keepattributes *Annotation*
-keepclasseswithmembernames class * {
    native <methods>;
}
