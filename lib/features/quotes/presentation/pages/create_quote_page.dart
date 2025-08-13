// --- PASO 2.1: Refactorizar CreateQuotePage para ser dinámica y funcional ---
// ARCHIVO: lib/features/quotes/presentation/pages/create_quote_page.dart (VERSIÓN FINAL)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prevenso_app_front/features/quotes/presentation/pages/rate_search_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../clients/domain/entities/client_model.dart';
import '../../../rates/domain/entities/rate_model.dart';

// --- ENUM para el tipo de descuento ---
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

  // Calcula el precio final de una unidad después del descuento
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

  // Calcula el subtotal del ítem (precio final * cantidad)
  double get subtotal => finalUnitPrice * quantity;
}

class CreateQuotePage extends StatefulWidget {
  const CreateQuotePage({super.key});

  @override
  State<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends State<CreateQuotePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Estado del formulario
  ClientModel? _selectedClient;
  String? _selectedCity;
  final List<SelectedItem> _selectedItems = [];
  double _totalValue = 0.0;
  bool _isLoading = false;

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

      setState(() {
        _availableClients = clients;
        _availableRates = rates;
        _availableCities = cities;
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
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
      total += item.subtotal; // Usamos el subtotal que ya considera el descuento
    }
    _totalValue = total;
  }

  // --- Muestra el diálogo para añadir/editar un descuento ---
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
    if (!(_formKey.currentState?.validate() ?? false) ||
        _selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, selecciona un cliente y añade al menos un servicio.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null || authProvider.user == null) return;

    // --- Lógica de envío para incluir descuentos ---
    final quoteData = {
      'id_usuario': authProvider.user!.id,
      'id_cliente': _selectedClient!.id,
      'ciudad': _selectedCity!,
      'estado': status,
      'items': _selectedItems.map((item) => {
        'id_servicio': item.serviceId,
        'cantidad': item.quantity,
        'tipo_descuento': item.discountType?.name, // 'porcentaje' o 'fijo'
        'valor_descuento': item.discountValue,
      }).toList(),
    };

    try {
      await _apiService.createQuote(quoteData: quoteData, token: authProvider.token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cotización guardada como $status con éxito'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // --- Abre la pantalla de búsqueda de tarifas ---
  Future<void> _openRateSearch() async {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione una ciudad primero.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final ratesForSelectedCity = _availableRates.where((r) => r.ciudad == _selectedCity).toList();

    // Navegamos a la nueva pantalla de búsqueda y esperamos a que nos devuelva una tarifa
    final RateModel? selectedRate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateSearchPage(availableRates: ratesForSelectedCity),
      ),
    );

    // Si el usuario seleccionó una tarifa, la añadimos a la lista
    if (selectedRate != null) {
      _addItem(selectedRate);
    }
  }


  @override
  Widget build(BuildContext context) {
    final ratesForSelectedCity = _selectedCity == null
        ? <RateModel>[]
        : _availableRates.where((r) => r.ciudad == _selectedCity).toList();

    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

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
                  'Nueva cotización',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C6AD),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Dropdown de Cliente ---
                _buildSectionTitle('Cliente*'),
                DropdownButtonFormField<ClientModel>(
                  isExpanded: true,
                  // <-- Buena práctica añadirlo aquí también
                  value: _selectedClient,
                  hint: const Text('Seleccione un cliente'),
                  items: _availableClients
                      .map(
                        (client) => DropdownMenuItem(
                          value: client,
                          child: Text(
                            client.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (client) =>
                      setState(() => _selectedClient = client),
                  validator: (value) =>
                      value == null ? 'Seleccione un cliente' : null,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 20),

                // --- Dropdown de Ciudad ---
                _buildSectionTitle('Ciudad*'),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  // <-- Buena práctica añadirlo aquí también
                  value: _selectedCity,
                  hint: const Text('Seleccione una ciudad'),
                  items: _availableCities
                      .map(
                        (city) =>
                            DropdownMenuItem(value: city, child: Text(city)),
                      )
                      .toList(),
                  onChanged: (city) => setState(() => _selectedCity = city),
                  validator: (value) =>
                      value == null ? 'Seleccione una ciudad' : null,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 20),

                // --- Dropdown de Servicio  ---
                _buildSectionTitle('Añadir Servicio'),
                InkWell(
                  onTap: _openRateSearch,
                  borderRadius: BorderRadius.circular(12.0),
                  child: InputDecorator(
                    decoration: _inputDecoration().copyWith(
                      hintText: _selectedCity == null ? 'Primero seleccione una ciudad' : 'Toca para buscar un servicio...',
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Buscar Servicio', style: TextStyle(color: AppTheme.subtleTextColor, fontSize: 16)),
                        Icon(Icons.search, color: AppTheme.subtleTextColor),
                      ],
                    ),
                  ),
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
                  controller: TextEditingController(
                    text: currencyFormatter.format(_totalValue),
                  ),
                  readOnly: true,
                  decoration: _inputDecoration().copyWith(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitQuote('creada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Generar cotización',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _submitQuote('borrador'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F54EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Guardar y salir',
                            style: TextStyle(fontSize: 16),
                          ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onRemove),
                Expanded(child: Text(item.serviceName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onDecrement),
                Text(item.quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onIncrement),
                // --- NUEVO BOTÓN PARA DESCUENTOS ---
                IconButton(
                  icon: Icon(Icons.sell_outlined, color: hasDiscount ? Colors.blue : Colors.grey),
                  onPressed: onDiscount,
                ),
              ],
            ),
            // --- Muestra el detalle del precio y descuento ---
            if (hasDiscount)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Precio Base:'),
                        Text(currencyFormatter.format(item.unitPrice), style: const TextStyle(decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Precio Final:'),
                        Text(currencyFormatter.format(item.finalUnitPrice), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
