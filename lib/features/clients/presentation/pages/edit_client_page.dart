
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/client_model.dart';

class EditClientPage extends StatefulWidget {
  final ClientModel client;

  const EditClientPage({super.key, required this.client});

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controladores para cada campo del formulario
  late TextEditingController _nameController;
  late TextEditingController _nitController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos del cliente actual
    _nameController = TextEditingController(text: widget.client.nombre);
    _nitController = TextEditingController(text: widget.client.nit);
    _addressController = TextEditingController(text: widget.client.direccion);
    _phoneController = TextEditingController(text: widget.client.telefono);
    _emailController = TextEditingController(text: widget.client.email);
  }

  @override
  void dispose() {
    // Limpiamos los controladores para liberar memoria
    _nameController.dispose();
    _nitController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

    Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) return;

    setState(() => _isLoading = true);

    final clientData = {
      'nombre_cliente': _nameController.text.trim(),
      'nit_cliente': _nitController.text.trim(),
      'direccion': _addressController.text.trim(),
      'telefono': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
    };

    try {
      await _apiService.updateClient(
        clientId: widget.client.id,
        data: clientData,
        token: authProvider.token!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente actualizado con éxito'), backgroundColor: Colors.green),
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
                  'Editando el cliente...',
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

                // Botón Guardar Cambios
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60), // Verde
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Guardar cambios', style: TextStyle(fontSize: 16)),
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
