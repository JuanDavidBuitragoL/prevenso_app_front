// =============================================================================
// ARCHIVO: lib/features/quotes/presentation/pages/pdf_viewer_page.dart (NUEVO ARCHIVO)
// FUNCIÓN:   Una pantalla dedicada a mostrar un archivo PDF local usando el
//            paquete flutter_pdfview.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class PdfViewerPage extends StatelessWidget {
  final String filePath;

  const PdfViewerPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa de la Cotización'),
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true, // Permite cambiar de página deslizando
        swipeHorizontal: false, // Deslizamiento vertical
        autoSpacing: false,
        pageFling: true,
        onError: (error) {
          print(error.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al abrir el PDF: $error')),
          );
        },
        onPageError: (page, error) {
          print('Error en la página $page: ${error.toString()}');
        },
      ),
    );
  }
}