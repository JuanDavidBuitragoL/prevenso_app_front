// --- PASO 2.1: Refactorizar CreateRatePage para ser dinámica y funcional ---
// ARCHIVO: lib/features/rates/presentation/pages/create_rate_page.dart (VERSIÓN FINAL)

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

  // Controladores para los campos del formulario
  final _cityController = TextEditingController();
  final _valueController = TextEditingController();

  // Variables para manejar el estado del dropdown de servicios
  int? _selectedServiceId;
  late Future<List<ServiceModel>> _servicesFuture;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargamos la lista de servicios al iniciar la pantalla
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      _servicesFuture = _apiService.getServices(authProvider.token!);
    } else {
      _servicesFuture = Future.error('Error de autenticación');
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  // --- Lógica para crear la nueva tarifa en el backend ---
  Future<void> _createRate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.createRate(
        serviceId: _selectedServiceId!,
        city: _cityController.text.trim(),
        cost: double.parse(_valueController.text.trim()),
        token: authProvider.token!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarifa creada con éxito'), backgroundColor: Colors.green),
        );
        // Regresamos a la pantalla anterior, devolviendo 'true' para que se refresque
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

                // --- Dropdown para seleccionar el servicio ---
                const Text('Servicio', style: TextStyle(color: Colors.black54, fontSize: 16)),
                const SizedBox(height: 8),
                FutureBuilder<List<ServiceModel>>(
                  future: _servicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No se pudieron cargar los servicios.');
                    }

                    final services = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      value: _selectedServiceId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Selecciona un servicio',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      items: services.map((service) {
                        return DropdownMenuItem<int>(
                          value: service.id,
                          child: Text(service.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedServiceId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Debes seleccionar un servicio' : null,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // --- Campo para la Ciudad ---
                _buildTextField(label: 'Ciudad', controller: _cityController),
                const SizedBox(height: 20),

                // --- Campo para el Costo ---
                _buildTextField(
                  label: 'Costo',
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  prefixText: '\$',
                ),
                const SizedBox(height: 50),

                // Botón de Crear Tarifa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createRate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60), // Verde
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Crear tarifa', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de Cancelar
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
                    child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper para construir los campos de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixText: prefixText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Este campo no puede estar vacío';
            }
            if (keyboardType == TextInputType.number && double.tryParse(value) == null) {
              return 'Por favor, ingresa un número válido';
            }
            return null;
          },
        ),
      ],
    );
  }
}