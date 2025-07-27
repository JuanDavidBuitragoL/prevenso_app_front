// -------------------------------------------------------------------
// features/services/presentation/pages/service_detail_page.dart
// --- NUEVO ARCHIVO ---
// La pantalla para ver los detalles de un servicio específico.

import 'package:flutter/material.dart';
import 'edit_service_page.dart';
import 'services_page.dart'; // Importamos la clase Service

class ServiceDetailPage extends StatelessWidget {
  final Service service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del servicio',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00C6AD)),
            ),
            const SizedBox(height: 30),
            // Campos de información
            _InfoField(label: 'Nombre', value: service.title),
            const SizedBox(height: 20),
            _InfoField(label: 'Tipo', value: service.type),
            const SizedBox(height: 20),
            _InfoField(label: 'Duración', value: service.duration),
            const Spacer(),
            // Botón de Editar Servicio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de edición, pasando el servicio actual
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditServicePage(service: service)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F54EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Editar servicio', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            // Botón de Eliminar Servicio
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implementar lógica para eliminar
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Eliminar servicio', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para los campos de información
class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
