// -------------------------------------------------------------------
// features/main_screen.dart
// --- ARCHIVO MODIFICADO ---
// Se simplifica la lógica de navegación del BottomNavigationBar.

import 'package:flutter/material.dart';
import 'home/presentation/pages/home_page.dart';
import 'rates/presentation/pages/rates_page.dart';
import '../core/utils/app_assets.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // La lista ahora solo necesita la HomePage. Las otras son placeholders.
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Center(child: Text('Placeholder para Tarifas')), // Este no se usará
    Center(child: Text('Placeholder para Cotizar')), // Este no se usará
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      // Si se presiona el segundo botón, navegamos a la página de Tarifas.
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RatesPage()));
    } else {
      // Para los otros botones, solo cambiamos el índice (si hubiera más páginas principales).
      setState(() {
        _selectedIndex = index;
      });
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
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            activeIcon: Icon(Icons.edit),
            label: 'Tarifas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Cotizar',
          ),
        ],
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
