import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_loader.dart';
import '../screens/product_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              final extra = state.extra;
              if (extra is Product && extra.id == productId) {
                return ProductDetailScreen(product: extra);
              }
              return ProductDetailLoader(productId: productId);
            },
          ),
          GoRoute(
            path: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: 'checkout-confirmation',
            redirect: (context, state) {
              final summary = state.extra as Map<String, dynamic>?;
              if (summary == null) {
                return '/';
              }
              final items = summary['items'] as List?;
              if (items == null || items.isEmpty) {
                return '/';
              }
              return null;
            },
            builder: (context, state) {
              final summary = state.extra as Map<String, dynamic>? ?? {};
              return CheckoutConfirmationScreen(summary: summary);
            },
          ),
        ],
      ),
    ],
  );
}
