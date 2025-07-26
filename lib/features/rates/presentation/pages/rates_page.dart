// =============================================================================
// ARCHIVO: features/rates/presentation/pages/rates_page.dart (VERSIÓN FINAL)
// FUNCIÓN:   Pantalla principal que lista todas las tarifas, maneja la carga
//            de datos y el refresco automático después de una acción.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/rate_model.dart';
import '../widgets/rate_card.dart';
import 'create_rate_page.dart';
import 'rate_detail_page.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  State<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  final ApiService _apiService = ApiService();
  // Usamos un 'late' Future porque se inicializará en initState/fetchRates
  late Future<List<RateModel>> _ratesFuture;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos por primera vez al construir la pantalla
    _fetchRates();
  }

  // Lógica centralizada para obtener o refrescar las tarifas
  void _fetchRates() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      setState(() {
        _ratesFuture = _apiService.getRates(authProvider.token!);
      });
    } else {
      // Si no hay token, establecemos un futuro con error
      setState(() {
        _ratesFuture = Future.error('No se encontró token de autenticación.');
      });
    }
  }

  // Maneja la navegación a la página de detalles y espera un resultado
  void _navigateToDetail(RateModel rate) async {
    // Navegamos y esperamos un posible resultado booleano (true si algo cambió)
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => RateDetailPage(rate: rate)),
    );

    if (result == true && mounted) {
      _fetchRates();
    }
  }
  // --- Maneja la navegación a la página de creación y el refresco ---
  void _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateRatePage()),
    );

    // Si la página de creación devuelve 'true', refrescamos la lista.
    if (result == true && mounted) {
      _fetchRates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifas'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Barra de búsqueda (funcionalidad a implementar)
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
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
            // Botón para crear una nueva tarifa
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
            // Cuadrícula de tarifas que se actualiza según el estado del Future
            Expanded(
              child: FutureBuilder<List<RateModel>>(
                future: _ratesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No se encontraron tarifas.'));
                  }

                  final rates = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: rates.length,
                    itemBuilder: (context, index) {
                      return RateCard(
                        rate: rates[index],
                        onTap: () => _navigateToDetail(rates[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}