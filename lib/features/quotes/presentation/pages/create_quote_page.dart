// VERSIÓN: V2.1 (Recargos por Ítem)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prevenso_app_front/features/quotes/presentation/pages/rate_search_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../clients/domain/entities/client_model.dart';
import '../../../rates/domain/entities/rate_model.dart';

enum DiscountType { porcentaje, fijo }

class SelectedItem {
  final int serviceId;
  final String serviceName;
  final double unitPrice;
  int quantity;
  DiscountType? discountType;
  double? discountValue;
  double surcharge; // <--- NUEVO: Recargo específico para este ítem

  SelectedItem({
    required this.serviceId,
    required this.serviceName,
    required this.unitPrice,
    this.quantity = 1,
    this.discountType,
    this.discountValue,
    this.surcharge = 0.0, // Por defecto 0
  });

  double get finalUnitPrice {
    double base;
    if (discountType == null || discountValue == null || discountValue == 0) {
      base = unitPrice;
    } else if (discountType == DiscountType.fijo) {
      base = (unitPrice - discountValue!) > 0 ? (unitPrice - discountValue!) : 0;
    } else { // porcentaje
      base = unitPrice * (1 - (discountValue! / 100));
    }

    return base + surcharge;
  }

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

  ClientModel? _selectedClient;
  String? _selectedCity;
  final List<SelectedItem> _selectedItems = [];
  double _totalValue = 0.0;
  bool _isLoading = false;

    final TextEditingController _observationsController = TextEditingController();

  List<ClientModel> _availableClients = [];
  List<RateModel> _availableRates = [];
  List<String> _availableCities = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
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
      total += item.subtotal; // Suma subtotales que ya incluyen sus recargos
    }
    _totalValue = total;
  }

    void _showPriceAdjustmentDialog(int index) {
    final item = _selectedItems[index];

    // Controladores
    final discountController = TextEditingController(text: item.discountValue?.toStringAsFixed(0) ?? '');
    final surchargeController = TextEditingController(text: item.surcharge > 0 ? item.surcharge.toStringAsFixed(0) : '');

    DiscountType? currentDiscountType = item.discountType ?? DiscountType.porcentaje;
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
              title: const Text('Ajustar Precio', textAlign: TextAlign.center),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        item.serviceName,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(height: 30),

                                        const Text('Descuento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 10),
                    Center(
                      child: ToggleButtons(
                        isSelected: isSelected,
                        onPressed: (int newIndex) {
                          setDialogState(() {
                            for (int i = 0; i < isSelected.length; i++) {
                              isSelected[i] = i == newIndex;
                            }
                            currentDiscountType = newIndex == 0 ? DiscountType.porcentaje : DiscountType.fijo;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        selectedColor: Colors.white,
                        fillColor: Colors.green,
                        color: Colors.green,
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('%')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('\$')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: discountController,
                      decoration: _inputDecoration().copyWith(
                        labelText: 'Valor a descontar',
                        prefixIcon: const Icon(Icons.remove_circle_outline, color: Colors.green),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 25),

                                        const Text('Recargo / Adicional', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: surchargeController,
                      decoration: _inputDecoration().copyWith(
                        labelText: 'Valor extra (Viáticos, etc.)',
                        prefixIcon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                        suffixText: 'COP',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.all(16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Limpiar todo
                          setState(() {
                            _selectedItems[index].discountType = null;
                            _selectedItems[index].discountValue = null;
                            _selectedItems[index].surcharge = 0.0;
                            _calculateTotal();
                          });
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Guardar Descuento
                            double dVal = double.tryParse(discountController.text) ?? 0.0;
                            if (dVal > 0) {
                              _selectedItems[index].discountType = currentDiscountType;
                              _selectedItems[index].discountValue = dVal;
                            } else {
                              _selectedItems[index].discountType = null;
                              _selectedItems[index].discountValue = null;
                            }

                            // Guardar Recargo
                            _selectedItems[index].surcharge = double.tryParse(surchargeController.text) ?? 0.0;

                            _calculateTotal();
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        child: const Text('Aplicar'),
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

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null || authProvider.user == null) return;

    final quoteData = {
      'id_usuario': authProvider.user!.id,
      'id_cliente': _selectedClient!.id,
      'ciudad': _selectedCity!,
      'estado': status,
      'observaciones': _observationsController.text, // Solo observaciones global
      // 'recargo': ... ELIMINADO GLOBAL
      'items': _selectedItems.map((item) => {
        'id_servicio': item.serviceId,
        'cantidad': item.quantity,
        'tipo_descuento': item.discountType?.name,
        'valor_descuento': item.discountValue,
        'recargo': item.surcharge, // <--- EL RECARGO VA AQUÍ AHORA
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

  Future<void> _openRateSearch() async {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione una ciudad primero.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final ratesForSelectedCity = _availableRates.where((r) => r.ciudad == _selectedCity).toList();

    final RateModel? selectedRate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateSearchPage(availableRates: ratesForSelectedCity),
      ),
    );

    if (selectedRate != null) {
      _addItem(selectedRate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

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
                const Text('Nueva cotización', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00C6AD))),
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
                      onAdjustPrice: () => _showPriceAdjustmentDialog(index), // <--- NUEVO CALLBACK
                    );
                  },
                ),
                const SizedBox(height: 20),

                                _buildSectionTitle('Observaciones'),
                TextFormField(
                  controller: _observationsController,
                  maxLines: 3,
                  decoration: _inputDecoration().copyWith(
                    hintText: 'Escriba aquí notas importantes...',
                    alignLabelWithHint: true,
                  ),
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF00C6AD), width: 2),
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 40),

                // Botones Guardar...
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitQuote('creada'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Generar cotización', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitQuote('borrador'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F54EB), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar y salir', style: TextStyle(fontSize: 16)),
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
      child: Text(title, style: const TextStyle(color: Colors.black54, fontSize: 16)),
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
  final VoidCallback onAdjustPrice; // <--- Renombrado de onDiscount

  const _TariffListItem({
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAdjustPrice,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    // Verificamos si tiene descuento O recargo para mostrar el detalle
    final hasAdjustments = (item.discountType != null && item.discountValue != null && item.discountValue! > 0) || item.surcharge > 0;

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
                Expanded(child: Text(item.serviceName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onDecrement),
                Text(item.quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onIncrement),
                // Botón de ajuste de precio (Etiqueta si tiene cambios)
                IconButton(
                  icon: Icon(Icons.price_change_outlined, color: hasAdjustments ? Colors.blue : Colors.grey),
                  onPressed: onAdjustPrice,
                  tooltip: "Ajustar precio / Recargo",
                ),
              ],
            ),
                        if (hasAdjustments)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: [
                    const Divider(),
                    // 1. Precio Base
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Precio Base:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(currencyFormatter.format(item.unitPrice), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    // 2. Descuento (Si hay)
                    if (item.discountValue != null && item.discountValue! > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Descuento:', style: TextStyle(color: Colors.green, fontSize: 12)),
                          Text(
                            item.discountType == DiscountType.porcentaje
                                ? '-${item.discountValue}%'
                                : '-${currencyFormatter.format(item.discountValue)}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    // 3. Recargo (Si hay)
                    if (item.surcharge > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recargo:', style: TextStyle(color: Colors.orange, fontSize: 12)),
                          Text('+${currencyFormatter.format(item.surcharge)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    // 4. Subtotal Final del Ítem
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Ítem:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(currencyFormatter.format(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
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