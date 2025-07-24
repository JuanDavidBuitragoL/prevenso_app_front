// --- PASO 2.1: Crear la nueva Splash Page ---
// ARCHIVO: lib/features/auth/presentation/pages/splash_page.dart (NUEVO ARCHIVO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import '../../../main_screen.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para escuchar el estado de carga del AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Mientras está cargando, mostramos un indicador
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Cuando termina de cargar, decidimos a dónde navegar
        if (authProvider.isLoggedIn) {
          return const MainScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
