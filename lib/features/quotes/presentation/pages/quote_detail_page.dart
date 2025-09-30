// =============================================================================
// ARCHIVO: lib/features/quotes/presentation/pages/quote_detail_page.dart (ACTUALIZADO)
// FUNCIÓN:   Ahora utiliza una superposición modal con una animación
//            personalizada al generar el PDF, en lugar de un simple
//            indicador de carga en el botón.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/quote_model.dart';
import 'pdf_viewer_page.dart';
import '../widgets/pdf_loading_indicator.dart'; // <-- Importar el nuevo widget

class QuoteDetailPage extends StatefulWidget {
  final QuoteModel quote;
  const QuoteDetailPage({super.key, required this.quote});

  @override
  State<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {

  Future<void> _viewPdf() async {
    // --- CAMBIO CLAVE: Mostrar el diálogo de carga ---
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrarlo
      builder: (BuildContext context) {
        return const PdfLoadingIndicator();
      },
    );

    final apiService = ApiService();
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token == null) {
      if (mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de autenticación.')),
        );
      }
      return;
    }

    try {
      final Uint8List pdfBytes = await apiService.getQuotePdf(widget.quote.id, token);
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/cotizacion_${widget.quote.id}.pdf';
      final file = File(tempPath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo de carga ANTES de navegar

        if (Platform.isAndroid || Platform.isIOS) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerPage(filePath: tempPath),
            ),
          );
        } else {
          final result = await OpenFilex.open(tempPath);
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se pudo abrir el archivo: ${result.message}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo de carga en caso de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar el PDF: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final formattedTotal = currencyFormatter.format(double.parse(widget.quote.totalValue));

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo-inicio.png', height: 40),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalles de la cotización', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00C6AD))),
              const SizedBox(height: 30),
              _InfoField(label: 'Empresa', value: widget.quote.clientName),
              const SizedBox(height: 20),
              const Text('Servicios Incluidos', style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.quote.items.length,
                itemBuilder: (context, index) {
                  return _TariffListItem(item: widget.quote.items[index]);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300, thickness: 1.5),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Cotización:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(formattedTotal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00C6AD))),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Creada por: ${widget.quote.userName}', style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 40),

              // --- CAMBIO CLAVE: El botón ahora es más simple y no maneja el estado de carga ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Ver / Descargar PDF', style: TextStyle(fontSize: 16)),
                  onPressed: _viewPdf, // Simplemente llama a la función
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('Regresar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... (Los widgets _InfoField y _TariffListItem se mantienen exactamente igual)
class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
class _TariffListItem extends StatelessWidget {
  final QuoteItemModel item;
  const _TariffListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final hasDiscount = item.discountType != null && item.discountValue != null && item.discountValue! > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${item.serviceName} (x${item.quantity})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                currencyFormatter.format(item.subtotal),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (hasDiscount) ...[
            const Divider(height: 16, color: Colors.black26),
            _buildPriceDetailRow(
              'Precio Base Unitario:',
              currencyFormatter.format(item.priceBaseUnit),
            ),
            const SizedBox(height: 4),
            _buildPriceDetailRow(
              'Descuento Aplicado:',
              '- ${item.discountType == 'porcentaje' ? '${item.discountValue}%' : currencyFormatter.format(item.discountValue)}',
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 4),
            _buildPriceDetailRow(
              'Precio Final Unitario:',
              currencyFormatter.format(item.priceFinalUnit),
              isBold: true,
            ),
          ] else ... [
            const SizedBox(height: 4),
            _buildPriceDetailRow(
              'Precio Unitario:',
              currencyFormatter.format(item.priceBaseUnit),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPriceDetailRow(String label, String value, {Color color = Colors.black54, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

