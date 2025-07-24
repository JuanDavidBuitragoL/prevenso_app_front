// -------------------------------------------------------------------
// features/auth/presentation/pages/login_page.dart
// --- ARCHIVO MODIFICADO ---
// La página ahora es responsable de posicionar el logo fijo en la parte superior.

import 'package:flutter/material.dart';
import '../../../../core/utils/app_assets.dart';
import '../widgets/curved_background.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: screenSize.height,
        width: screenSize.width,
        child: const Stack(
          children: [
            // Fondo y formulario siguen como antes
            CurvedBackground(),
            LoginForm(),

            // El logo ahora es un widget fijo dentro del Stack.
            // No se moverá al hacer scroll en el formulario.
            Positioned(
              top: 20, // Espacio desde la parte superior (considerando la barra de estado)
              left: 20, // Espacio desde la izquierda (alineado con el formulario)
              child: Image(
                image: AssetImage(AppAssets.logo),
                height: 45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
