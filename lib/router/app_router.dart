import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_orders_screen.dart';
import '../screens/admin/product_form_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/product_detail_loader.dart';
import '../screens/product_detail_screen.dart';
import '../state/session_state.dart';

class AppRouter {
  static late GoRouter router;

  static GoRouter create(SessionState session) => router = GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    redirect: (context, state) {
      final atLogin = state.matchedLocation == '/login';
      if (!session.isLoggedIn) return atLogin ? null : '/login';

      // Admin route guard
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      if (isAdminRoute && !session.isAdmin) {
        return '/'; // Non-admins cannot access admin screens
      }

      const customerOnly = ['/cart', '/checkout-confirmation', '/order-history'];
      if (session.isAdmin && customerOnly.contains(state.matchedLocation)) {
        return '/';
      }

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
              final idStr = state.pathParameters['id']!;
              final id = int.tryParse(idStr) ?? 1;
              final extra = state.extra;
              if (extra is Product && extra.id == id) {
                return ProductDetailScreen(product: extra);
              }
              return ProductDetailLoader(productId: id);
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
              if (summary == null) return '/';
              final items = summary['items'] as List?;
              if (items == null || items.isEmpty) return '/';
              return null;
            },
            builder: (context, state) {
              final summary = state.extra as Map<String, dynamic>? ?? {};
              return CheckoutConfirmationScreen(summary: summary);
            },
          ),
          GoRoute(
            path: 'order-history',
            builder: (context, state) => const OrderHistoryScreen(),
          ),
          GoRoute(
            path: 'admin/add-product',
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: 'admin/edit-product',
            builder: (context, state) {
              final prod = state.extra as Product?;
              return ProductFormScreen(productToEdit: prod);
            },
          ),
          GoRoute(
            path: 'admin/orders',
            builder: (context, state) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: 'admin/categories',
            builder: (context, state) => const AdminCategoriesScreen(),
          ),
        ],
      ),
    ],
  );
}
