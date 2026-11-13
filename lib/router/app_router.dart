import 'package:go_router/go_router.dart';

import '../state/session_state.dart';
import '../models/product.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/product_detail_loader.dart';
import '../screens/product_detail_screen.dart';

class AppRouter {
  static late GoRouter router;

  static GoRouter create(SessionState session) => router = GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    redirect: (context, state) {
      final atLogin = state.matchedLocation == '/login';
      if (!session.isLoggedIn) return atLogin ? null : '/login';
      return atLogin ? '/' : null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
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
