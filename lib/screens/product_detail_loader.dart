import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../providers/app_providers.dart';
import 'product_detail_screen.dart';

class ProductDetailLoader extends ConsumerStatefulWidget {
  const ProductDetailLoader({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductDetailLoader> createState() => _ProductDetailLoaderState();
}

class _ProductDetailLoaderState extends ConsumerState<ProductDetailLoader> {
  late final Future<Product?> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture =
        ref.read(productsProvider).getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _productFuture,
      builder: (context, snapshot) {
        final product = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            product != null) {
          return ProductDetailScreen(product: product);
        }

        final isLoading = snapshot.connectionState != ConnectionState.done;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
              tooltip: 'Back to products',
            ),
          ),
          body: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.hasError
                            ? 'Could not load this product.'
                            : 'This product is no longer available.',
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Back to store'),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
