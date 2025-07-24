// -------------------------------------------------------------------
// features/home/presentation/widgets/recent_quotes_section.dart
// Widget para la sección de "Cotizaciones recientes".

import 'package:flutter/material.dart';

class RecentQuotesSection extends StatelessWidget {
  const RecentQuotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cotizaciones recientes',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _QuoteCard(
          title: 'Cotización para la empresa J.F muebles',
          date: 'Sábado, Mayo 19',
          color: const Color(0xFF4A55A2),
          onPressed: () {},
        ),
        const SizedBox(height: 15),
        _QuoteCard(
          title: 'Cotización para la empresa MDS',
          date: 'Viernes, Enero 10',
          color: const Color(0xFFE87A5A),
          onPressed: () {},
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Ver todas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String title;
  final String date;
  final Color color;
  final VoidCallback onPressed;

  const _QuoteCard({
    required this.title,
    required this.date,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Icono de fondo
          Positioned(
            top: -30,
            right: -20,
            child: Icon(
              Icons.attach_money,
              size: 120,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          // Contenido de la tarjeta
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.25),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  child: const Text('Ver Cotización'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}