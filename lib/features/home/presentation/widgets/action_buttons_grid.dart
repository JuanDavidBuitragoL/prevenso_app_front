// =============================================================================
// ARCHIVO: features/home/presentation/widgets/action_buttons_grid.dart (VERSIÓN FINAL)
// FUNCIÓN:   Combina la navegación funcional con un layout responsivo usando Wrap,
//            asegurando una visualización óptima en todos los dispositivos.
// =============================================================================

import 'package:flutter/material.dart';
import '../../../clients/presentation/pages/clients_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../quotes/presentation/pages/quotes_page.dart';
import '../../../rates/presentation/pages/rates_page.dart';
import '../../../services/presentation/pages/services_page.dart';

class ActionButtonsGrid extends StatelessWidget {
  const ActionButtonsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Wrap para que los botones se organicen horizontalmente y salten
    // a la siguiente línea si no hay espacio. Es ideal para un layout responsivo.
    return Wrap(
      spacing: 24.0, // Espacio horizontal entre botones
      runSpacing: 24.0, // Espacio vertical si hay más de una fila
      alignment: WrapAlignment.center, // Centra los botones en el espacio disponible
      children: [
        // Botón Configurar Perfil
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          },
          child: const _ActionButton(icon: Icons.person_outline, label: 'Configurar perfil', color: Color(0xFF8B93FF)),
        ),
        // Botón Editar Tarifas
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RatesPage()));
          },
          child: const _ActionButton(icon: Icons.edit_outlined, label: 'Editar tarifas', color: Color(0xFF88E2D6)),
        ),
        // Botón Crear Cotización
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuotesPage()),
            );
          },
          child: const _ActionButton(icon: Icons.add_box_outlined, label: 'Cotizaciones', color: Colors.white, iconColor: Colors.black, hasBorder: true),
        ),
        // Botón Editar Clientes
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClientsPage()),
            );
          },
          child: const _ActionButton(icon: Icons.business_outlined, label: 'Editar Clientes', color: Color(0xFFE2A9A9)),
        ),
        // Botón Editar Servicios
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ServicesPage()),
            );
          },
          child: const _ActionButton(icon: Icons.design_services_outlined, label: 'Editar servicios', color: Color(0xFFC5A9E2)),
        ),
      ],
    );
  }
}

// Widget interno para cada botón
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final bool hasBorder;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.iconColor = Colors.white, // Color de ícono por defecto es blanco
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    // Se envuelve en un SizedBox para darle un ancho consistente a cada botón.
    return SizedBox(
      width: 140, // Ancho fijo para que los botones sean uniformes
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: hasBorder ? Border.all(color: Colors.grey.shade300, width: 2) : null,
              boxShadow: hasBorder ? null : [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 35, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

