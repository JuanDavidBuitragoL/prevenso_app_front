import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/quote_model.dart';
import '../widgets/pdf_loading_indicator.dart';
import 'edit_quote_page.dart';

class QuoteDetailPage extends StatefulWidget {
  final QuoteModel quote;

  const QuoteDetailPage({super.key, required this.quote});

  @override
  State<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {
  late QuoteModel _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = widget.quote;
  }

  Future<void> _downloadAndOpenFile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const PdfLoadingIndicator(),
    );

    try {
      final apiService = ApiService();
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      final Uint8List pdfBytes =
          await apiService.getQuotePdf(_currentQuote.id, token);

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/Cotizacion_${_currentQuote.id}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.of(context).pop();
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          print("No se pudo abrir el archivo: ${result.message}");
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

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuotePage(quote: _currentQuote),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    final formattedTotal = currencyFormatter.format(_currentQuote.totalValue);

    double subtotalItems = 0;
    for (var item in _currentQuote.items) {
      subtotalItems += item.subtotal;
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo-inicio.png', height: 40),
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF27AE60)),
            onPressed: _navigateToEdit,
            tooltip: 'Editar Cotización',
          ),
        ],
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
              _InfoField(label: 'Empresa', value: _currentQuote.clientName),
              const SizedBox(height: 20),
              if (_currentQuote.observations != null &&
                  _currentQuote.observations!.isNotEmpty) ...[
                const Text(
                  'Observaciones',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    _currentQuote.observations!,
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
                itemCount: _currentQuote.items.length,
                itemBuilder: (context, index) {
                  return _TariffListItem(item: _currentQuote.items[index]);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300, thickness: 1.5),
              const SizedBox(height: 16),
              if (_currentQuote.surcharge != null &&
                  _currentQuote.surcharge! > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal Servicios:',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    Text(currencyFormatter.format(subtotalItems),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recargo / Adicional:',
                        style: TextStyle(fontSize: 16, color: Colors.orange)),
                    Text(
                        '+ ${currencyFormatter.format(_currentQuote.surcharge)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300, endIndent: 150),
              ],
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
                  'Creada por: ${_currentQuote.userName}',
                  style: const TextStyle(
                      color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar Cotización',
                      style: TextStyle(fontSize: 16)),
                  onPressed: _navigateToEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF27AE60),
                    side:
                        const BorderSide(color: Color(0xFF27AE60), width: 1.5),
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
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Ver PDF', style: TextStyle(fontSize: 16)),
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

    final hasIndividualSurcharge =
        item.surcharge != null && item.surcharge! > 0;

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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (hasDiscount || hasIndividualSurcharge) ...[
            const Divider(height: 16, color: Colors.black26),
            _buildPriceDetailRow(
              'Precio Base Unitario:',
              currencyFormatter.format(item.priceBaseUnit),
            ),
            if (hasDiscount) ...[
              const SizedBox(height: 4),
              _buildPriceDetailRow(
                'Descuento Aplicado:',
                '- ${item.discountType == 'porcentaje' ? '${item.discountValue}%' : currencyFormatter.format(item.discountValue)}',
                color: Colors.green.shade700,
              ),
            ],
            const SizedBox(height: 4),
            _buildPriceDetailRow(
              'Precio Final Unitario:',
              currencyFormatter.format(item.priceFinalUnit),
              isBold: true,
            ),
            if (hasIndividualSurcharge) ...[
              const SizedBox(height: 4),
              _buildPriceDetailRow(
                'Recargo del servicio:',
                '+ ${currencyFormatter.format(item.surcharge)}',
                color: Colors.orange.shade700,
              ),
            ],
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
