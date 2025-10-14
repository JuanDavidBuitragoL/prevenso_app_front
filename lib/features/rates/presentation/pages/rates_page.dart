// =============================================================================
// ARCHIVO: features/rates/presentation/pages/rates_page.dart (CORRECCIÓN FINAL)
// FUNCIÓN:   Integra la lógica de estado (búsqueda, carga de datos) con un
//            diseño de cuadrícula completamente responsivo para móvil y escritorio.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/rate_model.dart';
import '../widgets/rate_card.dart';
import 'create_rate_page.dart';
import 'rate_detail_page.dart';
import '../../../../core/utils/app_assets.dart'; // Asegúrate de importar tus assets

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  State<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<RateModel> _allRates = [];
  List<RateModel> _filteredRates = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRates);
    _fetchRates();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRates);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) {
      if (mounted) {
        setState(() {
          _error = 'No se encontró token de autenticación.';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final rates = await _apiService.getRates(authProvider.token!);
      if (mounted) {
        setState(() {
          rates.sort((a, b) => b.id.compareTo(a.id));
          _allRates = rates;
          _filteredRates = rates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterRates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRates = _allRates.where((rate) {
        final serviceNameMatch = rate.nombreServicio.toLowerCase().contains(query);
        final cityMatch = rate.ciudad.toLowerCase().contains(query);
        return serviceNameMatch || cityMatch;
      }).toList();
    });
  }

  void _navigateToDetail(RateModel rate) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => RateDetailPage(rate: rate)),
    );
    if (result == true && mounted) {
      _fetchRates();
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateRatePage()),
    );
    if (result == true && mounted) {
      _fetchRates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(AppAssets.logo, height: 40),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: Center( // Centra el contenido en la pantalla
        child: ConstrainedBox( // Limita el ancho máximo del contenido
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por servicio o ciudad',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF9A825), Color(0xFFF57F17)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateToCreate,
                      borderRadius: BorderRadius.circular(30),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Crear nueva tarifa',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildRatesGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatesGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_filteredRates.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? 'No se encontraron resultados.'
              : 'No hay tarifas creadas.',
        ),
      );
    }

    // --- LÓGICA RESPONSIVA INTEGRADA ---
    return LayoutBuilder(
      builder: (context, constraints) {
        // En pantallas anchas (PC), las tarjetas serán más anchas que altas (rectangulares).
        // En pantallas estrechas (móvil), serán más altas que anchas (casi cuadradas).
        final double aspectRatio = constraints.maxWidth > 700 ? 1.4 : 0.85;

        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          // Se usa un delegate que calcula las columnas automáticamente.
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280, // Ancho ideal para cada tarjeta.
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: aspectRatio, // Define la forma de la tarjeta.
          ),
          itemCount: _filteredRates.length,
          itemBuilder: (context, index) {
            final rate = _filteredRates[index];
            return RateCard(
              rate: rate,
              onTap: () => _navigateToDetail(rate),
            );
          },
        );
      },
    );
  }
}

