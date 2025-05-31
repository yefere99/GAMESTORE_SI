import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class AddProductView extends StatefulWidget {
  @override
  _AddProductViewState createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final response = await http.get(Uri.parse('${apiUrl}/products/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = List<String>.from(data);
        });
      } else {
        print('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al conectar: $e');
    }
  }

  Future<void> submitProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = {
        'name': nameController.text,
        'description': descriptionController.text,
        'price': double.tryParse(priceController.text) ?? 0,
        'imageUrl': imageUrlController.text,
        'category': categoryController.text,
      };

      final response = await http.post(
        Uri.parse('${apiUrl}/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto agregado exitosamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar producto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa un nombre' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa una descripción' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Ingresa un precio' : null,
              ),
              TextFormField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'URL de la imagen'),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa una URL' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Categoría'),
                value: categoryController.text.isNotEmpty ? categoryController.text : null,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  categoryController.text = value!;
                },
                validator: (value) => value == null || value.isEmpty ? 'Selecciona una categoría' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitProduct,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
