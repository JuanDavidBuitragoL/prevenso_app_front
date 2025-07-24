// -------------------------------------------------------------------
// features/rates/presentation/pages/rate_detail_page.dart
// La pantalla para ver los detalles de una tarifa específica.

import 'package:flutter/material.dart';
import 'edit_rate_page.dart';
import 'rates_page.dart'; // Importamos la clase Rate

class RateDetailPage extends StatelessWidget {
  // La página recibe el objeto 'Rate' para saber qué información mostrar.
  final Rate rate;

  const RateDetailPage({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El logo se muestra en la AppBar para consistencia.
        title: Image.asset(
          'assets/images/logo-inicio.png', // Asegúrate que la ruta es correcta
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
              'Información de la tarifa',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Campos de información (no editables)
            _InfoField(label: 'Nombre', value: rate.title),
            const SizedBox(height: 20),
            // Asumimos un valor de duración de ejemplo
            const _InfoField(label: 'Duración', value: '16 horas'),
            const SizedBox(height: 20),
            _InfoField(label: 'Valor', value: '\$${rate.price}'),
            const Spacer(), // Empuja los botones hacia abajo
            // Botón de Editar Tarifa
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar navegación a una pantalla de edición
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F54EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navega a la pantalla de edición, pasando la tarifa actual
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditRatePage(rate: rate)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F54EB),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('Editar tarifa', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botón de Eliminar Tarifa
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implementar lógica para mostrar diálogo de confirmación y eliminar
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Eliminar tarifa', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Un widget reutilizable para mostrar los campos de información.
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
        // Usamos un TextFormField deshabilitado para lograr el estilo del borde.
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
