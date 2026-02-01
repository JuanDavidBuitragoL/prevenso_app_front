
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
  final int _selectedIndex = 0;

  // 🔑 Key para forzar la reconstrucción del HomePage
  Key _homePageKey = UniqueKey();

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
      // Si se presiona "Inicio" y ya estamos en Inicio, refrescamos
        setState(() {
          _homePageKey = UniqueKey(); // Forzar reconstrucción
        });
        break;
      case 1:
      // Navegamos a la página de Tarifas
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RatesPage()),
        );
        // 🔄 Al regresar, refrescamos el HomePage
        setState(() {
          _homePageKey = UniqueKey();
        });
        break;
      case 2:
      // Navegamos a la página de Cotizaciones
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuotesPage()),
        );
        // 🔄 Al regresar, refrescamos el HomePage
        setState(() {
          _homePageKey = UniqueKey();
        });
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
      // 🔑 Usamos la key para forzar reconstrucción
      body: HomePage(key: _homePageKey),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            activeIcon: Icon(Icons.monetization_on),
            label: 'Tarifas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_quote_outlined),
            activeIcon: Icon(Icons.request_quote),
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