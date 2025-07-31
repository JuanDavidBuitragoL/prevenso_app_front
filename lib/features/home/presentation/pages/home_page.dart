// -------------------------------------------------------------------
// features/home/presentation/pages/home_page.dart
// Se ajusta el espaciado para la nueva AppBar.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/action_buttons_grid.dart';
import '../widgets/recent_quotes_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Consumer para acceder al AuthProvider y reconstruir si cambia.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.user?.nombre_usuario ?? 'Usuario';
        final firstName = userName.split(' ').first;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // --- Saludo Dinámico ---
                Text(
                  'Hola, $firstName',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A55A2),
                  ),
                ),
                const SizedBox(height: 30),
                const ActionButtonsGrid(),
                const SizedBox(height: 40),
                const RecentQuotesSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
