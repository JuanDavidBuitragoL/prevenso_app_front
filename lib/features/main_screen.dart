// =============================================================================
// ARCHIVO: features/main_screen.dart (VERSIÓN CORREGIDA)
// FUNCIÓN:   Corrige la lógica de navegación para asegurar que al presionar
//            "atrás" siempre se regrese a la pantalla de inicio.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:prevenso_app_front/features/quotes/presentation/pages/quotes_page.dart';
import 'home/presentation/pages/home_page.dart';
import 'rates/presentation/pages/rates_page.dart';
import '../core/utils/app_assets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // El índice seleccionado siempre será 0 (Inicio), ya que las otras
  // opciones navegan a pantallas completamente nuevas.
  final int _selectedIndex = 0;

  // --- CAMBIO CLAVE: La lista ahora solo contiene la HomePage ---
  // Los placeholders se eliminan, ya que eran la causa del problema.
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
  ];

  // --- CAMBIO CLAVE: La lógica de navegación se simplifica ---
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
      // Si se presiona "Inicio" y ya estamos en Inicio, no hacemos nada.
        break;
      case 1:
      // Navegamos a la página de Tarifas como una nueva pantalla.
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RatesPage()));
        break;
      case 2:
      // Navegamos a la página de Cotizaciones como una nueva pantalla.
        Navigator.push(context, MaterialPageRoute(builder: (context) => const QuotesPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        title: Image.asset(
          AppAssets.logo,
          height: 40,
        ),
        automaticallyImplyLeading: false,
      ),
      // El cuerpo siempre muestra el widget en la posición 0 (HomePage)
      body: _widgetOptions.elementAt(0),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined), // Ícono cambiado para claridad
            activeIcon: Icon(Icons.monetization_on),
            label: 'Tarifas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote_outlined), // Ícono cambiado para claridad
            activeIcon: Icon(Icons.request_quote),
            label: 'Cotizar',
          ),
        ],
        // El ícono seleccionado siempre será el de "Inicio"
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFF0F0F0),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
