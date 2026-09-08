import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:siega_prelimexam/main.dart';
import 'package:siega_prelimexam/screens/cart_screen.dart';
import 'package:siega_prelimexam/screens/checkout_confirmation_screen.dart';
import 'package:siega_prelimexam/screens/product_detail_screen.dart';
import 'package:siega_prelimexam/state/cart_state.dart';
import 'package:siega_prelimexam/widgets/product_card.dart';

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

      await tester.pumpWidget(const HydroFlaskStoreApp());
      await tester.pumpAndSettle();

      expect(find.text('Hydro Flask'), findsWidgets);
      expect(
        find.text('FREE SHIPPING ON ALL ORDERS | LIFETIME WARRANTY'),
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

      await tester.tap(standardMouthCard);
      await tester.pumpAndSettle();

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

      await tester.pumpWidget(const HydroFlaskStoreApp());
      await tester.pumpAndSettle();

      final firstProduct = find.byType(ProductCard).first;
      await tester.tap(firstProduct);
      await tester.pumpAndSettle();

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
          find.widgetWithText(ElevatedButton, 'PROCEED TO CHECKOUT');
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
}
