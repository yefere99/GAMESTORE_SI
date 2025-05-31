import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

Future<bool> showSummaryDialog({
  required BuildContext context,
  required String name,
  required String address,
  required String phone,
  required String email,
  required String paymentMethod,
  required double total,
}) async {
  final cart = Provider.of<CartService>(context, listen: false);

  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Resumen del pedido"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Datos del comprador:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Nombre: $name"),
                Text("Dirección: $address"),
                Text("Teléfono: $phone"),
                Text("Correo: $email"),
                Text("Método de pago: $paymentMethod"),
                const SizedBox(height: 12),

                const Divider(),
                const Text("Productos:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("${item.quantity} x ${item.product.name}")),
                          Text("\$${(item.product.price * item.quantity).toStringAsFixed(0)}"),
                        ],
                      ),
                    )),

                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("\$${total.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Confirmar"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ) ??
      false;
}
