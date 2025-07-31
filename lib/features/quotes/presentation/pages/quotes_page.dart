// =============================================================================
// ARCHIVO: lib/features/quotes/presentation/pages/quotes_page.dart (VERSIÓN FINAL)
// FUNCIÓN:   Pantalla principal que lista todas las cotizaciones, maneja la carga
//            de datos y el refresco automático después de una acción.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/quote_model.dart';
import '../widgets/quote_list_item.dart';
import 'create_quote_page.dart';
import 'edit_quote_page.dart';
import 'quote_detail_page.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  final ApiService _apiService = ApiService();
  late Future<List<QuoteModel>> _quotesFuture;

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
  }

  void _fetchQuotes() {
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

  // --- Lógica para eliminar una cotización ---
  Future<void> _deleteQuote(int quoteId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) return;

    // Diálogo de confirmación
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este borrador?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.deleteQuote(quoteId, authProvider.token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Borrador eliminado con éxito'), backgroundColor: Colors.green),
        );
        _fetchQuotes(); // Refrescar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Lógica para navegar a la página de edición ---
  void _navigateToEdit(QuoteModel quote) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EditQuotePage(quote: quote)),
    );
    if (result == true && mounted) {
      _fetchQuotes();
    }
  }

  void _navigateToDetail(QuoteModel quote) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => QuoteDetailPage(quote: quote)),
    );
    if (result == true && mounted) {
      _fetchQuotes();
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => const CreateQuotePage()));
    if (result == true && mounted) {
      _fetchQuotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotizaciones')),
      body: FutureBuilder<List<QuoteModel>>(
        future: _quotesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron cotizaciones.'));
          }

          final quotes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: QuoteListItem(
                  quote: quote,
                  onTap: () => _navigateToDetail(quote),
                  onEdit: () => _navigateToEdit(quote),
                  onDelete: () => _deleteQuote(quote.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        label: const Text('Nueva Cotización'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
