// =============================================================================
// ARCHIVO: features/quotes/presentation/pages/rate_search_page.dart (NUEVO ARCHIVO)
// FUNCIÓN:   Una pantalla dedicada para buscar y seleccionar una tarifa.
// =============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../rates/domain/entities/rate_model.dart';

class RateSearchPage extends StatefulWidget {
  final List<RateModel> availableRates;
  const RateSearchPage({super.key, required this.availableRates});

  @override
  State<RateSearchPage> createState() => _RateSearchPageState();
}

class _RateSearchPageState extends State<RateSearchPage> {
  final _searchController = TextEditingController();
  List<RateModel> _filteredRates = [];

  @override
  void initState() {
    super.initState();
    _filteredRates = widget.availableRates;
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredRates = widget.availableRates
            .where((rate) => rate.nombreServicio.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // --- Barra de Búsqueda en el AppBar ---
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Escribe para buscar un servicio...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _filteredRates.isEmpty
          ? const Center(child: Text('No se encontraron servicios.'))
          : ListView.builder(
        itemCount: _filteredRates.length,
        itemBuilder: (context, index) {
          final rate = _filteredRates[index];
          return ListTile(
            title: Text(rate.nombreServicio),
            subtitle: Text('Costo: \$${rate.costo}'),
            onTap: () {
              // Al seleccionar, se devuelve la tarifa a la pantalla anterior
              Navigator.of(context).pop(rate);
            },
          );
        },
      ),
    );
  }
}
