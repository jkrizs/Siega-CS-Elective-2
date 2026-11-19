import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show supabase;
import '../models/category.dart';
import '../models/product.dart';

class ProductPage {
  const ProductPage({required this.items, required this.totalCount});

  final List<Product> items;
  final int totalCount;
}

class PriceBounds {
  const PriceBounds(this.min, this.max);

  final double min;
  final double max;
}

abstract class ProductService {
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    int? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
  });

  Future<PriceBounds?> fetchPriceBounds();

  Future<List<Category>> fetchCategories();

  Future<List<Product>> fetchFeatured({int limit = 3});

  Future<Product?> fetchProductById(int id);

  Future<Product> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    required String imageUrl,
    List<Map<String, dynamic>> colors = const [],
  });

  Future<Product> updateProduct(
    int id, {
    String? name,
    String? description,
    double? price,
    int? stock,
    int? categoryId,
    String? imageUrl,
    List<Map<String, dynamic>>? colors,
  });

  Future<void> deleteProduct(int id);

  Future<Category> addCategory(String name);

  Future<Category> updateCategory(int id, String name);

  Future<void> deleteCategory(int id);

  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  });
}

class SupabaseProductService implements ProductService {
  static const _table = 'products';
  static const _withCategory = '*, categories(name)';

  @override
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    int? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase.from(_table).select(_withCategory);

    if (categoryId != null && categoryId > 0) {
      query = query.eq('category_id', categoryId);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }
    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }
    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    final response = await query
        .order('price', ascending: true)
        .order('id', ascending: true)
        .range(from, to)
        .count(CountOption.exact);

    return ProductPage(
      items: (response.data as List<dynamic>).map((e) => Product.fromMap(e as Map<String, dynamic>)).toList(),
      totalCount: response.count,
    );
  }

  @override
  Future<PriceBounds?> fetchPriceBounds() async {
    final cheapest = await supabase
        .from(_table)
        .select('price')
        .order('price', ascending: true)
        .limit(1)
        .maybeSingle();

    final priciest = await supabase
        .from(_table)
        .select('price')
        .order('price', ascending: false)
        .limit(1)
        .maybeSingle();

    if (cheapest == null || priciest == null) return null;
    return PriceBounds(
      (cheapest['price'] as num).toDouble(),
      (priciest['price'] as num).toDouble(),
    );
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final rows = await supabase
        .from('categories')
        .select('*')
        .order('name', ascending: true);
    return (rows as List<dynamic>)
        .map((r) => Category.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Product>> fetchFeatured({int limit = 3}) async {
    final rows = await supabase
        .from(_table)
        .select(_withCategory)
        .order('id', ascending: true)
        .limit(limit);
    return (rows as List<dynamic>)
        .map((r) => Product.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product?> fetchProductById(int id) async {
    final row = await supabase
        .from(_table)
        .select(_withCategory)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Product.fromMap(row);
  }

  @override
  Future<Product> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    required String imageUrl,
    List<Map<String, dynamic>> colors = const [],
  }) async {
    final row = await supabase
        .from(_table)
        .insert({
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
          'image_url': imageUrl,
          'colors': colors,
        })
        .select(_withCategory)
        .single();
    return Product.fromMap(row);
  }

  @override
  Future<Product> updateProduct(
    int id, {
    String? name,
    String? description,
    double? price,
    int? stock,
    int? categoryId,
    String? imageUrl,
    List<Map<String, dynamic>>? colors,
  }) async {
    final changes = <String, dynamic>{
      'name': ?name,
      'description': ?description,
      'price': ?price,
      'stock': ?stock,
      'category_id': ?categoryId,
      'image_url': ?imageUrl,
      'colors': ?colors,
    };

    final row = await supabase
        .from(_table)
        .update(changes)
        .eq('id', id)
        .select(_withCategory)
        .single();
    return Product.fromMap(row);
  }

  @override
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final safeName =
        fileName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '_');
    final path = 'products/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    await supabase.storage.from('product-images').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return supabase.storage.from('product-images').getPublicUrl(path);
  }

  @override
  Future<void> deleteProduct(int id) async {
    final deleted = await supabase.from(_table).delete().eq('id', id).select();
    if (deleted.isEmpty) {
      throw const PostgrestException(
        message: 'Nothing was deleted. Check the DELETE policy on the products table.',
        code: '42501',
      );
    }
  }

  @override
  Future<Category> addCategory(String name) async {
    final row = await supabase
        .from('categories')
        .insert({'name': name})
        .select()
        .single();
    return Category.fromMap(row);
  }

  @override
  Future<Category> updateCategory(int id, String name) async {
    final row = await supabase
        .from('categories')
        .update({'name': name})
        .eq('id', id)
        .select()
        .single();
    return Category.fromMap(row);
  }

  @override
  Future<void> deleteCategory(int id) async {
    final deleted =
        await supabase.from('categories').delete().eq('id', id).select();
    if (deleted.isEmpty) {
      throw const PostgrestException(
        message: 'Nothing was deleted. Check the DELETE policy on the categories table.',
        code: '42501',
      );
    }
  }
}
