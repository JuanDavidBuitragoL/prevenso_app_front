//            acepta los callbacks 'onTap' y 'onEdit' en su constructor.

import 'package:flutter/material.dart';
import '../../domain/entities/service_model.dart';

Color _getColorForServiceType(String type) {
  switch (type.toLowerCase()) {
    case 'curso':
      return const Color(0xFFEBF1FF);
    case 'examen':
      return const Color(0xFFFEECEB);
    case 'taller':
      return const Color(0xFFE8F5E9);
    case 'certificación':
      return const Color(0xFFFFF3E0);
    default:
      return Colors.grey.shade200;
  }
}

IconData _getIconForServiceType(String type) {
  switch (type.toLowerCase()) {
    case 'curso':
      return Icons.school_outlined;
    case 'examen':
      return Icons.medical_services_outlined;
    default:
      return Icons.star_outline;
  }
}

class ServiceListItem extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;  // <-- Parámetro para ir a detalles
  final VoidCallback onEdit; // <-- Parámetro para ir a editar

    // Ahora se definen los parámetros 'onTap' y 'onEdit' para que puedan ser recibidos.
  const ServiceListItem({
    super.key,
    required this.service,
    required this.onTap,
    required this.onEdit
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Llama al callback de detalle
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getColorForServiceType(service.tipo),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(
                  _getIconForServiceType(service.tipo),
                  color: Colors.blueGrey.shade600,
                  size: 24
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                service.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

          ],
        ),
      ),
    );
  }
}
