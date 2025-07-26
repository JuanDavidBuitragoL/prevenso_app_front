// --- PASO 1.2: Crear el modelo de datos para las Tarifas ---
// ARCHIVO: lib/features/rates/domain/entities/rate_model.dart (NUEVO ARCHIVO)

class RateModel {
  final int id;
  final String nombreServicio;
  final String ciudad;
  final String costo;

  RateModel({
    required this.id,
    required this.nombreServicio,
    required this.ciudad,
    required this.costo,
  });

  factory RateModel.fromJson(Map<String, dynamic> json) {
    return RateModel(
      id: json['id_tarifa'],
      // El backend nos devuelve el nombre del servicio anidado
      nombreServicio: json['servicio']['nombre_servicio'] ?? 'Servicio Desconocido',
      ciudad: json['ciudad'],
      costo: json['costo'],
    );
  }
}

