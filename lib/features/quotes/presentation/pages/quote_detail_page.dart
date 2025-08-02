// =============================================================================
// ARCHIVO: lib/features/quotes/presentation/pages/quote_detail_page.dart (VERSIÓN FINAL)
// FUNCIÓN:   Muestra los detalles completos de una cotización, incluyendo
//            la lista de ítems con sus precios y descuentos.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/quote_model.dart';

class QuoteDetailPage extends StatelessWidget {
  final QuoteModel quote;

  const QuoteDetailPage({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final formattedTotal = currencyFormatter.format(double.parse(quote.totalValue));

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
              // Campos de información general
              _InfoField(label: 'Empresa', value: quote.clientName),
              const SizedBox(height: 20),

              // Lista de Tarifas/Items
              const Text(
                'Servicios Incluidos',
                style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Construimos la lista de ítems dinámicamente con el nuevo widget
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quote.items.length,
                itemBuilder: (context, index) {
                  return _TariffListItem(item: quote.items[index]);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
              const SizedBox(height: 20),

              // Línea divisoria antes del total
              Divider(color: Colors.grey.shade300, thickness: 1.5),
              const SizedBox(height: 16),

              // Resumen final
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
                child: Text(
                  'Creada por: ${quote.userName}',
                  style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 40),

              // Botón de Descargar PDF
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Descargar Pdf', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    // TODO: Implementar lógica para llamar a la API y descargar el PDF
                  },
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

              // Botón de Regresar
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

// Widget para los campos de texto de solo lectura
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

// --- Widget para cada ítem en la lista (COMPLETAMENTE REDISEÑADO) ---
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
          // Fila principal: Nombre y Subtotal
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
          // Muestra el detalle del precio solo si hay descuento
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

  // Widget helper para construir las filas de detalle de precios
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
