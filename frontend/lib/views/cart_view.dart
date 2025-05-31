import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito"),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              tooltip: "Vaciar carrito",
              onPressed: () => cart.clear(),
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text("Tu carrito está vacío."))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Image.network(
                            item.product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.product.name),
                          subtitle: Text(
                            "\$${item.product.price.toInt()} x ${item.quantity} = \$${(item.product.price * item.quantity).toInt()}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => cart.decreaseQuantity(item.product),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => cart.increaseQuantity(item.product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => cart.removeProduct(item.product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "\$${cart.totalPrice.toInt()}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.payment),
                          label: const Text("Finalizar compra"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CheckoutView()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
