// =============================================================================
// ARCHIVO: lib/features/quotes/presentation/pages/edit_quote_page.dart
// FUNCIÓN:   Pantalla completa para editar una cotización existente (borrador).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../clients/domain/entities/client_model.dart';
import '../../../rates/domain/entities/rate_model.dart';
import '../../domain/entities/quote_model.dart';

// Enum para el tipo de descuento, debe coincidir con el backend
enum DiscountType { porcentaje, fijo }

// Modelo para manejar los ítems seleccionados en la UI
class SelectedItem {
  final int serviceId;
  final String serviceName;
  final double unitPrice;
  int quantity;
  DiscountType? discountType;
  double? discountValue;

  SelectedItem({
    required this.serviceId,
    required this.serviceName,
    required this.unitPrice,
    this.quantity = 1,
    this.discountType,
    this.discountValue,
  });

  double get finalUnitPrice {
    if (discountType == null || discountValue == null || discountValue == 0) {
      return unitPrice;
    }
    if (discountType == DiscountType.fijo) {
      return (unitPrice - discountValue!) > 0 ? (unitPrice - discountValue!) : 0;
    }
    if (discountType == DiscountType.porcentaje) {
      return unitPrice * (1 - (discountValue! / 100));
    }
    return unitPrice;
  }

  double get subtotal => finalUnitPrice * quantity;
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
  bool _isLoadingData = true;
  bool _isSubmitting = false;

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
    if (authProvider.token == null) {
      setState(() => _isLoadingData = false);
      return;
    }

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

          // --- CORRECCIÓN: Se maneja el caso de lista vacía antes de llamar a firstWhere ---
          if (clients.isNotEmpty) {
            _selectedClient = clients.firstWhere(
                  (c) => c.nombre == widget.quote.clientName,
              // Ahora este orElse es seguro porque sabemos que la lista no está vacía.
              orElse: () => clients.first,
            );
          }

          if (widget.quote.items.isNotEmpty) {
            final firstItemInQuote = widget.quote.items.first;
            final rateForFirstItem = rates.firstWhere(
                  (r) => r.serviceId == firstItemInQuote.serviceId,
              orElse: () => rates.first,
            );
            _selectedCity = rateForFirstItem.ciudad;
          }

          _selectedItems.addAll(widget.quote.items.map((item) {
            final rate = _availableRates.firstWhere((r) => r.serviceId == item.serviceId && r.ciudad == _selectedCity);
            return SelectedItem(
              serviceId: item.serviceId,
              serviceName: item.serviceName,
              quantity: item.quantity,
              unitPrice: double.parse(rate.costo),
              discountType: item.discountType == 'porcentaje' ? DiscountType.porcentaje : (item.discountType == 'fijo' ? DiscountType.fijo : null),
              discountValue: item.discountValue,
            );
          }));
          _calculateTotal();
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
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
      total += item.subtotal;
    }
    _totalValue = total;
  }

  // --- _showDiscountDialog (COMPLETAMENTE REDISEÑADO) ---
  void _showDiscountDialog(int index) {
    final item = _selectedItems[index];
    final valueController = TextEditingController(text: item.discountValue?.toStringAsFixed(0) ?? '');
    DiscountType? currentDiscountType = item.discountType;

    List<bool> isSelected = [
      currentDiscountType == DiscountType.porcentaje,
      currentDiscountType == DiscountType.fijo,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  const Icon(Icons.sell_outlined, size: 32, color: AppTheme.primaryColor),
                  const SizedBox(height: 8),
                  const Text('Aplicar Descuento', textAlign: TextAlign.center),
                  Text(
                    item.serviceName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppTheme.subtleTextColor),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToggleButtons(
                    isSelected: isSelected,
                    onPressed: (int newIndex) {
                      setDialogState(() {
                        for (int i = 0; i < isSelected.length; i++) {
                          isSelected[i] = i == newIndex;
                        }
                        currentDiscountType = newIndex == 0 ? DiscountType.porcentaje : DiscountType.fijo;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: AppTheme.primaryColor,
                    color: AppTheme.primaryColor,
                    constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Porcentaje')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Monto Fijo')),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: valueController,
                    decoration: _inputDecoration().copyWith(
                      labelText: 'Valor del descuento',
                      prefixIcon: currentDiscountType == DiscountType.fijo ? const Icon(Icons.attach_money) : null,
                      suffixIcon: currentDiscountType == DiscountType.porcentaje ? const Icon(Icons.percent) : null,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: [
                // --- BOTONES DE ACCIÓN REDISEÑADOS ---
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedItems[index].discountType = null;
                            _selectedItems[index].discountValue = null;
                            _calculateTotal();
                          });
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Quitar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedItems[index].discountType = currentDiscountType;
                            _selectedItems[index].discountValue = double.tryParse(valueController.text) ?? 0.0;
                            _calculateTotal();
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
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
        'tipo_descuento': item.discountType?.name,
        'valor_descuento': item.discountValue,
      }).toList(),
    };

    try {
      await _apiService.updateQuote(quoteId: widget.quote.id, quoteData: quoteData, token: authProvider.token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cotización actualizada con éxito'), backgroundColor: Colors.green),
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
                  isExpanded: true,
                  value: _selectedClient,
                  hint: const Text('Seleccione un cliente'),
                  items: _availableClients.map((client) => DropdownMenuItem(value: client, child: Text(client.nombre, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (client) => setState(() => _selectedClient = client),
                  validator: (value) => value == null ? 'Seleccione un cliente' : null,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Ciudad*'),
                DropdownButtonFormField<String>(
                  isExpanded: true,
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
                  isExpanded: true,
                  hint: Text(_selectedCity == null ? 'Primero seleccione una ciudad' : 'Seleccione un servicio para añadir'),
                  items: ratesForSelectedCity.map((rate) {
                    return DropdownMenuItem<RateModel>(
                      value: rate,
                      child: Text(rate.nombreServicio, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
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
                      item: item,
                      onRemove: () => _removeItem(index),
                      onIncrement: () => _updateQuantity(index, 1),
                      onDecrement: () => _updateQuantity(index, -1),
                      onDiscount: () => _showDiscountDialog(index),
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

// --- WIDGET _TariffListItem (COMPLETAMENTE REDISEÑADO) ---
class _TariffListItem extends StatelessWidget {
  final SelectedItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDiscount;

  const _TariffListItem({
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final hasDiscount = item.discountType != null && item.discountValue != null && item.discountValue! > 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onRemove),
              Expanded(
                child: Text(
                  item.serviceName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(icon: const Icon(Icons.remove_circle_outline, size: 22), onPressed: onDecrement),
              Text(item.quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline, size: 22), onPressed: onIncrement),
              IconButton(
                icon: Icon(Icons.sell_outlined, color: hasDiscount ? AppTheme.primaryColor : Colors.grey, size: 20),
                onPressed: onDiscount,
              ),
            ],
          ),
          if (hasDiscount)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Precio Base:', style: TextStyle(color: AppTheme.subtleTextColor)),
                        Text(currencyFormatter.format(item.unitPrice), style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppTheme.subtleTextColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Precio Final:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(currencyFormatter.format(item.finalUnitPrice), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
