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

  int quantityInCart(int productId) => _items
      .where((item) => item.product.id == productId)
      .fold(0, (sum, item) => sum + item.quantity);

  /// Adds a product to the cart with color option and stock enforcement
  bool addItem(Product product, {int quantity = 1, ProductColorOption? color}) {
    if (product.stock <= 0) return false;

    final chosenColor = color ?? (product.colors.isNotEmpty ? product.colors.first : null);

    final index = _items.indexWhere(
      (i) => i.product.id == product.id && i.selectedColor?.name == chosenColor?.name,
    );
    if (quantityInCart(product.id) + quantity > product.stock) {
      return false;
    }
    if (index >= 0) {
      _items[index].quantity += quantity;
      _items[index].isSelected = true;
    } else {
      if (quantity > product.stock) return false;
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        isSelected: true,
        selectedColor: chosenColor,
      ));
    }
    notifyListeners();
    return true;
  }

  bool updateQuantity(int productId, int change, {ProductColorOption? color}) {
    final index = _items.indexWhere(
      (i) => i.product.id == productId && (color == null || i.selectedColor?.name == color.name),
    );
    if (index >= 0) {
      final target = _items[index];
      final newQty = target.quantity + change;
      if (newQty <= 0) {
        _items.removeAt(index);
        notifyListeners();
        return true;
      }
      if (change > 0 &&
          quantityInCart(productId) + change > target.product.stock) {
        return false;
      }
      target.quantity = newQty;
      notifyListeners();
      return true;
    }
    return false;
  }

  void toggleSelectItem(int productId, {ProductColorOption? color}) {
    final index = _items.indexWhere(
      (i) => i.product.id == productId && (color == null || i.selectedColor?.name == color.name),
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
