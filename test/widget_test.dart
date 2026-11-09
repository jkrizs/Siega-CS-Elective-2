import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:siega_prelimexam/main.dart';
import 'package:siega_prelimexam/models/product.dart';
import 'package:siega_prelimexam/router/app_router.dart';
import 'package:siega_prelimexam/screens/cart_screen.dart';
import 'package:siega_prelimexam/screens/checkout_confirmation_screen.dart';
import 'package:siega_prelimexam/screens/product_detail_screen.dart';
import 'package:siega_prelimexam/services/product_service.dart';
import 'package:siega_prelimexam/state/cart_state.dart';
import 'package:siega_prelimexam/state/product_provider.dart';
import 'package:siega_prelimexam/widgets/product_card.dart';

class FakeProductService implements ProductService {
  FakeProductService(List<Product> products) : _products = [...products];

  final List<Product> _products;

  @override
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final matches = _products
        .where((p) => category == null || p.category == category)
        .where((p) => minPrice == null || p.price >= minPrice)
        .where((p) => maxPrice == null || p.price <= maxPrice)
        .toList()
      ..sort((a, b) {
        final byPrice = a.price.compareTo(b.price);
        return byPrice != 0 ? byPrice : a.id.compareTo(b.id);
      });
    return ProductPage(
      items: matches.skip(page * pageSize).take(pageSize).toList(),
      totalCount: matches.length,
    );
  }

  @override
  Future<PriceBounds?> fetchPriceBounds() async {
    if (_products.isEmpty) return null;
    final prices = _products.map((p) => p.price).toList()..sort();
    return PriceBounds(prices.first, prices.last);
  }

  @override
  Future<List<String>> fetchCategories() async =>
      _products.map((p) => p.category).toSet().toList()..sort();

  @override
  Future<List<Product>> fetchFeatured({int limit = 3}) async =>
      _products.take(limit).toList();

  @override
  Future<Product?> fetchProductById(String id) async {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  @override
  Future<Product> updateProduct(
    String id, {
    String? title,
    double? price,
  }) async {
    final index = _products.indexWhere((p) => p.id == id);
    final old = _products[index];
    final updated = Product(
      id: old.id,
      title: title ?? old.title,
      category: old.category,
      size: old.size,
      price: price ?? old.price,
      rating: old.rating,
      badge: old.badge,
      imageUrl: old.imageUrl,
      colors: old.colors,
    );
    _products[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
  }
}

Product _product(String id, String title, String category, double price) {
  const image = 'assets/products/standard_white.png';
  return Product(
    id: id,
    title: title,
    category: category,
    size: '24 oz',
    price: price,
    rating: 4.8,
    badge: 'NEW',
    imageUrl: image,
    colors: const [
      ProductColorOption(
        name: 'White',
        color: Color(0xFFF0F0F0),
        imageUrl: image,
      ),
    ],
  );
}

final _sampleProducts = [
  _product('1', 'Standard Mouth', 'Bottles', 24.95),
  _product('2', 'Wide Mouth', 'Bottles', 44.95),
  _product('3', 'Flex Straw Cap', 'Bottles', 39.95),
  _product('4', 'Coffee Flex Sip', 'Coffee', 34.95),
  _product('5', 'All Around Tumbler', 'Tumblers', 32.95),
  _product('6', 'Trail Series Lightweight', 'Bottles', 49.95),
  _product('7', 'Wide Mouth Compact', 'Bottles', 29.95),
  _product('8', 'Coffee Travel Mug', 'Coffee', 27.95),
];

Finder _inGrid(String title) => find.descendant(
      of: find.byType(ProductCard),
      matching: find.text(title),
    );

Future<ProductProvider> _pumpStore(WidgetTester tester) async {
  final provider = ProductProvider(
    service: FakeProductService(_sampleProducts),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider..initialize(),
      child: const HydroFlaskStoreApp(),
    ),
  );
  AppRouter.router.go('/');
  await tester.pumpAndSettle();
  return provider;
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
}

void main() {
  setUp(() {
    cartState.clearCart();
  });

  testWidgets(
    'Storefront renders properly, toggles theme, and navigates via go_router',
    (WidgetTester tester) async {
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception is NetworkImageLoadException) {
          return;
        }
        previousOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousOnError);

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpStore(tester);

      expect(find.text('Hydro Flask'), findsWidgets);
      expect(
        find.text('Free Shipping'),
        findsOneWidget,
      );

      final themeToggle = find.byTooltip('Toggle Theme');
      expect(themeToggle, findsOneWidget);
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();

      final standardMouthCard = find.byType(ProductCard).first;
      expect(
        find.descendant(
          of: standardMouthCard,
          matching: find.text('Standard Mouth'),
        ),
        findsOneWidget,
      );

      await _tapVisible(tester, standardMouthCard);

      expect(find.byType(ProductDetailScreen), findsOneWidget);
      expect(find.text('Standard Mouth'), findsWidgets);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailScreen), findsNothing);
      expect(find.text('Explore Collection'), findsOneWidget);
    },
  );

  testWidgets(
    'Full User Flow: Home -> Product Detail -> Add to Cart -> Cart -> Checkout Confirmation',
    (WidgetTester tester) async {
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception is NetworkImageLoadException) {
          return;
        }
        previousOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousOnError);

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _pumpStore(tester);

      final firstProduct = find.byType(ProductCard).first;
      await _tapVisible(tester, firstProduct);

      expect(find.byType(ProductDetailScreen), findsOneWidget);

      final addToCartButton = find.widgetWithText(ElevatedButton, 'ADD TO CART');
      expect(addToCartButton, findsOneWidget);
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      expect(cartState.totalItemCount, 1);

      final cartIcon = find.byTooltip('View Cart');
      expect(cartIcon, findsOneWidget);
      await tester.tap(cartIcon);
      await tester.pumpAndSettle();

      expect(find.byType(CartScreen), findsOneWidget);
      expect(find.text('Your Cart'), findsOneWidget);
      expect(find.text('Total Amount:'), findsOneWidget);

      final plusButton = find.byIcon(Icons.add);
      expect(plusButton, findsOneWidget);
      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      expect(cartState.totalItemCount, 2);
      expect(find.text('2'), findsOneWidget);

      final checkoutButton =
          find.widgetWithText(ElevatedButton, 'PROCEED TO CHECKOUT (2)');
      expect(checkoutButton, findsOneWidget);
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      expect(find.byType(CheckoutConfirmationScreen), findsOneWidget);
      expect(find.text('Thank you for your order!'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('BACK TO STORE'), findsOneWidget);

      await tester.tap(find.text('BACK TO STORE'));
      await tester.pumpAndSettle();

      expect(find.text('Hydro Flask'), findsWidgets);
    },
  );

  group('Supabase products: pagination and filters', () {
    testWidgets('first page shows the 6 cheapest products', (tester) async {
      _useTallScreen(tester);
      await _pumpStore(tester);

      expect(find.byType(ProductCard), findsNWidgets(6));
      expect(find.text('Showing 1–6 of 8 products'), findsOneWidget);
      expect(find.text('Page 1 of 2'), findsOneWidget);
      expect(_inGrid('Standard Mouth'), findsOneWidget);
      expect(_inGrid('Trail Series Lightweight'), findsNothing);
    });

    testWidgets('next page loads the remaining products', (tester) async {
      _useTallScreen(tester);
      await _pumpStore(tester);

      await _tapVisible(tester, find.byTooltip('Next page'));

      expect(find.text('Page 2 of 2'), findsOneWidget);
      expect(find.byType(ProductCard), findsNWidgets(2));
      expect(_inGrid('Trail Series Lightweight'), findsOneWidget);
      expect(_inGrid('Standard Mouth'), findsNothing);

      await _tapVisible(tester, find.byTooltip('Previous page'));
      expect(find.text('Page 1 of 2'), findsOneWidget);
    });

    testWidgets('category chips filter the products', (tester) async {
      _useTallScreen(tester);
      await _pumpStore(tester);

      await _tapVisible(tester, find.widgetWithText(FilterChip, 'Coffee'));

      expect(find.byType(ProductCard), findsNWidgets(2));
      expect(_inGrid('Coffee Flex Sip'), findsOneWidget);
      expect(_inGrid('Standard Mouth'), findsNothing);
      expect(find.text('Page 1 of 1'), findsOneWidget);
    });

    testWidgets('price range limits the products shown', (tester) async {
      _useTallScreen(tester);
      final provider = await _pumpStore(tester);

      expect(find.byType(RangeSlider), findsOneWidget);
      provider.updatePriceRange(const RangeValues(30, 40));
      provider.applyPriceRange();
      await tester.pumpAndSettle();

      expect(find.text('Showing 1–3 of 3 products'), findsOneWidget);
      expect(_inGrid('All Around Tumbler'), findsOneWidget);
      expect(_inGrid('Standard Mouth'), findsNothing);

      await _tapVisible(tester, find.widgetWithText(TextButton, 'Reset'));
      expect(find.text('Showing 1–6 of 8 products'), findsOneWidget);
    });

    test('price and category filters combine', () async {
      final provider = ProductProvider(
        service: FakeProductService(_sampleProducts),
      );
      await provider.initialize();

      provider.selectCategory('Bottles');
      provider.updatePriceRange(const RangeValues(25, 45));
      provider.applyPriceRange();
      await Future<void>.delayed(Duration.zero);

      expect(provider.products.map((p) => p.id), ['7', '3', '2']);
    });

    test('deleting the last product on a page steps back a page', () async {
      final provider = ProductProvider(
        service: FakeProductService(_sampleProducts.take(7).toList()),
      );
      await provider.initialize();
      provider.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentPage, 1);

      await provider.deleteProduct(provider.products.single.id);

      expect(provider.currentPage, 0);
      expect(provider.totalCount, 6);
    });

    test('updating a price re-sorts the page', () async {
      final provider = ProductProvider(
        service: FakeProductService(_sampleProducts),
      );
      await provider.initialize();

      await provider.updateProduct('6', price: 19.95);

      expect(provider.products.first.id, '6');
      expect(provider.priceBounds!.min, 19);
    });
  });
}
