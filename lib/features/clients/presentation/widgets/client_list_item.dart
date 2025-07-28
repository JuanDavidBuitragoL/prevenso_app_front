// -------------------------------------------------------------------
// features/clients/presentation/widgets/client_list_item.dart
// --- ARCHIVO MODIFICADO ---
// Se hace interactivo para navegar a la pantalla de detalles.

// ARCHIVO: lib/features/clients/presentation/widgets/client_list_item.dart (VERSIÓN FINAL)

import 'package:flutter/material.dart';
import '../../domain/entities/client_model.dart';

// --- Lógica para asignar colores e íconos dinámicamente ---
Color _getColorForClient(String clientName) {
  final hash = clientName.hashCode;
  final colors = [
    const Color(0xFFFEECEB), const Color(0xFFEBF1FF), const Color(0xFFE8F5E9),
    const Color(0xFFF3E5F5), const Color(0xFFE0F2F1), const Color(0xFFFFFDE7)
  ];
  return colors[hash % colors.length];
}

IconData _getIconForClient(String clientName) {
  final lower = clientName.toLowerCase();
  if (lower.contains('constructora')) return Icons.engineering_outlined;
  if (lower.contains('muebles')) return Icons.chair_outlined;
  if (lower.contains('union')) return Icons.groups_2_outlined;
  return Icons.business_outlined;
}

class ClientListItem extends StatelessWidget {
  final ClientModel client;
  final VoidCallback onTap;

  const ClientListItem({super.key, required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getColorForClient(client.nombre),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(_getIconForClient(client.nombre), color: Colors.black54, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.nombre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (client.nit != null && client.nit!.isNotEmpty)
                    Text(
                      'NIT: ${client.nit}',
                      style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.6)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
