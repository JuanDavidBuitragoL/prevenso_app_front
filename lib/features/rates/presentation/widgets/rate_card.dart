// =============================================================================
// ARCHIVO: features/rates/presentation/widgets/rate_card.dart (VERSIÓN CORREGIDA)
// FUNCIÓN:   Componente visual para una tarjeta de tarifa. Se ha reestructurado
//            con un Expanded para evitar errores de desbordamiento de layout.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/rate_model.dart';

// Lógica para asignar colores e íconos dinámicamente
Color _getColorForService(String serviceName) {
  final hash = serviceName.hashCode;
  final colors = [
    const Color(0xFFFFF3E0), const Color(0xFFE3F2FD), const Color(0xFFE8F5E9),
    const Color(0xFFF3E5F5), const Color(0xFFFFEBEE), const Color(0xFFE0F7FA)
  ];
  return colors[hash % colors.length];
}

IconData _getIconForService(String serviceName) {
  final lowerCaseName = serviceName.toLowerCase();
  if (lowerCaseName.contains('vigía')) return Icons.security_outlined;
  if (lowerCaseName.contains('supervisor')) return Icons.supervisor_account_outlined;
  if (lowerCaseName.contains('estrés')) return Icons.self_improvement_outlined;
  if (lowerCaseName.contains('auxilios')) return Icons.medical_services_outlined;
  if (lowerCaseName.contains('extintores')) return Icons.fire_extinguisher_outlined;
  return Icons.work_outline;
}

class RateCard extends StatelessWidget {
  final RateModel rate;
  final VoidCallback onTap;

  const RateCard({super.key, required this.rate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final formattedPrice = currencyFormatter.format(double.parse(rate.costo));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getColorForService(rate.nombreServicio),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white.withOpacity(0.7),
              child: Icon(
                _getIconForService(rate.nombreServicio),
                size: 28,
                color: const Color(0xFF00C6AD),
              ),
            ),
            // --- CORRECCIÓN: Se usa Expanded para que el contenido de texto ocupe el espacio restante ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end, // Alinea el contenido a la parte inferior del espacio
                children: [
                  Text(
                    rate.nombreServicio,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.black.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          rate.ciudad,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
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
