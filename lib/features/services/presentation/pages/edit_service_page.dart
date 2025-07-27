// -------------------------------------------------------------------
// features/services/presentation/pages/edit_service_page.dart
// La pantalla para editar los detalles de un servicio existente.

import 'package:flutter/material.dart';
import 'services_page.dart'; // Importamos la clase Service

class EditServicePage extends StatefulWidget {
  final Service service;

  const EditServicePage({super.key, required this.service});

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  String? _selectedType;
  final List<String> _serviceTypes = ['Examen', 'Capacitación', 'Taller', 'Certificación'];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores y el tipo con los valores actuales del servicio
    _nameController = TextEditingController(text: widget.service.title);
    _durationController = TextEditingController(text: widget.service.duration);
    _selectedType = widget.service.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar la lógica para guardar los cambios en la API
      print('Cambios de servicio guardados (simulado)');
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
                  'Editando el servicio...',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00C6AD)),
                ),
                const SizedBox(height: 30),

                // Campo Nombre
                _buildTextField(label: 'Nombre', controller: _nameController),
                const SizedBox(height: 20),

                // Campo Tipo (Dropdown)
                _buildDropdownField(),
                const SizedBox(height: 20),

                // Campo Duración
                _buildTextField(label: 'Duración', controller: _durationController),
                const SizedBox(height: 50),

                // Botón Guardar Cambios
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

                // Botón Cancelar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
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

  // Widget helper para el campo de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
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
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Este campo es requerido' : null,
        ),
      ],
    );
  }

  // Widget helper para el campo de dropdown
  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          items: _serviceTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedType = newValue;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          validator: (value) => (value == null) ? 'Selecciona un tipo' : null,
        ),
      ],
    );
  }
}
