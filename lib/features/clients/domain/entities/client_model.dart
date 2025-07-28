// ARCHIVO: lib/features/clients/domain/entities/client_model.dart (NUEVO ARCHIVO)

class ClientModel {
  final int id;
  final String nombre;
  final String? nit;
  final String? email;
  final String? telefono;
  final String? direccion;

  ClientModel({
    required this.id,
    required this.nombre,
    this.nit,
    this.email,
    this.telefono,
    this.direccion,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id_cliente'],
      nombre: json['nombre_cliente'],
      nit: json['nit_cliente'],
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
    );
  }
}