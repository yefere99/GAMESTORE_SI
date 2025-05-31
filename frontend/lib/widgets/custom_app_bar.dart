import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../views/cart_view.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Future<void> Function()? onReload;

  const CustomAppBar({super.key, this.title, this.onReload});

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartService>().itemCount;

    return AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      title: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.greenAccent, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartView()),
              );
            },
          ),
          if (cartCount > 0)
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
                  '$cartCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        if (onReload != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Recargar",
            onPressed: () => onReload!(),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
