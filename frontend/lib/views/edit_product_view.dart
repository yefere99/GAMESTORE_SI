import 'dart:io' as io show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class EditProductView extends StatefulWidget {
  final Product product;
  const EditProductView({super.key, required this.product});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  XFile? imageFile;

  late String name;
  late String description;
  late String category;
  late double price;
  late int quantity;
  late String imageUrl;

  final List<String> categories = ['consolas', 'videojuegos', 'accesorios'];

  @override
  void initState() {
    super.initState();
    name = widget.product.name;
    description = widget.product.description;
    category = widget.product.category;
    price = widget.product.price;
    quantity = widget.product.quantity;
    imageUrl = widget.product.imageUrl;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = picked);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        String finalImageUrl = imageUrl;
        if (imageFile != null) {
          finalImageUrl = await ApiService.uploadImage(imageFile!);
        }

        final updated = Product(
          id: widget.product.id,
          name: name,
          description: description,
          category: category,
          price: price,
          quantity: quantity,
          imageUrl: finalImageUrl,
        );

        await ApiService.updateProduct(updated.id, updated);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto actualizado correctamente')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar: $e')),
          );
        }
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar producto?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteProduct(widget.product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePreview = imageFile != null
        ? kIsWeb
            ? Image.network(imageFile!.path, height: 120)
            : Image.file(io.File(imageFile!.path), height: 120)
        : Image.network(imageUrl, height: 120);

    return Scaffold(
      appBar: AppBar(title: const Text("Editar producto")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                onChanged: (v) => name = v,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                onChanged: (v) => description = v,
              ),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => category = value!),
                validator: (v) => v == null || v.isEmpty ? 'Selecciona una categoría' : null,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null ? 'Número inválido' : null,
                onChanged: (v) => price = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                initialValue: quantity.toString(),
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null ? 'Cantidad inválida' : null,
                onChanged: (v) => quantity = int.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 12),
              imagePreview,
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _pickImage, child: const Text("Cambiar imagen")),
              ElevatedButton(onPressed: _submit, child: const Text("Guardar cambios")),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Eliminar producto"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
