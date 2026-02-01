
//            todos los campos necesarios para los detalles.

class QuoteItemModel {
  final int serviceId;
  final String serviceName;
  final int quantity;
  final String? discountType;
  final double? discountValue;
  final double priceBaseUnit;
  final double priceFinalUnit;
  final double subtotal;
  final double? surcharge; // <-- NUEVO campo para recargo individual

  QuoteItemModel({
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    this.discountType,
    this.discountValue,
    required this.priceBaseUnit,
    required this.priceFinalUnit,
    required this.subtotal,
    this.surcharge, // <-- NUEVO campo opcional
  });

  factory QuoteItemModel.fromJson(Map<String, dynamic> json) {
    return QuoteItemModel(
      serviceId: json['id_servicio'],
      serviceName: json['servicio']['nombre_servicio'] ?? 'N/A',
      quantity: json['cantidad'],
      discountType: json['tipo_descuento'],
      discountValue: json['valor_descuento'] != null ? double.tryParse(json['valor_descuento'].toString()) : null,
      priceBaseUnit: double.parse(json['precio_base_unitario'].toString()),
      priceFinalUnit: double.parse(json['precio_final_unitario'].toString()),
      subtotal: double.parse(json['subtotal_item'].toString()),
      surcharge: json['recargo'] != null ? double.tryParse(json['recargo'].toString()) : null, // <-- NUEVO campo del JSON
    );
  }
}

// Modelo principal para una Cotización
class QuoteModel {
  final int id;
  final String clientName;
  final int clientId;
  final String userName;
  final DateTime creationDate;
  final String status;
  final double totalValue;
  final String? observations;
  final double? surcharge;
  final List<QuoteItemModel> items;

  QuoteModel({
    required this.id,
    required this.clientName,
    required this.clientId,
    required this.userName,
    required this.creationDate,
    required this.status,
    required this.totalValue,
    this.observations,
    this.surcharge,
    required this.items,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<QuoteItemModel> parsedItems = itemsList.map((i) => QuoteItemModel.fromJson(i)).toList();

    return QuoteModel(
      id: json['id_cotizacion'],
      clientName: json['cliente']['nombre_cliente'] ?? 'N/A',
      clientId: json['id_cliente'],
      userName: json['usuario']['nombre_usuario'] ?? 'N/A',
      creationDate: DateTime.parse(json['fecha_creacion']),
      status: json['estado'],
      totalValue: double.parse(json['costo_total'].toString()),
      observations: json['observaciones'],
      surcharge: json['recargo'] != null ? double.tryParse(json['recargo'].toString()) : 0.0,
      items: parsedItems,
    );
  }
}