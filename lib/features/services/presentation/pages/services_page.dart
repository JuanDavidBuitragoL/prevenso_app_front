
//            el refresco y ahora también el filtrado en tiempo real.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/service_model.dart';
import '../widgets/service_list_item.dart';
import 'create_service_page.dart';
import 'edit_service_page.dart';
import 'service_detail_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();

    List<ServiceModel> _allServices = []; // Almacena la lista completa y original de servicios
  List<ServiceModel> _filteredServices = []; // Almacena la lista filtrada que se muestra en la UI
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    // Añadimos un listener al controlador para que la función de filtro se ejecute cada vez que el texto cambie.
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  // Función para remover acentos y normalizar texto
  String _removeAccents(String text) {
    const accents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÌÍÎÏìíîïÙÚÛÜùúûüÿÑñÇç';
    const withoutAccents = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeIIIIiiiiUUUUuuuuyNnCc';

    String result = text;
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], withoutAccents[i]);
    }
    return result;
  }

  // Carga la lista inicial de servicios desde la API
  Future<void> _fetchServices() async {
    // Aseguramos que el estado de carga se active al refrescar
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) {
      setState(() {
        _error = 'Error de autenticación';
        _isLoading = false;
      });
      return;
    }

    try {
      final services = await _apiService.getServices(authProvider.token!);
      setState(() {
        _allServices = services;
        _filteredServices = services; // Inicialmente, la lista filtrada es igual a la completa
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

    void _filterServices() {
    final query = _removeAccents(_searchController.text.toLowerCase());
    setState(() {
      // Si la barra de búsqueda está vacía, mostramos todos los servicios.
      if (query.isEmpty) {
        _filteredServices = _allServices;
      } else {
        // Si hay texto, filtramos la lista original (_allServices) normalizando el nombre del servicio
        _filteredServices = _allServices
            .where((service) => _removeAccents(service.nombre.toLowerCase()).contains(query))
            .toList();
      }
    });
  }

    void _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateServicePage()),
    );
    if (result == true && mounted) {
      _fetchServices();
    }
  }

  void _navigateToEdit(ServiceModel service) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EditServicePage(service: service)),
    );
    if (result == true && mounted) {
      _fetchServices();
    }
  }

  void _navigateToDetail(ServiceModel service) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => ServiceDetailPage(service: service)),
    );
    if (result == true && mounted) {
      _fetchServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo-inicio.png', height: 40),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Servicios',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
                        TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar servicio por nombre...',
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
                  colors: [Color(0xFF00C6AD), Color(0xFF00AAB2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C6AD).withOpacity(0.4),
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
                          'Crear nuevo servicio',
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
              child: _buildServiceList(), // Usamos un método helper para construir la lista
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildServiceList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _fetchServices, child: const Text('Reintentar'))
          ],
        ),
      );
    }
    if (_filteredServices.isEmpty) {
      return const Center(child: Text('No se encontraron servicios que coincidan con la búsqueda.'));
    }

    // Construimos la lista a partir de la lista FILTRADA
    return ListView.builder(
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ServiceListItem(
            service: service,
            onTap: () => _navigateToDetail(service),
            onEdit: () => _navigateToEdit(service),
          ),
        );
      },
    );
  }
}