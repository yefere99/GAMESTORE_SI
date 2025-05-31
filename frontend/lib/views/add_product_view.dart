import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
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
  final TextEditingController categoryController = TextEditingController();

  List<String> categories = [];
  Uint8List? imageBytes;
  String? imageName;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/products/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = data.map((e) => e['name'].toString()).toList();
        });
      } else {
        print('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al conectar: $e');
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        imageBytes = result.files.first.bytes!;
        imageName = result.files.first.name;
      });
    }
  }

  Future<void> submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una imagen.')),
      );
      return;
    }

    final uploadRequest = http.MultipartRequest('POST', Uri.parse('$apiUrl/upload'));
    uploadRequest.files.add(http.MultipartFile.fromBytes('image', imageBytes!, filename: imageName));
    final uploadResponse = await uploadRequest.send();

    if (uploadResponse.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir imagen')),
      );
      return;
    }

    final imageResponse = await uploadResponse.stream.bytesToString();
    final imageUrl = jsonDecode(imageResponse)['imageUrl'];

    final product = {
      'name': nameController.text,
      'description': descriptionController.text,
      'price': double.tryParse(priceController.text) ?? 0,
      'imageUrl': imageUrl,
      'category': categoryController.text,
    };

    final response = await http.post(
      Uri.parse('$apiUrl/products'),
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
              const SizedBox(height: 16),
              Text(imageName ?? 'No se ha seleccionado imagen'),
              TextButton(
                onPressed: pickImage,
                child: Text('Seleccionar imagen'),
              ),
              const SizedBox(height: 16),
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
