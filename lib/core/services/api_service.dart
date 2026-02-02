import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../../features/auth/domain/entities/user_model.dart';
import '../../features/clients/domain/entities/client_model.dart';
import '../../features/quotes/domain/entities/quote_model.dart';
import '../../features/rates/domain/entities/rate_model.dart';
import '../../features/services/domain/entities/service_model.dart';

class ApiService {

  static const String _baseUrl = 'https://prevenso-api.onrender.com/api';
  //static const String _baseUrl = 'http://localhost:3000/api';

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
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al iniciar sesión');
    }
  }

  Future<List<String>> getUsuarios() async {
    final response = await http.get(Uri.parse('$_baseUrl/usuarios'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => user['nombre_usuario'] as String).toList();
    } else {
      throw Exception('Error al cargar la lista de usuarios');
    }
  }

    Future<UserModel> updateProfile(int userId, String newName, String token) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/usuarios/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
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
    Future<UserModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Sesión inválida o expirada.');
    }
  }
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

    Future<Map<String, dynamic>> resetPassword(String email, String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
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

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
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

    Future<void> deleteRate(int rateId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tarifas/$rateId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      if (response.body.isNotEmpty) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Error al eliminar la tarifa');
      } else {
        throw Exception('Error al eliminar la tarifa. Código: ${response.statusCode}');
      }
    }
  }
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

    Future<List<ServiceModel>> getServices(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/servicios'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al cargar los servicios');
    }
  }
    Future<ServiceModel> updateService({
    required int serviceId,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/servicios/$serviceId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al actualizar el servicio');
    }
  }
    Future<ServiceModel> createService({
    required String nombre,
    required String tipo,
    String? duracion,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/servicios'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre_servicio': nombre,
        'tipo_servicio': tipo,
        'duracion': duracion,
      }),
    );

    if (response.statusCode == 201) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al crear el servicio');
    }
  }
    Future<void> deleteService(int serviceId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/servicios/$serviceId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      if (response.body.isNotEmpty) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Error al eliminar el servicio');
      } else {
        throw Exception('Error al eliminar el servicio. Código: ${response.statusCode}');
      }
    }
  }
    Future<List<ClientModel>> getClients(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/clientes'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ClientModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los clientes');
    }

  }

    Future<void> deleteClient(int clientId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/clientes/$clientId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al eliminar el cliente');
    }
  }
    Future<ClientModel> createClient({
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/clientes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return ClientModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al crear el cliente');
    }
  }
    Future<ClientModel> updateClient({
    required int clientId,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/clientes/$clientId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return ClientModel.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al actualizar el cliente');
    }
  }
    Future<List<QuoteModel>> getQuotes(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cotizaciones'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => QuoteModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las cotizaciones');
    }
  }
    Future<QuoteModel> getQuoteById(int quoteId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cotizaciones/$quoteId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return QuoteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar los detalles de la cotización');
    }
  }

    Future<void> createQuote({
    required Map<String, dynamic> quoteData,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cotizaciones'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(quoteData),
    );

    if (response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al crear la cotización');
    }
  }
    Future<void> deleteQuote(int quoteId, String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/cotizaciones/$quoteId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la cotización');
    }
  }

    Future<void> updateQuote({
    required int quoteId,
    required Map<String, dynamic> quoteData,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/cotizaciones/$quoteId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(quoteData),
    );
    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al actualizar la cotización');
    }
  }
    Future<Uint8List> getQuotePdf(int quoteId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cotizaciones/$quoteId/pdf'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Error al descargar el PDF');
      } catch (_) {
        throw Exception('Error desconocido al descargar el PDF. Código: ${response.statusCode}');
      }
    }
  }
  Future<Map<String, dynamic>> getLatestVersion() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/version/latest'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('No se pudo verificar la versión de la aplicación.');
    }
  }
}