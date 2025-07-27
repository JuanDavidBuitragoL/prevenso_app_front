// -------------------------------------------------------------------
// features/services/presentation/widgets/service_list_item.dart
// --- ARCHIVO MODIFICADO ---
// Se hace interactivo para navegar a la pantalla de detalles.

import 'package:flutter/material.dart';
import '../pages/services_page.dart';
import '../pages/service_detail_page.dart'; // Importa la nueva página de detalles

class ServiceListItem extends StatelessWidget {
  final Service service;

  const ServiceListItem({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navega a la pantalla de detalles, pasando el objeto 'service'
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ServiceDetailPage(service: service)),
        );
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: service.color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.star, color: Colors.amber, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                service.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar navegación a la pantalla de edición de servicio
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Editar'),
            ),
          ],
        ),
      ),
    );
  }
}

