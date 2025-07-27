// -------------------------------------------------------------------
// features/home/presentation/widgets/action_buttons_grid.dart
// --- ARCHIVO MODIFICADO ---
// Se añade el nuevo botón "Editar servicios" a la cuadrícula.

import 'package:flutter/material.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../rates/presentation/pages/rates_page.dart';
import '../../../services/presentation/pages/services_page.dart';

class ActionButtonsGrid extends StatelessWidget {
  const ActionButtonsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 10,
      childAspectRatio: 0.8,
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
            // Esta navegación debería cambiar el índice del MainScreen o usar un gestor de estado.
            // Por ahora, lo dejamos como una navegación a una página independiente.
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RatesPage()));
          },
          child: const _ActionButton(icon: Icons.edit_outlined, label: 'Editar tarifas', color: Color(0xFF88E2D6)),
        ),
        // Botón Crear Cotización
        const _ActionButton(icon: Icons.add_box_outlined, label: 'Crear cotización', color: Colors.white, iconColor: Colors.black, hasBorder: true),

        // Botón Editar Clientes
        const _ActionButton(icon: Icons.business_outlined, label: 'Editar Clientes', color: Color(0xFFE2A9A9)),

        GestureDetector(
          onTap: () {
            // Navega a la nueva página de Servicios
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

// El widget _ActionButton se mantiene igual.
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
    this.iconColor = Colors.white,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
