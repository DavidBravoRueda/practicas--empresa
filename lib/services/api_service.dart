
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://practicas2026.logicsistemas.es';

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'sanctum_token';

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products?per_page=100'),
      headers: {'Accept': 'application/json'},
    );

    final data = _decodeResponse(response);
    final products = data['data'];

    if (products is! List) {
      throw ApiException('La API no ha devuelto una lista de productos válida.');
    }

    return products
        .whereType<Map>()
        .map((product) => Map<String, dynamic>.from(product))
        .where((product) => product['is_active'] != false)
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getBrands() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/brands?per_page=100'),
      headers: {'Accept': 'application/json'},
    );

    final data = _decodeResponse(response);
    final brands = data['data'];

    if (brands is! List) {
      throw ApiException('La API no ha devuelto una lista de marcas válida.');
    }

    return brands
        .whereType<Map>()
        .map((brand) => Map<String, dynamic>.from(brand))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories?per_page=100'),
      headers: {'Accept': 'application/json'},
    );

    final data = _decodeResponse(response);
    final categories = data['data'];

    if (categories is! List) {
      throw ApiException('La API no ha devuelto una lista de categorías válida.');
    }

    return categories
        .whereType<Map>()
        .map((category) => Map<String, dynamic>.from(category))
        .toList();
  }

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

    if (data['user'] is! Map) {
      throw ApiException('La API no ha devuelto los datos del usuario.');
    }

    return Map<String, dynamic>.from(data['user'] as Map);
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
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

    if (data['user'] is! Map) {
      throw ApiException('La API no ha devuelto los datos del usuario.');
    }

    return Map<String, dynamic>.from(data['user'] as Map);
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/user'),
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
    final user = data['user'] ?? data;

    if (user is! Map) {
      throw ApiException('La API no ha devuelto los datos del usuario.');
    }

    return Map<String, dynamic>.from(user);
  }

  static Future<Map<String, dynamic>> updateCurrentUser({
    required String name,
    required String address,
    required String city,
    required String postalCode,
    required String country,
    required String phone,
  }) async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      throw ApiException('Tu sesión ha caducado. Inicia sesión de nuevo.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/user'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name.trim(),
        'address': address.trim(),
        'city': city.trim(),
        'postal_code': postalCode.trim(),
        'country': country.trim(),
        'phone': phone.trim(),
      }),
    );

    final data = _decodeResponse(response);
    final user = data['user'];

    if (user is! Map) {
      throw ApiException('La API no ha devuelto el perfil actualizado.');
    }

    return Map<String, dynamic>.from(user);
  }

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

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // CREAR PEDIDO

  static Future<Map<String, dynamic>> createOrder({
    required String shippingName,
    required String shippingAddress,
    required String shippingCity,
    required String shippingPostalCode,
    required String shippingCountry,
    String? shippingPhone,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      throw ApiException('Tu sesión ha caducado. Inicia sesión de nuevo.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'shipping_name': shippingName.trim(),
        'shipping_address': shippingAddress.trim(),
        'shipping_city': shippingCity.trim(),
        'shipping_postal_code': shippingPostalCode.trim(),
        'shipping_country': shippingCountry.trim(),
        'shipping_phone': shippingPhone == null ||
                shippingPhone.trim().isEmpty
            ? null
            : shippingPhone.trim(),
        'items': items,
      }),
    );

    final data = _decodeResponse(response);
    final order = data['data'];

    if (order is! Map) {
      throw ApiException(
        'El servidor no ha devuelto los datos del pedido.',
      );
    }

    return Map<String, dynamic>.from(order);
  }

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
        'Respuesta no válida del servidor (HTTP ${response.statusCode}).',
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
