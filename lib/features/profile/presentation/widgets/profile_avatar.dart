// -------------------------------------------------------------------
// features/profile/presentation/widgets/profile_avatar.dart
// Un widget personalizado para mostrar el avatar con círculos decorativos.

import 'dart:math';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;

  const ProfileAvatar({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2.8,
      height: radius * 2.8,
      child: CustomPaint(
        painter: _CirclePainter(
          color: const Color(0xFF8B93FF).withOpacity(0.5),
        ),
        child: Center(
          child: CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFF8B93FF).withOpacity(0.3),
            child: Icon(
              Icons.person,
              size: radius,
              color: const Color(0xFF8B93FF),
            ),
          ),
        ),
      ),
    );
  }
}

// CustomPainter para dibujar los círculos discontinuos de fondo.
class _CirclePainter extends CustomPainter {
  final Color color;
  _CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibuja los círculos discontinuos
    _drawDashedCircle(canvas, center, size.width / 2.2, 20, paint);
    _drawDashedCircle(canvas, center, size.width / 2.8, 15, paint);
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, int dashCount, Paint paint) {
    const double dashSpace = 10;
    final double dashWidth = (2 * pi * radius - dashCount * dashSpace) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) / radius;
      final sweepAngle = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}