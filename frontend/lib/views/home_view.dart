import 'package:flutter/material.dart';
import 'package:gamestore_frontend/views/product_list_view.dart';
import 'package:gamestore_frontend/views/admin_login_view.dart';
import 'package:gamestore_frontend/views/cart_view.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<CartService>().items.length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.greenAccent, size: 32),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartView()),
                );
              },
            ),
            if (cartItemCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$cartItemCount',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductListView()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/cover.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLoginView()),
                );
              },
              child: const Text("Administrador"),
            ),
          )
        ],
      ),
    );
  }
}
