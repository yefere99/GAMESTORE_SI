import 'package:flutter/material.dart';
import 'package:gamestore_frontend/models/product.dart';
import 'package:gamestore_frontend/services/api_service.dart';
import 'package:gamestore_frontend/views/product_detail_view.dart';
import '../widgets/custom_app_bar.dart';


class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  List<Product> _products = [];
  String _searchTerm = '';
  String _selectedCategory = 'todos';

  final List<String> categories = ['todos', 'consolas', 'videojuegos', 'accesorios'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ApiService.fetchProducts();
    setState(() => _products = products);
  }

  List<Product> get _filtered {
    return _products.where((p) {
      final matchesName = p.name.toLowerCase().contains(_searchTerm.toLowerCase());
      final matchesCategory = _selectedCategory == 'todos' || p.category == _selectedCategory;
      return matchesName && matchesCategory;
    }).toList();
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onReload: _loadProducts, title: '',),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => setState(() => _searchTerm = value),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase())))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                  return _filtered.isEmpty
                      ? const Center(child: Text("No hay productos disponibles."))
                      : GridView.builder(
                          itemCount: _filtered.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (_, index) {
                            final product = _filtered[index];
                            bool isHovered = false;

                            return StatefulBuilder(
                              builder: (context, setInnerState) {
                                return MouseRegion(
                                  onEnter: (_) => setInnerState(() => isHovered = true),
                                  onExit: (_) => setInnerState(() => isHovered = false),
                                  child: AnimatedScale(
                                    scale: isHovered ? 1.03 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ProductDetailView(product: product),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 5,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(12)),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Image.network(
                                                  product.imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => const Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    product.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 4, horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.greenAccent.shade700,
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                    child: Text(
                                                      '\$${product.price.toInt()}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text("Ayuda"),
            content: Text("Aquí puedes buscar y filtrar productos disponibles."),
          ),
        ),
        child: const Icon(Icons.help_outline),
      ),
    );
  }
}
