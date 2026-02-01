
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

class _RecentQuotesSectionState extends State<RecentQuotesSection>
    with AutomaticKeepAliveClientMixin {

  final ApiService _apiService = ApiService();
  late Future<List<QuoteModel>> _quotesFuture;

  @override
  bool get wantKeepAlive => false; // No mantener el estado cuando no es visible

  @override
  void initState() {
    super.initState();
    _fetchRecentQuotes();
  }

  // 🔄 Este método se llama cada vez que la pantalla vuelve a ser visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar las cotizaciones cada vez que la pantalla se muestra
    _fetchRecentQuotes();
  }

  void _fetchRecentQuotes() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      setState(() {
        _quotesFuture = _apiService.getQuotes(authProvider.token!);
      });
    } else {
      setState(() {
        _quotesFuture = Future.error('Error de autenticación');
      });
    }
  }

  // 🔄 Método público para refrescar manualmente (opcional)
  void refresh() {
    _fetchRecentQuotes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido por AutomaticKeepAliveClientMixin

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cotizaciones recientes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            // Botón de refresh manual (opcional)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF4A55A2)),
              onPressed: _fetchRecentQuotes,
              tooltip: 'Actualizar',
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Usamos un FutureBuilder para manejar los estados de la llamada a la API
        FutureBuilder<List<QuoteModel>>(
          future: _quotesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A55A2)),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(
                      'Error al cargar cotizaciones',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _fetchRecentQuotes,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no hay cotizaciones',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Tomamos solo las 2 cotizaciones más recientes para mostrar
            final recentQuotes = snapshot.data!.take(2).toList();

            return Column(
              children: recentQuotes.map((quote) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: _QuoteCard(
                    quote: quote,
                    onPressed: () async {
                      // Navegar y esperar a que regrese
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuoteDetailPage(quote: quote),
                        ),
                      );
                      // Refrescar cuando regrese (por si se editó o eliminó)
                      _fetchRecentQuotes();
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
            onPressed: () async {
              // Navegar a la página de todas las cotizaciones
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuotesPage()),
              );
              // Refrescar cuando regrese
              _fetchRecentQuotes();
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