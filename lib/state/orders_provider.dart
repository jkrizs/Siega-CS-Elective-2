import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../services/order_service.dart';
import '../utils/error_messages.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider({OrderService? service})
      : _service = service ?? SupabaseOrderService();

  final OrderService _service;

  List<OrderModel> _myOrders = const [];
  List<OrderModel> _allOrders = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get myOrders => _myOrders;
  List<OrderModel> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myOrders = await _service.fetchMyOrders();
    } catch (e) {
      _errorMessage = _describeError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allOrders = await _service.fetchAllOrders();
    } catch (e) {
      _errorMessage = _describeError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> placeOrder(List<CartItem> items) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.placeOrder(items);
      await fetchMyOrders();
      return res;
    } catch (e) {
      _errorMessage = _describeError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await _service.updateOrderStatus(orderId, status);
    await fetchAllOrders();
  }

  String _describeError(Object error) => friendlyError(error);
}

