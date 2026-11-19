import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../state/cart_state.dart';
import '../state/orders_provider.dart';
import '../state/product_provider.dart';
import '../state/session_state.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) {
  return SupabaseAuthService();
});

final productServiceProvider = Provider<ProductService>((ref) {
  return SupabaseProductService();
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return SupabaseOrderService();
});

// State Notifiers / Providers
final sessionProvider = ChangeNotifierProvider<SessionState>((ref) {
  return SessionState(service: ref.watch(authServiceProvider));
});

final productsProvider = ChangeNotifierProvider<ProductProvider>((ref) {
  return ProductProvider(service: ref.watch(productServiceProvider))..initialize();
});

final cartProvider = ChangeNotifierProvider<CartState>((ref) {
  final cart = CartState();
  // Empty cart automatically when user logs out
  ref.listen<SessionState>(sessionProvider, (prev, next) {
    if (prev?.isLoggedIn == true && !next.isLoggedIn) {
      cart.clearCart();
    }
  });
  return cart;
});

final ordersProvider = ChangeNotifierProvider<OrdersProvider>((ref) {
  return OrdersProvider(service: ref.watch(orderServiceProvider));
});

