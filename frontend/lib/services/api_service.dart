import 'dart:convert';
import 'dart:io' as io show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import 'package:gamestore_frontend/config/env.dart';

class ApiService {
  static String get baseUrl => '${Env.apiUrl}/api/products';

  /// Obtener todos los productos
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: al obtener productos');
      }
    } catch (e) {
      throw Exception('Excepción al obtener productos: $e');
    }
  }

  /// Obtener categorías desde el backend
  static Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products/categories'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Error ${response.statusCode}: al obtener categorías');
      }
    } catch (e) {
      throw Exception('Excepción al obtener categorías: $e');
    }
  }

  /// Añadir un nuevo producto
  static Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Error al agregar producto');
      }
    } catch (e) {
      throw Exception('Excepción al agregar producto: $e');
    }
  }

  /// Actualizar producto existente
  static Future<void> updateProduct(String id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar producto');
      }
    } catch (e) {
      throw Exception('Excepción al actualizar producto: $e');
    }
  }

  /// Eliminar producto
  static Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar producto');
      }
    } catch (e) {
      throw Exception('Excepción al eliminar producto: $e');
    }
  }

  /// Subir imagen (web y mobile/desktop)
  static Future<String> uploadImage(dynamic file) async {
    try {
      final uri = Uri.parse('${Env.apiUrl}/api/upload');
      final request = http.MultipartRequest('POST', uri);

      if (file is XFile) {
        final bytes = await file.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        );
        request.files.add(multipartFile);
      } else if (file is io.File) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      } else {
        throw Exception('Tipo de archivo no compatible');
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = json.decode(responseBody);
        return decoded['imageUrl'];
      } else {
        throw Exception('Error al subir imagen');
      }
    } catch (e) {
      throw Exception('Excepción al subir imagen: $e');
    }
  }
}
