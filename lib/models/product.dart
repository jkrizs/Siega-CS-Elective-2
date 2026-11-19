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

  factory ProductColorOption.fromMap(Map<String, dynamic> map) {
    final hex = (map['hex'] as String? ?? '9E9E9E').replaceAll('#', '');
    return ProductColorOption(
      name: map['name'] as String? ?? 'Color',
      color: Color(int.parse('FF$hex', radix: 16)),
      imageUrl: map['image_url'] as String? ?? '',
    );
  }

  String get hex => (color.toARGB32() & 0xFFFFFF)
      .toRadixString(16)
      .padLeft(6, '0')
      .toUpperCase();

  Map<String, dynamic> toJson() => {'name': name, 'hex': hex};

  static const List<ProductColorOption> palette = [
    ProductColorOption(name: 'Black', color: Color(0xFF222222), imageUrl: ''),
    ProductColorOption(name: 'White', color: Color(0xFFF0F0F0), imageUrl: ''),
    ProductColorOption(name: 'Indigo', color: Color(0xFF1E365D), imageUrl: ''),
    ProductColorOption(name: 'Pacific Blue', color: Color(0xFF4C6988), imageUrl: ''),
    ProductColorOption(name: 'Cobalt', color: Color(0xFF334CB8), imageUrl: ''),
    ProductColorOption(name: 'Lupine', color: Color(0xFF745DB0), imageUrl: ''),
    ProductColorOption(name: 'Spearmint', color: Color(0xFF74C2A8), imageUrl: ''),
    ProductColorOption(name: 'Olive', color: Color(0xFF76834F), imageUrl: ''),
    ProductColorOption(name: 'Carnation', color: Color(0xFFDFACB4), imageUrl: ''),
    ProductColorOption(name: 'Clementine', color: Color(0xFFF0753F), imageUrl: ''),
    ProductColorOption(name: 'Snapper', color: Color(0xFF8B2B43), imageUrl: ''),
    ProductColorOption(name: 'Obsidian', color: Color(0xFF5A4C40), imageUrl: ''),
  ];
}

class Product {
  final int id;
  final String name;
  final String description;
  final int stock;
  final String imageUrl;
  final int? categoryId;
  final String? categoryName;
  final double price;
  final DateTime? createdAt;
  final List<ProductColorOption> colors;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.stock,
    required this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.price,
    this.createdAt,
    this.colors = const [],
  });

  List<Color> get swatches => colors.map((c) => c.color).toList();
  bool get isOutOfStock => stock <= 0;

  Product copyWith({
    int? id,
    String? name,
    String? description,
    int? stock,
    String? imageUrl,
    int? categoryId,
    String? categoryName,
    double? price,
    DateTime? createdAt,
    List<ProductColorOption> ? colors,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      colors: colors ?? this.colors,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    String? catName;
    if (map['categories'] != null && map['categories'] is Map) {
      catName = map['categories']['name'] as String?;
    } else if (map['category_name'] != null) {
      catName = map['category_name'] as String?;
    }

    final name = map['name'] as String? ?? 'Unnamed Product';
    final imageUrl = map['image_url'] as String? ?? '';

    List<ProductColorOption> colors = [];
    if (map['product_colors'] != null && map['product_colors'] is List) {
      colors = (map['product_colors'] as List)
          .map((c) => ProductColorOption.fromMap(c as Map<String, dynamic>))
          .toList();
    }
    final defaults = _defaultColorsFor(name, imageUrl);
    if (colors.isEmpty && map['colors'] is List) {
      colors = (map['colors'] as List).whereType<Map>().map((raw) {
        final option = ProductColorOption.fromMap(Map<String, dynamic>.from(raw));
        if (option.imageUrl.isNotEmpty) return option;
        final match = defaults.where(
          (d) => d.name.toLowerCase() == option.name.toLowerCase(),
        );
        return ProductColorOption(
          name: option.name,
          color: option.color,
          imageUrl: match.isNotEmpty ? match.first.imageUrl : imageUrl,
        );
      }).toList();
    }
    if (colors.isEmpty) {
      colors = defaults;
    }

    return Product(
      id: (map['id'] as num).toInt(),
      name: name,
      description: map['description'] as String? ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      imageUrl: imageUrl,
      categoryId: (map['category_id'] as num?)?.toInt(),
      categoryName: catName,
      price: _toDouble(map['price']),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      colors: colors,
    );
  }

  static List<ProductColorOption> _defaultColorsFor(String name, String baseImage) {
    if (baseImage.startsWith('http')) {
      return [
        ProductColorOption(name: 'Default', color: const Color(0xFF4C6988), imageUrl: baseImage),
      ];
    }
    final lower = name.toLowerCase();
    if (lower.contains('standard')) {
      return const [
        ProductColorOption(name: 'Carnation', color: Color(0xFFDFACB4), imageUrl: 'assets/products/standard_carnation.png'),
        ProductColorOption(name: 'Indigo', color: Color(0xFF1E365D), imageUrl: 'assets/products/standard_indigo.png'),
        ProductColorOption(name: 'White', color: Color(0xFFF0F0F0), imageUrl: 'assets/products/standard_white.png'),
      ];
    } else if (lower.contains('wide')) {
      return const [
        ProductColorOption(name: 'Indigo', color: Color(0xFF1E365D), imageUrl: 'assets/products/wide_indigo.png'),
        ProductColorOption(name: 'Black', color: Color(0xFF222222), imageUrl: 'assets/products/wide_black.png'),
        ProductColorOption(name: 'Clementine', color: Color(0xFFF0753F), imageUrl: 'assets/products/wide_clementine.png'),
      ];
    } else if (lower.contains('straw')) {
      return const [
        ProductColorOption(name: 'Carnation', color: Color(0xFFDFACB4), imageUrl: 'assets/products/straw_pink.png'),
        ProductColorOption(name: 'Spearmint', color: Color(0xFF74C2A8), imageUrl: 'assets/products/straw_spearmint.png'),
        ProductColorOption(name: 'Snapper', color: Color(0xFF8B2B43), imageUrl: 'assets/products/straw_snapper.png'),
      ];
    } else if (lower.contains('coffee')) {
      return const [
        ProductColorOption(name: 'Olive', color: Color(0xFF76834F), imageUrl: 'assets/products/coffee_olive.png'),
        ProductColorOption(name: 'Snapper', color: Color(0xFF813647), imageUrl: 'assets/products/coffee_snapper.png'),
      ];
    } else if (lower.contains('tumbler')) {
      return const [
        ProductColorOption(name: 'Pacific Blue', color: Color(0xFF4C6988), imageUrl: 'assets/products/tumbler_pacific.png'),
        ProductColorOption(name: 'Lupine', color: Color(0xFF745DB0), imageUrl: 'assets/products/tumbler_lupine.png'),
        ProductColorOption(name: 'Olive', color: Color(0xFF748147), imageUrl: 'assets/products/tumbler_olive.png'),
      ];
    } else if (lower.contains('trail')) {
      return const [
        ProductColorOption(name: 'Obsidian', color: Color(0xFF5A4C40), imageUrl: 'assets/products/trail_obsidian.jpg'),
        ProductColorOption(name: 'Cobalt', color: Color(0xFF334CB8), imageUrl: 'assets/products/trail_cobalt.jpg'),
      ];
    }

    return [
      ProductColorOption(name: 'Default', color: const Color(0xFF4C6988), imageUrl: baseImage),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'stock': stock,
      'image_url': imageUrl,
      'category_id': categoryId,
      'price': price,
    };
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class CartItem {
  final Product product;
  int quantity;
  bool isSelected;
  ProductColorOption? selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
    this.selectedColor,
  });

  double get subtotal => product.price * quantity;
}
