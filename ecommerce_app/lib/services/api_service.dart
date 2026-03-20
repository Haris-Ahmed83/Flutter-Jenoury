import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/product.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw ApiException('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/products/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      } else {
        throw ApiException(
            'Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/products/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException(
            'Failed to load category products: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
