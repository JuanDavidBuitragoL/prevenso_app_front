// -------------------------------------------------------------------
// features/rates/presentation/widgets/rate_card.dart
// El widget que representa una tarjeta de tarifa individual en la cuadrícula.

import 'package:flutter/material.dart';
import '../pages/rate_detail_page.dart';
import '../pages/rates_page.dart';

class RateCard extends StatelessWidget {
  final Rate rate;

  const RateCard({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navega a la página de detalles, pasando la información de la tarifa seleccionada.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RateDetailPage(rate: rate)),
        );
      },
      borderRadius: BorderRadius.circular(20), // Para que el efecto ripple coincida con el borde
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: rate.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white.withOpacity(0.7),
              child: Icon(rate.icon, size: 28, color: const Color(0xFF00C6AD)),
            ),
            const Spacer(),
            Text(
              rate.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${rate.price}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}