// -------------------------------------------------------------------
// features/quotes/presentation/pages/quote_detail_page.dart
// --- NUEVO ARCHIVO ---
// La pantalla para ver los detalles de una cotización específica.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/quote_model.dart';

class QuoteDetailPage extends StatelessWidget {
  // La página sigue recibiendo el objeto 'QuoteModel' con la información básica
  final QuoteModel quote;

  const QuoteDetailPage({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    // Formateamos el valor total para mostrarlo correctamente
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
              // Construimos la lista de ítems dinámicamente
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)
                ),
                child: ListView.separated(
                  shrinkWrap: true, // Para que la lista ocupe solo el espacio necesario
                  physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll de la lista interna
                  itemCount: quote.items.length,
                  itemBuilder: (context, index) {
                    return _TariffListItem(tariff: quote.items[index]);
                  },
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200, indent: 16, endIndent: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Valor Total
              _InfoField(label: 'Valor total', value: formattedTotal),
              const SizedBox(height: 16),

              // Creador
              Text(
                'Creada por: ${quote.userName}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
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

// Widget para cada ítem en la lista de tarifas
class _TariffListItem extends StatelessWidget {
  final QuoteItemModel tariff;

  const _TariffListItem({required this.tariff});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(tariff.serviceName, style: const TextStyle(fontSize: 16))
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey.shade300,
            child: Text(
              tariff.quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
