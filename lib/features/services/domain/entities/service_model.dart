
class ServiceModel {
  final int id;
  final String nombre;
  final String tipo;
  final String? duracion;

  ServiceModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.duracion,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id_servicio'],
      nombre: json['nombre_servicio'],
      tipo: json['tipo_servicio'],
      duracion: json['duracion'],
    );
  }
}
