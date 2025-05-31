import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import 'package:gamestore_frontend/config/env.dart';

class OrderService {
  static String get _baseUrl => '${Env.apiUrl}/api/orders';

  static Future<String> submitOrder({
    required BuildContext context,
    required String name,
    required String address,
    required String phone,
    required String email,
    required String paymentMethod,
  }) async {
    final cart = Provider.of<CartService>(context, listen: false);

    if (cart.items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    final items = cart.items.map((item) => {
      "productId": item.product.id,
      "name": item.product.name,
      "quantity": item.quantity,
      "price": item.product.price,
    }).toList();

    final total = cart.totalPrice;

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "items": items,
          "total": total,
          "name": name,
          "address": address,
          "phone": phone,
          "email": email,
          "paymentMethod": paymentMethod,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final orderId = data['orderId'];
        if (orderId == null || orderId.isEmpty) {
          throw Exception('Respuesta sin orderId del servidor');
        }
        debugPrint('✅ Orden registrada: $orderId');
        return orderId;
      } else {
        debugPrint('❌ Error al registrar orden');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
        throw Exception('Error del servidor al registrar la orden');
      }
    } catch (e) {
      debugPrint('❗ Error inesperado: $e');
      rethrow;
    }
  }
}
