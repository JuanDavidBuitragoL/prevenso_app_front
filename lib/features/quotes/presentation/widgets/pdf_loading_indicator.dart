//            animación de engranaje giratorio y mensajes informativos.

import 'package:flutter/material.dart';

class PdfLoadingIndicator extends StatefulWidget {
  const PdfLoadingIndicator({super.key});

  @override
  State<PdfLoadingIndicator> createState() => _PdfLoadingIndicatorState();
}

class _PdfLoadingIndicatorState extends State<PdfLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Se configura el controlador para una animación que se repite
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Dialog para darle una apariencia de "modal"
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // La animación de rotación aplicada al ícono
              RotationTransition(
                turns: _controller,
                child: Icon(
                  Icons.settings, // Un ícono de engranaje
                  size: 50.0,
                  color: const Color(0xFF00C6AD), // Color primario
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Generando PDF...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Esto puede tardar unos segundos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
