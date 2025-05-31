import 'package:boyshub/services/api_service.dart';
import 'package:boyshub/services/storage_service.dart';
import 'dart:convert';

class AuthService {
  final StorageService _storageService = StorageService();

  Future<bool> login(String username, String password) async {
    try {
      final response = await ApiService.post('token-auth/', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        await _storageService.saveToken(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.post('profiles/register/', userData);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}