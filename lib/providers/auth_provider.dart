import 'package:flutter/material.dart';
import 'package:boyshub/services/auth_service.dart';
import 'package:boyshub/services/storage_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final baseUrl = 'http://10.0.2.2:8000/api/';

  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await _storageService.getToken();
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.login(username, password);
      if (success) {
        await _loadToken();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _token = null;
    notifyListeners();
  }
  Future<bool> register(Map<String, dynamic> userData) async {
    final url = Uri.parse('${baseUrl}auth/register/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    return response.statusCode == 201;
  }
}