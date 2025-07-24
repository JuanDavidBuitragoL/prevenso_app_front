import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/pages/splash_page.dart'; // <-- Importar SplashPage
import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';

void main() {
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
      home: const SplashPage(), // <-- La app ahora empieza aquí
      debugShowCheckedModeBanner: false,
    );
  }
}