// -------------------------------------------------------------------
// features/rates/presentation/pages/edit_rate_page.dart
// La pantalla para editar los detalles de una tarifa existente.

import 'package:flutter/material.dart';
import 'rates_page.dart'; // Importamos la clase Rate

class EditRatePage extends StatefulWidget {
  final Rate rate;

  const EditRatePage({super.key, required this.rate});

  @override
  State<EditRatePage> createState() => _EditRatePageState();
}

class _EditRatePageState extends State<EditRatePage> {
  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _valueController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los valores actuales de la tarifa
    _nameController = TextEditingController(text: widget.rate.title);
    _durationController = TextEditingController(text: '16 horas'); // Valor de ejemplo
    _valueController = TextEditingController(text: widget.rate.price);
  }

  @override
  void dispose() {
    // Limpiamos los controladores para liberar memoria
    _nameController.dispose();
    _durationController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar la lógica para guardar los cambios en la API
      print('Cambios guardados (simulado)');
      // Regresa a la pantalla anterior después de guardar
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo-inicio.png',
          height: 40,
        ),
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
                // Campos de formulario editables
                _buildTextField(label: 'Nombre', controller: _nameController),
                const SizedBox(height: 20),
                _buildTextField(label: 'Duración', controller: _durationController),
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
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60), // Verde
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('Guardar cambios', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón de Cancelar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Simplemente regresa a la pantalla anterior sin guardar
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F54EB), // Azul
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

  // Widget helper para construir los campos de texto y no repetir código
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
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
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo no puede estar vacío';
            }
            return null;
          },
        ),
      ],
    );
  }
}
