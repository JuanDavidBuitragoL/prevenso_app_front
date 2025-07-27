// -------------------------------------------------------------------
// features/services/presentation/pages/services_page.dart
// --- ARCHIVO MODIFICADO ---
// Se actualiza el modelo 'Service' y la lista de datos de ejemplo.

import 'package:flutter/material.dart';
import '../widgets/service_list_item.dart';
import 'create_service_page.dart';

// --- CAMBIO: Se añaden nuevos campos al modelo ---
class Service {
  final String title;
  final String type;
  final String duration;
  final Color color;

  Service({
    required this.title,
    required this.type,
    required this.duration,
    required this.color,
  });
}

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- CAMBIO: Se actualiza la lista de datos de ejemplo ---
    final List<Service> services = [
      Service(title: 'Trabajador Entrante', type: 'Examen', duration: '12 horas', color: const Color(0xFFFEECEB)),
      Service(title: 'Supervisor', type: 'Capacitación', duration: '24 horas', color: const Color(0xFFEBF1FF)),
      Service(title: 'Manejo del Estrés', type: 'Taller', duration: '8 horas', color: const Color(0xFFE8F5E9)),
      Service(title: 'Alturas', type: 'Certificación', duration: '40 horas', color: const Color(0xFFFFF3E0)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo-inicio.png',
          height: 40,
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Servicios',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // --- CAMBIO AQUÍ ---
                onPressed: () {
                  // Navega a la pantalla de creación de servicio
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateServicePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE87A5A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 2,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ServiceListItem(service: services[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}