import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _baseUrl = dotenv.get('API_BASE_URL', fallback:'http://10.0.2.2:8000/api/');
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = {..._headers};
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> post(String endpoint, dynamic data, {String? token}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = {..._headers};
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

// Add similar methods for PUT, PATCH, DELETE
}