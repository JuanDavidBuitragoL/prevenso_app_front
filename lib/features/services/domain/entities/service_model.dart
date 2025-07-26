// --- PASO 1.2: Crear el modelo de datos para los Servicios ---
// ARCHIVO: lib/features/services/domain/entities/service_model.dart (NUEVO ARCHIVO)

class ServiceModel {
  final int id;
  final String nombre;

  ServiceModel({required this.id, required this.nombre});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id_servicio'],
      nombre: json['nombre_servicio'],
    );
  }
}