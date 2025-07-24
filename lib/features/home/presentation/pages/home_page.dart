// -------------------------------------------------------------------
// features/home/presentation/pages/home_page.dart
// Se ajusta el espaciado para la nueva AppBar.

import 'package:flutter/material.dart';
import '../widgets/action_buttons_grid.dart';
import '../widgets/recent_quotes_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Hola, Juan',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A55A2),
              ),
            ),
            SizedBox(height: 30),
            ActionButtonsGrid(),
            SizedBox(height: 40),
            RecentQuotesSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}