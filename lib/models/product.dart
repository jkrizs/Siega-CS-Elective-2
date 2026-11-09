import 'package:flutter/material.dart';

class ProductColorOption {
  final String name;
  final Color color;
  final String imageUrl;

  const ProductColorOption({
    required this.name,
    required this.color,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductColorOption &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(name, color, imageUrl);

  factory ProductColorOption.fromMap(Map<String, dynamic> map) {
    final hex = (map['hex'] as String? ?? '9E9E9E').replaceAll('#', '');
    return ProductColorOption(
      name: map['name'] as String,
      color: Color(int.parse('FF$hex', radix: 16)),
      imageUrl: map['image_url'] as String? ?? '',
    );
  }
}

class Product {
  final String id;
  final String title;
  final String category;
  final String size;
  final double price;
  final double rating;
  final String badge;
  final String imageUrl;
  final List<ProductColorOption> colors;
  final String description;

  List<Color> get swatches => colors.map((c) => c.color).toList();

  const Product({
    required this.id,
    required this.title,
    this.category = '',
    required this.size,
    required this.price,
    required this.rating,
    required this.badge,
    required this.imageUrl,
    required this.colors,
    this.description =
        'TempShield™ double-wall vacuum insulation keeps drinks cold up to 24 hours and hot up to 12. Durable pro-grade stainless steel construction ensures pure taste without flavor transfer.',
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final colorRows = (map['product_colors'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort(
        (a, b) => ((a['position'] as num?) ?? 0).compareTo(
          (b['position'] as num?) ?? 0,
        ),
      );
    final description = map['description'] as String?;

    return Product(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String? ?? '',
      size: map['size'] as String? ?? '',
      price: _toDouble(map['price']),
      rating: _toDouble(map['rating']),
      badge: map['badge'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      colors: colorRows.map(ProductColorOption.fromMap).toList(),
      description: description == null || description.isEmpty
          ? 'TempShield™ double-wall vacuum insulation keeps drinks cold up to 24 hours and hot up to 12. Durable pro-grade stainless steel construction ensures pure taste without flavor transfer.'
          : description,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class CartItem {
  final Product product;
  int quantity;
  ProductColorOption selectedColor;
  bool isSelected;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedColor,
    this.isSelected = true,
  });

  double get subtotal => product.price * quantity;
}
