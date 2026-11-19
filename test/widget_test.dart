import 'package:flutter_test/flutter_test.dart';

import 'package:siega_prelimexam/models/category.dart';
import 'package:siega_prelimexam/models/order.dart';
import 'package:siega_prelimexam/models/product.dart';
import 'package:siega_prelimexam/state/cart_state.dart';

void main() {
  group('E-Commerce App Unit Tests', () {
    test('Category model parses correctly', () {
      final cat = Category.fromMap({'id': 1, 'name': 'Bottles'});
      expect(cat.id, 1);
      expect(cat.name, 'Bottles');
    });

    test('Product model isOutOfStock checks correctly', () {
      const inStockProd = Product(
        id: 1,
        name: 'In Stock Bottle',
        description: 'Test description',
        stock: 5,
        imageUrl: 'assets/products/wide_indigo.png',
        price: 34.95,
      );
      expect(inStockProd.isOutOfStock, isFalse);

      const outOfStockProd = Product(
        id: 2,
        name: 'Sold Out Bottle',
        description: 'Test description',
        stock: 0,
        imageUrl: 'assets/products/wide_indigo.png',
        price: 34.95,
      );
      expect(outOfStockProd.isOutOfStock, isTrue);
    });

    test('CartState enforces stock limits', () {
      final cart = CartState();
      const product = Product(
        id: 1,
        name: 'Limited Stock Bottle',
        description: '',
        stock: 2,
        imageUrl: '',
        price: 20.0,
      );

      // Add within stock
      expect(cart.addItem(product, quantity: 1), isTrue);
      expect(cart.totalItemCount, 1);

      // Add up to stock
      expect(cart.addItem(product, quantity: 1), isTrue);
      expect(cart.totalItemCount, 2);

      // Exceed stock -> should fail!
      expect(cart.addItem(product, quantity: 1), isFalse);
      expect(cart.totalItemCount, 2);

      // Clear cart
      cart.clearCart();
      expect(cart.totalItemCount, 0);
      expect(cart.items.isEmpty, isTrue);
    });

    test('OrderModel parses with items', () {
      final rawOrder = {
        'id': 101,
        'user_id': 'user-123',
        'status': 'done',
        'total': 49.95,
        'created_at': '2026-11-19T10:00:00Z',
        'order_items': [
          {
            'id': 1,
            'order_id': 101,
            'product_id': 1,
            'unit_price': 49.95,
            'quantity': 1,
            'product_name': 'Hydro Flask 32oz',
          }
        ]
      };

      final order = OrderModel.fromMap(rawOrder);
      expect(order.id, 101);
      expect(order.status, 'done');
      expect(order.total, 49.95);
      expect(order.items.length, 1);
      expect(order.items.first.productName, 'Hydro Flask 32oz');
    });
  });
}
