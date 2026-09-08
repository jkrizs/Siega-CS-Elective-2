import 'package:flutter/material.dart';
import '../models/product.dart';

class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get selectedItemCount => _items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  double get selectedSubtotal => _items
      .where((item) => item.isSelected)
      .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  void addItem(Product product, ProductColorOption color) {
    final index = _items.indexWhere(
      (i) => i.product.id == product.id && i.selectedColor == color,
    );
    if (index >= 0) {
      _items[index].quantity += 1;
      _items[index].isSelected = true;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: 1,
        selectedColor: color,
        isSelected: true,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, ProductColorOption color, int change) {
    final index = _items.indexWhere(
      (i) => i.product.id == productId && i.selectedColor == color,
    );
    if (index >= 0) {
      _items[index].quantity += change;
      if (_items[index].quantity <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void toggleSelectItem(String productId, ProductColorOption color) {
    final index = _items.indexWhere(
      (i) => i.product.id == productId && i.selectedColor == color,
    );
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }

  void toggleSelectAll(bool selected) {
    for (final item in _items) {
      item.isSelected = selected;
    }
    notifyListeners();
  }

  void removePurchasedItems(List<CartItem> purchased) {
    _items.removeWhere((item) => purchased.contains(item));
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

final cartState = CartState();
