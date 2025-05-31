class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int quantity;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.quantity,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    int? quantity,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
