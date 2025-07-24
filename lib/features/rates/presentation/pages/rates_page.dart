// -------------------------------------------------------------------
// features/rates/presentation/pages/rates_page.dart
// --- ARCHIVO MODIFICADO ---
// Se convierte en una página independiente y autocontenida con su propio Scaffold.

import 'package:flutter/material.dart';
import '../widgets/rate_card.dart';
import 'create_rate_page.dart';

class Rate {
  final String title;
  final String price;
  final Color color;
  final IconData icon;

  Rate({required this.title, required this.price, required this.color, required this.icon});
}

class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Rate> rates = [
      Rate(title: 'Trabajador Entrante', price: '550.000', color: const Color(0xFFFFF3E0), icon: Icons.work_outline),
      Rate(title: 'Vigía de Seguridad', price: '500.000', color: const Color(0xFFE3F2FD), icon: Icons.security_outlined),
      Rate(title: 'Supervisor', price: '650.000', color: const Color(0xFFE8F5E9), icon: Icons.supervisor_account_outlined),
      Rate(title: 'Manejo del Estrés', price: '150.000', color: const Color(0xFFF3E5F5), icon: Icons.self_improvement_outlined),
      Rate(title: 'Primeros Auxilios', price: '200.000', color: const Color(0xFFFFF3E0), icon: Icons.medical_services_outlined),
      Rate(title: 'Manejo de Extintores', price: '180.000', color: const Color(0xFFE3F2FD), icon: Icons.fire_extinguisher_outlined),
    ];

    // --- CORRECCIÓN DEFINITIVA: Se envuelve en un Scaffold ---
    // Esto proporciona el contexto de Material y los límites de layout necesarios.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifas'),
        // El botón de regreso es añadido automáticamente por el Navigator.
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // La barra de búsqueda ahora funciona correctamente.
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF9A825), Color(0xFFF57F17)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navega a la pantalla de creación de tarifa
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateRatePage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Crear nueva tarifa',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // El Expanded ahora funciona porque el Scaffold le da límites al Column.
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9,
                ),
                itemCount: rates.length,
                itemBuilder: (context, index) {
                  return RateCard(rate: rates[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}