// ARCHIVO: lib/features/clients/presentation/pages/create_client_page.dart (VERSIÓN FINAL)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';

class CreateClientPage extends StatefulWidget {
  const CreateClientPage({super.key});

  @override
  State<CreateClientPage> createState() => _CreateClientPageState();
}

class _CreateClientPageState extends State<CreateClientPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controladores para todos los campos del formulario
  final _nameController = TextEditingController();
  final _nitController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(); // Nuevo controlador para el email

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nitController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose(); // Limpiar el nuevo controlador
    super.dispose();
  }

  // --- Lógica para crear el nuevo cliente en el backend ---
  Future<void> _createClient() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) return;

    setState(() => _isLoading = true);

    // Creamos el mapa de datos para enviar a la API
    final clientData = {
      'nombre_cliente': _nameController.text.trim(),
      'nit_cliente': _nitController.text.trim(),
      'direccion': _addressController.text.trim(),
      'telefono': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
    };

    try {
      await _apiService.createClient(
        data: clientData,
        token: authProvider.token!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente creado con éxito'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Devuelve 'true' para refrescar la lista
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
                  'Nuevo cliente',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00C6AD)),
                ),
                const SizedBox(height: 30),

                // Campos del formulario
                _buildTextField(label: 'Nombre*', controller: _nameController),
                const SizedBox(height: 20),
                _buildTextField(label: 'Nit', controller: _nitController, isRequired: false),
                const SizedBox(height: 20),
                _buildTextField(label: 'Dirección', controller: _addressController, isRequired: false),
                const SizedBox(height: 20),
                _buildTextField(label: 'Teléfono', controller: _phoneController, keyboardType: TextInputType.phone, isRequired: false),
                const SizedBox(height: 20),
                _buildTextField(label: 'Correo', controller: _emailController, keyboardType: TextInputType.emailAddress, isRequired: false),
                const SizedBox(height: 50),

                // Botón Crear Cliente
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createClient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60), // Verde
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Crear cliente', style: TextStyle(fontSize: 16)),
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

  // Widget helper reutilizable para construir los campos de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'Este campo es requerido';
            }
            if (keyboardType == TextInputType.emailAddress && value != null && value.isNotEmpty && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
              return 'Ingresa un correo válido';
            }
            return null;
          },
        ),
      ],
    );
  }
}