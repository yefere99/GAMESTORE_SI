import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'edit_product_view.dart';
import 'package:gamestore_frontend/models/product.dart';


class ManageProductsView extends StatefulWidget {
  const ManageProductsView({super.key});

  @override
  State<ManageProductsView> createState() => _ManageProductsViewState();
}

class _ManageProductsViewState extends State<ManageProductsView> {
  List<dynamic> _products = [];
  String _searchQuery = '';
  String _selectedCategory = 'todos';
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ApiService.fetchProducts();
    setState(() => _products = products);
  }

  List<dynamic> get _filteredAndSorted {
    List<dynamic> list = _products;

    if (_selectedCategory != 'todos') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    list.sort((a, b) {
      if (_sortBy == 'name') return a.name.compareTo(b.name);
      if (_sortBy == 'price') return a.price.compareTo(b.price);
      return 0;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar productos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'consolas', child: Text('Consolas')),
                    DropdownMenuItem(value: 'accesorios', child: Text('Accesorios')),
                    DropdownMenuItem(value: 'videojuegos', child: Text('Videojuegos')),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Nombre')),
                    DropdownMenuItem(value: 'price', child: Text('Precio')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredAndSorted.length,
                itemBuilder: (context, index) {
                  final p = _filteredAndSorted[index];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('\$${p.price} - ${p.category} - ${p.quantity} disponibles'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final productMap = {
                          '_id': p.id,
                          'name': p.name,
                          'description': p.description,
                          'price': p.price,
                          'category': p.category,
                          'quantity': p.quantity,
                          'imageUrl': p.imageUrl,
                        };
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProductView(product: Product.fromJson(productMap)),
                          ),
                        );
                        await _loadProducts();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
