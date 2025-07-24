// ARCHIVO: lib/features/auth/domain/entities/user_model.dart (NUEVO ARCHIVO)

class UserModel {
  final int id;
  String nombre_usuario;
  final String email;

  UserModel(
      {required this.id, required this.nombre_usuario, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_usuario'],
      nombre_usuario: json['nombre_usuario'],
      email: json['email'],
    );
  }
}