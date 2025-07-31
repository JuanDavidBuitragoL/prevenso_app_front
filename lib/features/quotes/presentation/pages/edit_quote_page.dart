// ARCHIVO: lib/features/quotes/presentation/pages/edit_quote_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../clients/domain/entities/client_model.dart';
import '../../../rates/domain/entities/rate_model.dart';
import '../../domain/entities/quote_model.dart';

// Modelo para manejar los ítems seleccionados en la UI
class SelectedItem {
  final int serviceId;
  final String serviceName;
  final double unitPrice;
  int quantity;

  SelectedItem({
    required this.serviceId,
    required this.serviceName,
    required this.unitPrice,
    this.quantity = 1,
  });
}

class EditQuotePage extends StatefulWidget {
  final QuoteModel quote;
  const EditQuotePage({super.key, required this.quote});

  @override
  State<EditQuotePage> createState() => _EditQuotePageState();
}

class _EditQuotePageState extends State<EditQuotePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Estado del formulario
  ClientModel? _selectedClient;
  String? _selectedCity;
  final List<SelectedItem> _selectedItems = [];
  double _totalValue = 0.0;
  bool _isLoadingData = true; // Nuevo estado para la carga inicial
  bool _isSubmitting = false; // Nuevo estado para el envío

  List<ClientModel> _availableClients = [];
  List<RateModel> _availableRates = [];
  List<String> _availableCities = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null) return;

    try {
      final results = await Future.wait([
        _apiService.getClients(authProvider.token!),
        _apiService.getRates(authProvider.token!),
      ]);

      final clients = results[0] as List<ClientModel>;
      final rates = results[1] as List<RateModel>;
      final cities = rates.map((r) => r.ciudad).toSet().toList();

      if (mounted) {
        setState(() {
          _availableClients = clients;
          _availableRates = rates;
          _availableCities = cities;

          // --- Pre-poblar el formulario con los datos de la cotización existente ---
          _selectedClient = clients.firstWhere((c) => c.nombre == widget.quote.clientName, orElse: () => clients.first);

          if (widget.quote.items.isNotEmpty) {
            final firstItemInQuote = widget.quote.items.first;
            final rateForFirstItem = rates.firstWhere(
                  (r) => r.serviceId == firstItemInQuote.serviceId,
              orElse: () => rates.first, // Fallback
            );
            _selectedCity = rateForFirstItem.ciudad;
          }

          _selectedItems.addAll(widget.quote.items.map((item) {
            final rate = rates.firstWhere((r) => r.serviceId == item.serviceId && r.ciudad == _selectedCity);
            return SelectedItem(
              serviceId: item.serviceId,
              serviceName: item.serviceName,
              quantity: item.quantity,
              unitPrice: double.parse(rate.costo),
            );
          }));
          _calculateTotal();
          _isLoadingData = false; // Termina la carga inicial
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _addItem(RateModel? rate) {
    if (rate != null && !_selectedItems.any((item) => item.serviceId == rate.serviceId)) {
      setState(() {
        _selectedItems.add(SelectedItem(
          serviceId: rate.serviceId,
          serviceName: rate.nombreServicio,
          unitPrice: double.parse(rate.costo),
        ));
        _calculateTotal();
      });
    }
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      if (_selectedItems[index].quantity + change > 0) {
        _selectedItems[index].quantity += change;
        _calculateTotal();
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _selectedItems) {
      total += item.unitPrice * item.quantity;
    }
    _totalValue = total;
  }

  Future<void> _submitQuote(String status) async {
    if (!(_formKey.currentState?.validate() ?? false) || _selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un cliente y añade al menos un servicio.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null || authProvider.user == null) return;

    final quoteData = {
      'id_usuario': authProvider.user!.id,
      'id_cliente': _selectedClient!.id,
      'ciudad': _selectedCity!,
      'estado': status,
      'items': _selectedItems.map((item) => {
        'id_servicio': item.serviceId,
        'cantidad': item.quantity,
      }).toList(),
    };

    try {
      await _apiService.updateQuote(quoteId: widget.quote.id, quoteData: quoteData, token: authProvider.token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cotización actualizada con éxito'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratesForSelectedCity = _selectedCity == null
        ? <RateModel>[]
        : _availableRates.where((r) => r.ciudad == _selectedCity).toList();

    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cotización'),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Editando Cotización #${widget.quote.id}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00C6AD))),
                const SizedBox(height: 30),

                _buildSectionTitle('Cliente*'),
                DropdownButtonFormField<ClientModel>(
                  value: _selectedClient,
                  hint: const Text('Seleccione un cliente'),
                  items: _availableClients.map((client) => DropdownMenuItem(value: client, child: Text(client.nombre))).toList(),
                  onChanged: (client) => setState(() => _selectedClient = client),
                  validator: (value) => value == null ? 'Seleccione un cliente' : null,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Ciudad*'),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  hint: const Text('Seleccione una ciudad'),
                  items: _availableCities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                  onChanged: (city) => setState(() => _selectedCity = city),
                  validator: (value) => value == null ? 'Seleccione una ciudad' : null,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Añadir Servicio'),
                DropdownButtonFormField<RateModel>(
                  hint: Text(_selectedCity == null ? 'Primero seleccione una ciudad' : 'Seleccione un servicio para añadir'),
                  items: ratesForSelectedCity.map((rate) => DropdownMenuItem(value: rate, child: Text(rate.nombreServicio))).toList(),
                  onChanged: _selectedCity == null ? null : _addItem,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 16),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = _selectedItems[index];
                    return _TariffListItem(
                      name: item.serviceName,
                      quantity: item.quantity,
                      onRemove: () => _removeItem(index),
                      onIncrement: () => _updateQuantity(index, 1),
                      onDecrement: () => _updateQuantity(index, -1),
                    );
                  },
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Valor total'),
                TextFormField(
                  controller: TextEditingController(text: currencyFormatter.format(_totalValue)),
                  readOnly: true,
                  decoration: _inputDecoration().copyWith(filled: true, fillColor: Colors.grey.shade100),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitQuote('creada'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                    child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Finalizar y Guardar', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitQuote('borrador'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F54EB), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                    child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar como Borrador', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.black54, fontSize: 16),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

class _TariffListItem extends StatelessWidget {
  final String name;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _TariffListItem({
    required this.name,
    required this.quantity,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
            ),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDecrement,
            ),
            Text(
              quantity.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}
