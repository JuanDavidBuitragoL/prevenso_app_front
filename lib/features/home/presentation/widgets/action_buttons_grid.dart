
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Lista de datos de los botones
    final buttons = [
      _ButtonData(
        icon: Icons.person_outline,
        label: 'Configurar perfil',
        color: const Color(0xFF8B93FF),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        ),
      ),
      _ButtonData(
        icon: Icons.edit_outlined,
        label: 'Editar tarifas',
        color: const Color(0xFF88E2D6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RatesPage()),
        ),
      ),
      _ButtonData(
        icon: Icons.add_box_outlined,
        label: 'Cotizaciones',
        color: Colors.white,
        iconColor: Colors.black,
        hasBorder: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuotesPage()),
        ),
      ),
      _ButtonData(
        icon: Icons.business_outlined,
        label: 'Editar Clientes',
        color: const Color(0xFFE2A9A9),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClientsPage()),
        ),
      ),
      _ButtonData(
        icon: Icons.design_services_outlined,
        label: 'Editar servicios',
        color: const Color(0xFFC5A9E2),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ServicesPage()),
        ),
      ),
    ];

    // 🔑 DECISIÓN: Pantallas < 600px usan Grid, pantallas >= 600px usan Wrap
    if (screenWidth < 600) {
      // MÓVIL: Usa GridView para centrado perfecto
      return _MobileGrid(buttons: buttons);
    } else {
      // ESCRITORIO: Usa Wrap compacto como antes
      return _DesktopWrap(buttons: buttons);
    }
  }
}

// Widget para MÓVIL (Grid centrado)
class _MobileGrid extends StatelessWidget {
  final List<_ButtonData> buttons;

  const _MobileGrid({required this.buttons});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (24 * 2);
    const buttonWidth = 156.0;
    const spacing = 24.0;

    int crossAxisCount = (availableWidth / (buttonWidth + spacing)).floor();
    if (crossAxisCount < 2) crossAxisCount = 2;
    if (crossAxisCount > 3) crossAxisCount = 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.85,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final button = buttons[index];
        return GestureDetector(
          onTap: button.onTap,
          child: _ActionButton(
            icon: button.icon,
            label: button.label,
            color: button.color,
            iconColor: button.iconColor,
            hasBorder: button.hasBorder,
          ),
        );
      },
    );
  }
}

// Widget para ESCRITORIO (Wrap compacto)
class _DesktopWrap extends StatelessWidget {
  final List<_ButtonData> buttons;

  const _DesktopWrap({required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24.0,
      runSpacing: 24.0,
      alignment: WrapAlignment.start, // Alineación a la izquierda para escritorio
      children: buttons.map((button) {
        return GestureDetector(
          onTap: button.onTap,
          child: SizedBox(
            width: 156,
            child: _ActionButton(
              icon: button.icon,
              label: button.label,
              color: button.color,
              iconColor: button.iconColor,
              hasBorder: button.hasBorder,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Clase auxiliar para almacenar datos de cada botón
class _ButtonData {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final bool hasBorder;
  final VoidCallback onTap;

  _ButtonData({
    required this.icon,
    required this.label,
    required this.color,
    this.iconColor = Colors.white,
    this.hasBorder = false,
    required this.onTap,
  });
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
    this.iconColor = Colors.white,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder
                ? Border.all(color: Colors.grey.shade300, width: 2)
                : null,
            boxShadow: hasBorder
                ? null
                : [
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}