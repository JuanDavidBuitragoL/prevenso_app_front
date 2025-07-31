// ARCHIVO: lib/features/quotes/domain/entities/quote_model.dart (NUEVO ARCHIVO CORREGIDO)

// Modelo para un ítem individual dentro de una cotización
class QuoteItemModel {
  final int serviceId; // <-- CAMBIO: Se añade el ID del servicio
  final String serviceName;
  final int quantity;

  QuoteItemModel({
    required this.serviceId, // <-- CAMBIO: Se añade al constructor
    required this.serviceName,
    required this.quantity,
  });

  factory QuoteItemModel.fromJson(Map<String, dynamic> json) {
    return QuoteItemModel(
      serviceId: json['id_servicio'], // <-- CAMBIO: Se mapea desde el JSON
      serviceName: json['servicio']['nombre_servicio'] ?? 'N/A',
      quantity: json['cantidad'],
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
