// ARCHIVO: lib/features/home/presentation/widgets/recent_quotes_section.dart (VERSIÓN FINAL)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../quotes/domain/entities/quote_model.dart';
import '../../../quotes/presentation/pages/quote_detail_page.dart';
import '../../../quotes/presentation/pages/quotes_page.dart';

class RecentQuotesSection extends StatefulWidget {
  const RecentQuotesSection({super.key});

  @override
  State<RecentQuotesSection> createState() => _RecentQuotesSectionState();
}

class _RecentQuotesSectionState extends State<RecentQuotesSection> {
  final ApiService _apiService = ApiService();
  late Future<List<QuoteModel>> _quotesFuture;

  @override
  void initState() {
    super.initState();
    _fetchRecentQuotes();
  }

  void _fetchRecentQuotes() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      // Llamamos a la API para obtener todas las cotizaciones
      _quotesFuture = _apiService.getQuotes(authProvider.token!);
    } else {
      _quotesFuture = Future.error('Error de autenticación');
    }
  }

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
        // Usamos un FutureBuilder para manejar los estados de la llamada a la API
        FutureBuilder<List<QuoteModel>>(
          future: _quotesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar cotizaciones: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aún no hay cotizaciones.'));
            }

            // Tomamos solo las 2 cotizaciones más recientes para mostrar
            final recentQuotes = snapshot.data!.take(2).toList();

            return Column(
              children: recentQuotes.map((quote) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: _QuoteCard(
                    quote: quote,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuoteDetailPage(quote: quote)),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {
              // Navega a la página que muestra TODAS las cotizaciones
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuotesPage()),
              );
            },
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

// --- El widget _QuoteCard ahora usa el QuoteModel ---
class _QuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onPressed;

  const _QuoteCard({
    required this.quote,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica para asignar un color basado en el nombre del cliente
    final Color cardColor = _getColorForClient(quote.clientName);
    final String formattedDate = DateFormat('EEEE, MMMM d', 'es_CO').format(quote.creationDate.toLocal());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Icon(
              Icons.receipt_long_outlined,
              size: 120,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cotización para ${quote.clientName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
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

  Color _getColorForClient(String clientName) {
    final hash = clientName.hashCode;
    final colors = [
      const Color(0xFF4A55A2), const Color(0xFFE87A5A),
      const Color(0xFF00C6AD), const Color(0xFF5D5FEF)
    ];
    return colors[hash % colors.length];
  }
}
