// ARCHIVO: lib/features/rates/domain/entities/rate_model.dart (NUEVO ARCHIVO)

class RateModel {
  final int id;
  final int serviceId; // <-- Campo importante para la lógica de la cotización
  final String nombreServicio;
  final String ciudad;
  final String costo;

  RateModel({
    required this.id,
    required this.serviceId,
    required this.nombreServicio,
    required this.ciudad,
    required this.costo,
  });

  factory RateModel.fromJson(Map<String, dynamic> json) {
    return RateModel(
      id: json['id_tarifa'],
      serviceId: json['id_servicio'],
      nombreServicio: json['servicio']['nombre_servicio'] ?? 'N/A',
      ciudad: json['ciudad'],
      costo: json['costo'],
    );
  }
}