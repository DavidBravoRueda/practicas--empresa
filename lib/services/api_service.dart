
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Más adelante pondremos aquí la URL real de Laravel.
  static const String baseUrl =
    'https://practicas2026.logicsistemas.es';

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'sanctum_token';

  // INICIAR SESIÓN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = _decodeResponse(response);
    final token = data['token'];

    if (token is! String || token.isEmpty) {
      throw ApiException('La API no ha devuelto un token válido.');
    }

    await _storage.write(key: _tokenKey, value: token);

    return Map<String, dynamic>.from(data['user'] as Map);
  }

  // REGISTRAR USUARIO
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/registro'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = _decodeResponse(response);
    final token = data['token'];

    if (token is! String || token.isEmpty) {
      throw ApiException('La API no ha devuelto un token válido.');
    }

    await _storage.write(key: _tokenKey, value: token);

    return Map<String, dynamic>.from(data['user'] as Map);
  }

  // OBTENER USUARIO DE LA SESIÓN GUARDADA
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/usuario'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await _storage.delete(key: _tokenKey);
      return null;
    }

    final data = _decodeResponse(response);

    return Map<String, dynamic>.from(data['user'] as Map);
  }

  // CERRAR SESIÓN
  static Future<void> logout() async {
    final token = await _storage.read(key: _tokenKey);

    try {
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode >= 500) {
          throw ApiException('Error al cerrar sesión en el servidor.');
        }
      }
    } finally {
      await _storage.delete(key: _tokenKey);
    }
  }

  // COMPROBAR SI HAY TOKEN GUARDADO
  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // PROCESAR RESPUESTAS DE LARAVEL
  static Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    Map<String, dynamic> data;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw const FormatException();
      }

      data = Map<String, dynamic>.from(decoded);
    } on FormatException {
      throw ApiException(
        'Respuesta no válida del servidor '
        '(HTTP ${response.statusCode}).',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    final errors = data['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final firstErrors = errors.values.first;

      if (firstErrors is List && firstErrors.isNotEmpty) {
        throw ApiException(firstErrors.first.toString());
      }
    }

    throw ApiException(
      data['message']?.toString() ??
          'Error del servidor (HTTP ${response.statusCode}).',
    );
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
