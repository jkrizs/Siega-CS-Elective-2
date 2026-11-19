import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show supabase;
import '../models/order.dart';
import '../models/product.dart';
import '../utils/error_messages.dart';

abstract class OrderService {
  Future<Map<String, dynamic>> placeOrder(List<CartItem> items);
  Future<List<OrderModel>> fetchMyOrders();
  Future<List<OrderModel>> fetchAllOrders();
  Future<void> updateOrderStatus(int orderId, String status);
}

class SupabaseOrderService implements OrderService {
  @override
  Future<Map<String, dynamic>> placeOrder(List<CartItem> items) async {
    final payload = items
        .map((item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
              'color': item.selectedColor?.name,
            })
        .toList();

    final result = await supabase.rpc(
      'place_order',
      params: {'items': payload},
    );

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    return {'status': 'done'};
  }

  @override
  Future<List<OrderModel>> fetchMyOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('orders')
        .select('*, order_items(*, products(*))')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<OrderModel>> fetchAllOrders() async {
    final data = await supabase
        .from('orders')
        .select('*, profiles(firstname, lastname, email), order_items(*, products(*))')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateOrderStatus(int orderId, String status) async {
    final updated = await supabase
        .from('orders')
        .update({'status': status})
        .eq('id', orderId)
        .select('id');
    if (updated.isEmpty) {
      throw const PostgrestException(
        message: permissionDeniedMessage,
        code: '42501',
      );
    }
  }
}
