// =============================================================================
// ARCHIVO: lib/features/quotes/presentation/pages/quote_detail_page.dart (SOLUCIÓN DEFINITIVA)
// FUNCIÓN:   Implementa la lógica de guardado en un directorio temporal y
//            apertura con el visor nativo, evitando los problemas de Scoped Storage.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
// permission_handler ya no es necesario

import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/quote_model.dart';
import '../widgets/pdf_loading_indicator.dart';

class QuoteDetailPage extends StatefulWidget {
  final QuoteModel quote;
  const QuoteDetailPage({super.key, required this.quote});

  @override
  State<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {
  Future<void> _downloadAndOpenFile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const PdfLoadingIndicator(),
    );

    try {
      // 1. Descargar el PDF (no cambia)
      final apiService = ApiService();
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      final Uint8List pdfBytes =
      await apiService.getQuotePdf(widget.quote.id, token);

      // 2. Obtener el directorio TEMPORAL (no requiere permisos de almacenamiento)
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/Cotizacion_${widget.quote.id}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // 3. Ocultar el diálogo de carga y abrir el archivo
      if (mounted) {
        Navigator.of(context).pop();

        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          throw Exception('No se pudo abrir el archivo: ${result.message}');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... El resto de la UI se mantiene exactamente igual ...
    final currencyFormatter =
    NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final formattedTotal =
    currencyFormatter.format(double.parse(widget.quote.totalValue));

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
              const Text(
                'Detalles de la cotización',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00C6AD),
                ),
              ),
              const SizedBox(height: 30),
              _InfoField(label: 'Empresa', value: widget.quote.clientName),
              const SizedBox(height: 20),
              const Text(
                'Servicios Incluidos',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.quote.items.length,
                itemBuilder: (context, index) {
                  return _TariffListItem(item: widget.quote.items[index]);
                },
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300, thickness: 1.5),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Cotización:',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(formattedTotal,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C6AD))),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Creada por: ${widget.quote.userName}',
                  style: const TextStyle(
                      color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Ver PDF',
                      style: TextStyle(fontSize: 16)),
                  onPressed: _downloadAndOpenFile,
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
                  child:
                  const Text('Regresar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ... (El resto de widgets de la página se mantienen igual)
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
    final currencyFormatter =
    NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final hasDiscount = item.discountType != null &&
        item.discountValue != null &&
        item.discountValue! > 0;
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
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                currencyFormatter.format(item.subtotal),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
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
          ] else ...[
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
  Widget _buildPriceDetailRow(String label, String value,
      {Color color = Colors.black54, bool isBold = false}) {
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
