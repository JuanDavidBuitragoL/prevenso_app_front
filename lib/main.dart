// --- PASO 2.1: Configurar la localización en main.dart ---
// ARCHIVO: lib/main.dart (VERSIÓN FINAL Y CORRECTA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- Importar la nueva librería
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';

void main() {
  // Asegura que los bindings de Flutter estén inicializados antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Establece el modo de UI inmersivo para ocultar las barras del sistema
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotizador App',
      theme: AppTheme.lightTheme,

      // --- Se añade la configuración de localización ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CO'), // Español de Colombia
      ],
      locale: const Locale('es', 'CO'),
      // ---------------------------------------------------------------------

      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
