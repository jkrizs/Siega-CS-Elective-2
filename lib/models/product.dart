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
}

class Product {
  final String id;
  final String title;
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
    required this.size,
    required this.price,
    required this.rating,
    required this.badge,
    required this.imageUrl,
    required this.colors,
    this.description =
        'TempShield™ double-wall vacuum insulation keeps drinks cold up to 24 hours and hot up to 12. Durable pro-grade stainless steel construction ensures pure taste without flavor transfer.',
  });
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

final List<Product> mockProducts = [
  const Product(
    id: '1',
    title: 'Standard Mouth',
    size: '21 oz',
    price: 34.95,
    rating: 4.8,
    badge: 'NEW',
    imageUrl: 'assets/products/standard_carnation.png',
    colors: [
      ProductColorOption(
        name: 'Carnation',
        color: Color(0xFFDFACB4),
        imageUrl: 'assets/products/standard_carnation.png',
      ),
      ProductColorOption(
        name: 'Indigo',
        color: Color(0xFF1E365D),
        imageUrl: 'assets/products/standard_indigo.png',
      ),
      ProductColorOption(
        name: 'White',
        color: Color(0xFFF0F0F0),
        imageUrl: 'assets/products/standard_white.png',
      ),
    ],
    description:
        'The ideal companion for everyday hydration. Standard mouth opening fits most backcountry water filters and fits easily in standard car cup holders.',
  ),
  const Product(
    id: '2',
    title: 'Wide Mouth',
    size: '32 oz',
    price: 44.95,
    rating: 4.9,
    badge: 'BEST SELLER',
    imageUrl: 'assets/products/wide_indigo.png',
    colors: [
      ProductColorOption(
        name: 'Indigo',
        color: Color(0xFF1E365D),
        imageUrl: 'assets/products/wide_indigo.png',
      ),
      ProductColorOption(
        name: 'Black',
        color: Color(0xFF222222),
        imageUrl: 'assets/products/wide_black.png',
      ),
      ProductColorOption(
        name: 'Clementine',
        color: Color(0xFFF0753F),
        imageUrl: 'assets/products/wide_clementine.png',
      ),
    ],
    description:
        'Our largest everyday hydration bottle. Wide mouth opening allows quick filling, ice insertion, and easy cleaning.',
  ),
  const Product(
    id: '3',
    title: 'Flex Straw Cap',
    size: '24 oz',
    price: 39.95,
    rating: 4.7,
    badge: 'LEAKPROOF',
    imageUrl: 'assets/products/straw_pink.png',
    colors: [
      ProductColorOption(
        name: 'Carnation',
        color: Color(0xFFDFACB4),
        imageUrl: 'assets/products/straw_pink.png',
      ),
      ProductColorOption(
        name: 'Spearmint',
        color: Color(0xFF74C2A8),
        imageUrl: 'assets/products/straw_spearmint.png',
      ),
      ProductColorOption(
        name: 'Snapper',
        color: Color(0xFF8B2B43),
        imageUrl: 'assets/products/straw_snapper.png',
      ),
    ],
    description:
        'Sip anywhere with leakproof straw cap design. Keeps drinks icy cold with double-wall insulation while offering effortless hydration on the go.',
  ),
  const Product(
    id: '4',
    title: 'Coffee Flex Sip',
    size: '20 oz',
    price: 34.95,
    rating: 4.6,
    badge: 'HOT + COLD',
    imageUrl: 'assets/products/coffee_olive.png',
    colors: [
      ProductColorOption(
        name: 'Olive',
        color: Color(0xFF76834F),
        imageUrl: 'assets/products/coffee_olive.png',
      ),
      ProductColorOption(
        name: 'Snapper',
        color: Color(0xFF813647),
        imageUrl: 'assets/products/coffee_snapper.png',
      ),
    ],
    description:
        'Engineered for hot beverages. Fits under most coffee brewing systems and ensures leakproof travel so you can sip your favorite brew with confidence.',
  ),
  const Product(
    id: '5',
    title: 'All Around Tumbler',
    size: '28 oz',
    price: 32.95,
    rating: 4.8,
    badge: 'POPULAR',
    imageUrl: 'assets/products/tumbler_pacific.png',
    colors: [
      ProductColorOption(
        name: 'Pacific Blue',
        color: Color(0xFF4C6988),
        imageUrl: 'assets/products/tumbler_pacific.png',
      ),
      ProductColorOption(
        name: 'Lupine',
        color: Color(0xFF745DB0),
        imageUrl: 'assets/products/tumbler_lupine.png',
      ),
      ProductColorOption(
        name: 'Olive',
        color: Color(0xFF748147),
        imageUrl: 'assets/products/tumbler_olive.png',
      ),
    ],
    description:
        'From morning smoothie to evening mocktail, this tumbler keeps temperatures locked in for hours with splash-resistant press-in lid.',
  ),
  const Product(
    id: '6',
    title: 'Trail Series Lightweight',
    size: '32 oz',
    price: 49.95,
    rating: 4.9,
    badge: 'LIGHTWEIGHT',
    imageUrl: 'assets/products/trail_obsidian.jpg',
    colors: [
      ProductColorOption(
        name: 'Obsidian',
        color: Color(0xFF5A4C40),
        imageUrl: 'assets/products/trail_obsidian.jpg',
      ),
      ProductColorOption(
        name: 'Cobalt',
        color: Color(0xFF334CB8),
        imageUrl: 'assets/products/trail_cobalt.jpg',
      ),
    ],
    description:
        '25% lighter than standard 32 oz bottles. Engineered for backcountry hikers and backpackers seeking ultralight hydration without sacrificing durability.',
  ),
];
