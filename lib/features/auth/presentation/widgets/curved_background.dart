// -------------------------------------------------------------------
// features/auth/presentation/widgets/curved_background.dart
// --- ARCHIVO MODIFICADO ---
// Widget dedicado al fondo. Ahora posicionado solo en la esquina inferior derecha.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_assets.dart';

class CurvedBackground extends StatelessWidget {
  const CurvedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Usamos Positioned para anclar el widget en la esquina inferior derecha.
    return Positioned(
      bottom: 0,
      right: 0,
      child: ClipPath(
        // Usamos un nuevo clipper que solo redondea la esquina superior izquierda.
        clipper: _CornerClipper(),
        child: Container(
          // Definimos el tamaño del área curvada.
          width: screenSize.width * 0.8,
          height: screenSize.height * 0.55,
          color: AppTheme.secondaryColor,
          child: Stack(
            clipBehavior: Clip.none, // Permite que la imagen se salga un poco si es necesario
            children: [
              // Posicionamos la ilustración dentro del nuevo contenedor.
              Positioned(
                bottom: 0,
                right: 5,
                child: Image.asset(
                  AppAssets.doctorIllustration,
                  height: screenSize.height * 0.3,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: screenSize.height * 0.4,
                      width: screenSize.width * 0.6,
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: Text('Ilustración no encontrada')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Nuevo CustomClipper para crear la forma de la esquina.
class _CornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Inicia en la esquina inferior izquierda del contenedor.
    path.moveTo(0, size.height);
    // Dibuja una línea hacia la esquina inferior derecha.
    path.lineTo(size.width, size.height);
    // Dibuja una línea hacia la esquina superior derecha.
    path.lineTo(size.width, 0);
    // Dibuja la curva. Esta curva va desde la esquina superior derecha
    // hasta la esquina inferior izquierda, usando el punto (0,0) como
    // punto de control, lo que crea un arco cóncavo.
    path.quadraticBezierTo(0, 0, 0, size.height);
    // Cierra el trazado.
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
