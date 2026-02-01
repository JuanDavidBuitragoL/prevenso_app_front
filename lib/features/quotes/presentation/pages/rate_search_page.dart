
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
      final rawQuery = _searchController.text;
      _filterRates(rawQuery);
    });
  }

    String _removeDiacritics(String str) {
    var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  void _filterRates(String query) {
    // 1. Limpiamos la búsqueda (minusculas y sin tildes)
    final cleanQuery = _removeDiacritics(query.toLowerCase());

    setState(() {
      if (cleanQuery.isEmpty) {
        _filteredRates = widget.availableRates;
      } else {
        _filteredRates = widget.availableRates.where((rate) {
          // 2. Limpiamos el nombre del servicio también
          final cleanName = _removeDiacritics(rate.nombreServicio.toLowerCase());

          // 3. Comparamos las versiones limpias
          return cleanName.contains(cleanQuery);
        }).toList();
      }
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
        iconTheme: const IconThemeData(color: Colors.black54),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Buscar servicio (ej. Examen)...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black38),
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                // El listener se encargará de resetear la lista
              },
            ),
        ],
      ),
      body: _filteredRates.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.black12),
            const SizedBox(height: 16),
            Text(
              'No se encontraron servicios para\n"${_searchController.text}"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black45, fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.separated(
        itemCount: _filteredRates.length,
        separatorBuilder: (ctx, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final rate = _filteredRates[index];
          return ListTile(
            title: Text(
              rate.nombreServicio,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              rate.ciudad, // Muestra la ciudad para diferenciar tarifas iguales
              style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
            ),
            trailing: Text(
              '\$${rate.costo}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
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