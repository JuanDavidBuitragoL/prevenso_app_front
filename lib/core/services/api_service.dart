// =============================================================================
// ARCHIVO: lib/core/services/api_service.dart (NUEVO ARCHIVO)
// FUNCIÓN:   Centraliza todas las llamadas a la API en un solo lugar.
// =============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../features/auth/domain/entities/user_model.dart';

class ApiService {

  static const String _baseUrl = 'http://localhost:3000/api';

  // --- Método para el Login ---
  Future<Map<String, dynamic>> login(String nombreUsuario, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nombre_usuario': nombreUsuario,
        'password_raw': password,
      }),
    );

    if (response.statusCode == 200) {
      // Si el servidor devuelve un 200 OK, parseamos el JSON.
      return jsonDecode(response.body);
    } else {
      // Si el servidor devuelve un error, lanzamos una excepción.
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al iniciar sesión');
    }
  }

  // --- Método para obtener la lista de usuarios para el dropdown ---
  Future<List<String>> getUsuarios() async {
    final response = await http.get(Uri.parse('$_baseUrl/usuarios'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      // Extraemos solo los nombres de usuario de la lista
      return data.map((user) => user['nombre_usuario'] as String).toList();
    } else {
      throw Exception('Error al cargar la lista de usuarios');
    }
  }

  // --- Actualizar el perfil del usuario ---
  Future<UserModel> updateProfile(int userId, String newName, String token) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/usuarios/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // <-- ENVIAR EL TOKEN
      },
      body: jsonEncode(<String, String>{
        'nombre_usuario': newName,
      }),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al actualizar el perfil');
    }
  }
  // --- Obtener el perfil del usuario usando un token ---
  Future<UserModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // <-- Enviamos el token para autenticarnos
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      // Si el token es inválido o expiró, el backend devolverá un error 401
      throw Exception('Sesión inválida o expirada.');
    }
  }
  // --- Solicitar el reseteo de contraseña ---
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/forgot-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email}),
    );
    return jsonDecode(response.body);
  }

  // --- Enviar el token y la nueva contraseña ---
  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al resetear la contraseña');
    }
  }
}