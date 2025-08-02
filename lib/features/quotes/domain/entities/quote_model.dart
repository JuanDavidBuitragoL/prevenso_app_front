// =============================================================================
// ARCHIVO: lib/features/quotes/domain/entities/quote_model.dart (VERSIÓN CORREGIDA)
// FUNCIÓN:   Define los modelos de datos para las cotizaciones, incluyendo
//            todos los campos necesarios para los detalles.
// =============================================================================

// Modelo para un ítem individual dentro de una cotización
class QuoteItemModel {
  final int serviceId;
  final String serviceName;
  final int quantity;
  final String? discountType;
  final double? discountValue;
  final double priceBaseUnit;
  final double priceFinalUnit;
  final double subtotal;

  QuoteItemModel({
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    this.discountType,
    this.discountValue,
    required this.priceBaseUnit,
    required this.priceFinalUnit,
    required this.subtotal,
  });

  factory QuoteItemModel.fromJson(Map<String, dynamic> json) {
    return QuoteItemModel(
      serviceId: json['id_servicio'],
      serviceName: json['servicio']['nombre_servicio'] ?? 'N/A',
      quantity: json['cantidad'],
      discountType: json['tipo_descuento'],
      // --- CORRECCIÓN: Se usa double.tryParse para manejar el string de forma segura ---
      discountValue: json['valor_descuento'] != null ? double.tryParse(json['valor_descuento'].toString()) : null,
      priceBaseUnit: double.parse(json['precio_base_unitario'].toString()),
      priceFinalUnit: double.parse(json['precio_final_unitario'].toString()),
      subtotal: double.parse(json['subtotal_item'].toString()),
    );
  }
}

// Modelo principal para una Cotización
class QuoteModel {
  final int id;
  final String clientName;
  final String userName;
  final DateTime creationDate;
  final String status;
  final String totalValue;
  final List<QuoteItemModel> items;

  QuoteModel({
    required this.id,
    required this.clientName,
    required this.userName,
    required this.creationDate,
    required this.status,
    required this.totalValue,
    required this.items,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<QuoteItemModel> parsedItems = itemsList.map((i) => QuoteItemModel.fromJson(i)).toList();

    return QuoteModel(
      id: json['id_cotizacion'],
      clientName: json['cliente']['nombre_cliente'] ?? 'N/A',
      userName: json['usuario']['nombre_usuario'] ?? 'N/A',
      creationDate: DateTime.parse(json['fecha_creacion']),
      status: json['estado'],
      totalValue: json['costo_total'],
      items: parsedItems,
    );
  }
}