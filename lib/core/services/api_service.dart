// =============================================================================
// ARCHIVO: lib/core/services/api_service.dart (NUEVO ARCHIVO)
// FUNCIÓN:   Centraliza todas las llamadas a la API en un solo lugar.
// =============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../features/auth/domain/entities/user_model.dart';
import '../../features/rates/domain/entities/rate_model.dart';
import '../../features/services/domain/entities/service_model.dart';

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
  Future<UserModel> register({
    required String nombreUsuario,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/usuarios'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nombre_usuario': nombreUsuario,
        'email': email,
        'password_raw': password,
      }),
    );

    if (response.statusCode == 201) { // 201 Created
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      // Captura errores del backend (ej. 409 Conflict si el usuario ya existe)
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al registrar el usuario');
    }
  }
  Future<List<RateModel>> getRates(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tarifas'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RateModel.fromJson(json)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al cargar las tarifas');
    }
  }
  // --- Obtener los detalles de una sola tarifa por su ID ---
  Future<RateModel> getRateById(int rateId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tarifas/$rateId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return RateModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al cargar la tarifa');
    }
  }

  // --- Eliminar una tarifa por su ID ---
  Future<void> deleteRate(int rateId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tarifas/$rateId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    // Una respuesta 204 No Content es un éxito para una operación de borrado
    if (response.statusCode != 204) {
      // Si hay un cuerpo de error, lo mostramos
      if (response.body.isNotEmpty) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Error al eliminar la tarifa');
      } else {
        throw Exception('Error al eliminar la tarifa. Código: ${response.statusCode}');
      }
    }
  }
  // --- Actualizar una tarifa por su ID ---
  Future<RateModel> updateRate({
    required int rateId,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/tarifas/$rateId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return RateModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al actualizar la tarifa');
    }
  }
  // --- Obtener la lista de todos los servicios para el dropdown ---
  Future<List<ServiceModel>> getServices(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/servicios'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los servicios');
    }
  }

  // --- Crear una nueva tarifa ---
  Future<RateModel> createRate({
    required int serviceId,
    required String city,
    required double cost,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tarifas'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'id_servicio': serviceId,
        'ciudad': city,
        'costo': cost,
      }),
    );

    if (response.statusCode == 201) {
      return RateModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al crear la tarifa');
    }
  }
}