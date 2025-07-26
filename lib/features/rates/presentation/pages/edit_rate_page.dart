// -------------------------------------------------------------------
// features/rates/presentation/pages/edit_rate_page.dart
// La pantalla para editar los detalles de una tarifa existente.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/rate_model.dart';

class EditRatePage extends StatefulWidget {
  // La página ahora recibe el RateModel, que es el tipo de dato correcto
  final RateModel rate;

  const EditRatePage({super.key, required this.rate});

  @override
  State<EditRatePage> createState() => _EditRatePageState();
}

class _EditRatePageState extends State<EditRatePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _valueController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los valores actuales de la tarifa
    _nameController = TextEditingController(text: widget.rate.nombreServicio);
    _cityController = TextEditingController(text: widget.rate.ciudad);
    _valueController = TextEditingController(text: widget.rate.costo);
  }

  @override
  void dispose() {
    // Limpiamos los controladores para liberar memoria
    _nameController.dispose();
    _cityController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  // --- Lógica para guardar los cambios en el backend ---
  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Creamos el mapa de datos solo con los campos que pueden cambiar
    final Map<String, dynamic> dataToUpdate = {
      'ciudad': _cityController.text.trim(),
      'costo': double.tryParse(_valueController.text.trim()) ?? 0.0,
    };

    try {
      await _apiService.updateRate(
        rateId: widget.rate.id,
        data: dataToUpdate,
        token: authProvider.token!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarifa actualizada con éxito'), backgroundColor: Colors.green),
        );
        // Regresa a la pantalla anterior después de guardar
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
                  'Editando la tarifa...',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // El nombre del servicio no es editable, se muestra como información
                _buildInfoField(label: 'Nombre del Servicio', value: _nameController.text),
                const SizedBox(height: 20),
                // La ciudad y el valor sí son editables
                _buildTextField(label: 'Ciudad', controller: _cityController),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Valor',
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  prefixText: '\$',
                ),
                const SizedBox(height: 50),
                // Botón de Guardar Cambios
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

  // Widget helper para campos de texto editables
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

  // Widget helper para campos de información no editables
  Widget _buildInfoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
