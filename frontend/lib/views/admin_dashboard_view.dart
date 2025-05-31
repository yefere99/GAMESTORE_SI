import 'package:flutter/material.dart';
import 'add_product_view.dart';
import 'manage_products_view.dart';
import 'admin_orders_view.dart'; // Asegúrate de tener esta vista importada

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de administrador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductView()),
              ),
              child: const Text("Agregar producto"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageProductsView()),
              ),
              child: const Text("Editar productos"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOrdersView()),
              ),
              child: const Text("Ver órdenes"),
            ),
          ],
        ),
      ),
    );
  }
}
