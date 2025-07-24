
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user_model.dart';

// La clase UserModel ya no vive aquí

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    _token = await _storageService.getToken();

    if (_token == null) {
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final userProfile = await _apiService.getProfile(_token!);
      _user = userProfile;
      _isLoggedIn = true;
    } catch (e) {
      await _storageService.deleteToken();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String nombreUsuario, String password) async {
    final result = await _apiService.login(nombreUsuario, password);
    _token = result['token'];
    _user = UserModel.fromJson(result['user']);
    _isLoggedIn = true;
    await _storageService.saveToken(_token!);
    notifyListeners();
  }

  Future<void> updateUserName(String newName) async {
    if (_user == null || _token == null) return;
    final updatedUser = await _apiService.updateProfile(_user!.id, newName, _token!);
    _user!.nombre_usuario = updatedUser.nombre_usuario;
    notifyListeners();
  }

  void logout() async {
    _user = null;
    _token = null;
    _isLoggedIn = false;
    await _storageService.deleteToken();
    notifyListeners();
  }
  // --- Llamar al servicio de forgotPassword ---
  Future<String> forgotPassword(String email) async {
    try {
      final result = await _apiService.forgotPassword(email);
      return result['message']; // Devuelve el mensaje de éxito
    } catch (e) {
      print('Error en forgotPassword provider: $e');
      throw e;
    }
  }

  // --- Llamar al servicio de resetPassword ---
  Future<String> resetPassword(String token, String newPassword) async {
    try {
      final result = await _apiService.resetPassword(token, newPassword);
      return result['message'];
    } catch (e) {
      print('Error en resetPassword provider: $e');
      throw e;
    }
  }
}
