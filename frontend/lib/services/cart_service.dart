import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  // 🔒 Lista inmutable para lectura externa
  List<CartItem> get items => List.unmodifiable(_items);

  // 💰 Total en dinero
  double get total => _items.fold(
    0,
    (sum, item) => sum + item.product.price * item.quantity,
  );

  double get totalPrice => total; // Alias

  // 🧮 Total de productos sumados (para ícono de carrito)
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // 🛒 Agregar producto
  void addProduct(Product product) {
    if (product.quantity <= 0) return;

    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (_items[index].quantity < product.quantity) {
        _items[index].quantity++;
        notifyListeners();
      }
    } else {
      _items.add(CartItem(product: product, quantity: 1));
      notifyListeners();
    }
  }

  // ❌ Eliminar producto completamente
  void removeProduct(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  // ➕ Aumentar cantidad (respetando stock)
  void increase(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final cartItem = _items[index];
      if (cartItem.quantity < cartItem.product.quantity) {
        _items[index].quantity++;
        notifyListeners();
      }
    }
  }

  // ➖ Disminuir cantidad o eliminar si llega a 0
  void decrease(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final currentQuantity = _items[index].quantity;
      if (currentQuantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // 🎯 Alias para compatibilidad con vistas antiguas
  void increaseQuantity(Product product) => increase(product);
  void decreaseQuantity(Product product) => decrease(product);

  // 🧼 Vaciar todo el carrito
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // 🐞 (Opcional) Ver carrito en consola para debug
  void debugCart() {
    for (var item in _items) {
      print('${item.product.name} x${item.quantity} → \$${item.product.price * item.quantity}');
    }
    print('Total: \$${total.toStringAsFixed(2)}');
  }
}
