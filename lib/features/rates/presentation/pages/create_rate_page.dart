// -------------------------------------------------------------------
// features/rates/presentation/pages/create_rate_page.dart
// La pantalla para crear una nueva tarifa desde cero.

import 'package:flutter/material.dart';

class CreateRatePage extends StatefulWidget {
  const CreateRatePage({super.key});

  @override
  State<CreateRatePage> createState() => _CreateRatePageState();
}

class _CreateRatePageState extends State<CreateRatePage> {
  // Los controladores se inicializan vacíos
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _valueController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Limpiamos los controladores para liberar memoria
    _nameController.dispose();
    _durationController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _createRate() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar la lógica para enviar la nueva tarifa a la API
      print('Nueva tarifa creada (simulado)');
      // Regresa a la pantalla anterior después de crear
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
                  'Nueva tarifa',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Campos de formulario vacíos
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
                // Botón de Crear Tarifa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createRate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60), // Verde
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('Crear tarifa', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón de Cancelar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Simplemente regresa a la pantalla anterior
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

  // Reutilizamos el mismo widget helper para construir los campos de texto
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
