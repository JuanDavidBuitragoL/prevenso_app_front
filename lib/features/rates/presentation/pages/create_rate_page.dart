
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../services/domain/entities/service_model.dart';

class CreateRatePage extends StatefulWidget {
  const CreateRatePage({super.key});

  @override
  State<CreateRatePage> createState() => _CreateRatePageState();
}

class _CreateRatePageState extends State<CreateRatePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controladores
  final _cityController = TextEditingController();
  final _valueController = TextEditingController();
  // Controlador para mostrar el nombre del servicio seleccionado en el input
  final _serviceDisplayController = TextEditingController();

  // Variables de Estado
  int? _selectedServiceId;
  List<ServiceModel> _allServices = []; // Lista completa en memoria
  bool _isLoadingServices = true;
  bool _isLoadingSubmit = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  // Carga inicial de servicios
  Future<void> _loadServices() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      try {
        final services = await _apiService.getServices(authProvider.token!);
        if (mounted) {
          setState(() {
            _allServices = services;
            _isLoadingServices = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingServices = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error cargando servicios')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _valueController.dispose();
    _serviceDisplayController.dispose();
    super.dispose();
  }

    // Convierte "Camión" -> "camion" para facilitar la búsqueda
  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áäâà]'), 'a')
        .replaceAll(RegExp(r'[éëêè]'), 'e')
        .replaceAll(RegExp(r'[íïîì]'), 'i')
        .replaceAll(RegExp(r'[óöôò]'), 'o')
        .replaceAll(RegExp(r'[úüûù]'), 'u')
        .replaceAll(RegExp(r'ñ'), 'n');
  }

    void _openServiceSelector() {
    if (_isLoadingServices) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el modal suba con el teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _ServiceSearchModal(
              services: _allServices,
              scrollController: scrollController,
              onServiceSelected: (selectedService) {
                setState(() {
                  _selectedServiceId = selectedService.id;
                  _serviceDisplayController.text = selectedService.nombre;
                });
                Navigator.pop(context); // Cerrar modal
              },
              normalizeFunction: _normalize,
            );
          },
        );
      },
    );
  }

  Future<void> _createRate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un servicio')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) return;

    setState(() => _isLoadingSubmit = true);

    try {
      await _apiService.createRate(
        serviceId: _selectedServiceId!,
        city: _cityController.text.trim(),
        cost: double.parse(_valueController.text.trim()),
        token: authProvider.token!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tarifa creada con éxito'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingSubmit = false);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nueva tarifa',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                                const Text('Servicio',
                    style: TextStyle(color: Colors.black54, fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _openServiceSelector,
                  child: IgnorePointer(
                    // Ignoramos toques directos para manejarlo con el InkWell
                    child: TextFormField(
                      controller: _serviceDisplayController,
                      readOnly: true, // No se puede escribir directamente aquí
                      decoration: InputDecoration(
                        hintText: _isLoadingServices
                            ? 'Cargando servicios...'
                            : 'Selecciona un servicio',
                        suffixIcon: _isLoadingServices
                            ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      validator: (value) => _selectedServiceId == null
                          ? 'Debes seleccionar un servicio'
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _buildTextField(label: 'Ciudad', controller: _cityController),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Costo',
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  prefixText: '\$',
                ),
                const SizedBox(height: 50),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingSubmit ? null : _createRate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoadingSubmit
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Text('Crear tarifa',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón Cancelar
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
                    child:
                    const Text('Cancelar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixText: prefixText,
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Requerido';
            if (keyboardType == TextInputType.number &&
                double.tryParse(value) == null) return 'Inválido';
            return null;
          },
        ),
      ],
    );
  }
}

class _ServiceSearchModal extends StatefulWidget {
  final List<ServiceModel> services;
  final ScrollController scrollController;
  final Function(ServiceModel) onServiceSelected;
  final String Function(String) normalizeFunction;

  const _ServiceSearchModal({
    required this.services,
    required this.scrollController,
    required this.onServiceSelected,
    required this.normalizeFunction,
  });

  @override
  State<_ServiceSearchModal> createState() => _ServiceSearchModalState();
}

class _ServiceSearchModalState extends State<_ServiceSearchModal> {
  List<ServiceModel> _filteredServices = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredServices = widget.services;
  }

  void _filterList(String query) {
    if (query.isEmpty) {
      setState(() => _filteredServices = widget.services);
      return;
    }

    final normalizedQuery = widget.normalizeFunction(query);

    setState(() {
      _filteredServices = widget.services.where((service) {
        final normalizedName = widget.normalizeFunction(service.nombre);
        // Búsqueda "fuzzy": ¿El nombre contiene la búsqueda normalizada?
        return normalizedName.contains(normalizedQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabecera del Modal
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecciona un Servicio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Buscador interno
              TextField(
                controller: _searchController,
                autofocus: true, // Abre el teclado automáticamente
                onChanged: _filterList,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar (ej. Camion, Grua...)',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Lista Filtrada
        Expanded(
          child: _filteredServices.isEmpty
              ? const Center(child: Text('No se encontraron servicios'))
              : ListView.builder(
            controller: widget.scrollController,
            itemCount: _filteredServices.length,
            itemBuilder: (context, index) {
              final service = _filteredServices[index];
              return ListTile(
                title: Text(service.nombre),
                onTap: () => widget.onServiceSelected(service),
                leading: const Icon(Icons.work_outline, color: Colors.grey),
              );
            },
          ),
        ),
      ],
    );
  }
}