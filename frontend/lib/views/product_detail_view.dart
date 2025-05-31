import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';

class ProductDetailView extends StatelessWidget {
  final Product product;

  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // ✅ carrito en el centro
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return FutureBuilder<List<Product>>(
            future: ApiService.fetchProducts(),
            builder: (context, snapshot) {
              final recommendations = (snapshot.data ?? [])
                  .where((p) => p.category == product.category && p.id != product.id)
                  .toList()
                ..shuffle();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildImage(product),
                          const SizedBox(height: 20),
                          _buildDetails(context),
                          const SizedBox(height: 30),
                          _buildRecommendations(context, recommendations),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildImage(product),
                                const SizedBox(height: 20),
                                _buildDetails(context),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 1,
                            child: _buildRecommendations(context, recommendations),
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImage(Product product) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          product.imageUrl,
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          product.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category),
            const SizedBox(width: 6),
            Text('Categoría: ${product.category}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2),
            const SizedBox(width: 6),
            Text('Cantidad disponible: ${product.quantity}'),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.greenAccent.shade700,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '\$${product.price.toInt()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: product.quantity > 0
              ? () {
                  final cart = context.read<CartService>(); // ✅ USO CORRECTO
                  cart.addProduct(product);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} añadido al carrito'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.add_shopping_cart),
          label: Text(product.quantity > 0 ? 'Añadir al carrito' : 'Agotado'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                product.quantity > 0 ? Colors.deepPurple : Colors.grey.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, List<Product> items) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productos recomendados',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Column(
          children: items.take(3).map((p) => _buildCard(context, p)).toList(),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Product p) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailView(product: p)),
          );
        },
        leading: Image.network(p.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
        title: Text(p.name),
        subtitle: Text('\$${p.price.toInt()}'),
      ),
    );
  }
}
