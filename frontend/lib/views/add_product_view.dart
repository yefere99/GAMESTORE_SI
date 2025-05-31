import 'dart:html' as html show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gamestore_frontend/services/api_service.dart';
import 'package:gamestore_frontend/models/product.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  XFile? imageFile;

  List<String> categories = [];
  bool isLoadingCategories = true;

  String name = '';
  String description = '';
  String category = '';
  double price = 0;
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ApiService.fetchCategories();
      setState(() {
        categories = result;
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => isLoadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar categorías: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || imageFile == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos e incluye una imagen')),
      );
      return;
    }

    try {
      final imageUrl = await ApiService.uploadImage(imageFile!);

      final product = Product(
        id: '',
        name: name,
        description: description,
        category: category,
        price: price,
        quantity: quantity,
        imageUrl: imageUrl,
      );

      await ApiService.addProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto añadido exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = imageFile != null
        ? kIsWeb
            ? Image.network(imageFile!.path, height: 150)
            : Image.network(imageFile!.path, height: 150)
        : const Text('No se ha seleccionado imagen');

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                onChanged: (v) => name = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                onChanged: (v) => description = v,
              ),
              isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      value: category.isNotEmpty ? category : null,
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) => setState(() => category = value ?? ''),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Selecciona una categoría' : null,
                    ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || double.tryParse(v) == null ? 'Número inválido' : null,
                onChanged: (v) => price = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || int.tryParse(v) == null ? 'Número entero requerido' : null,
                onChanged: (v) => quantity = int.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 10),
              imageWidget,
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar imagen'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
