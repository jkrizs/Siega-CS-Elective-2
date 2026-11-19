import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../providers/app_providers.dart';
import '../widgets/quantity_control.dart';
import '../utils/error_messages.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isSubmitting = false;

  Widget _buildItemThumbnail(CartItem cartItem) {
    final imagePath = cartItem.selectedColor?.imageUrl.isNotEmpty == true
        ? cartItem.selectedColor!.imageUrl
        : cartItem.product.imageUrl;

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 28),
      );
    }
    return Image.network(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 28),
    );
  }

  Future<void> _proceedToCheckout() async {
    final cart = ref.read(cartProvider);
    final selectedItems = cart.items.where((e) => e.isSelected).toList();
    if (selectedItems.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await ref.read(ordersProvider).placeOrder(selectedItems);
      final orderId = result['order_id'];
      final total = (result['total'] as num?)?.toDouble() ?? cart.selectedSubtotal;

      final summary = {
        'order_id': orderId,
        'items': selectedItems
            .map(
              (e) => {
                'title': e.selectedColor != null
                    ? '${e.product.name} (${e.selectedColor!.name})'
                    : e.product.name,
                'quantity': e.quantity,
                'price': e.product.price,
                'subtotal': e.subtotal,
              },
            )
            .toList(),
        'total': total,
      };

      cart.removePurchasedItems(selectedItems);
      ref.read(productsProvider).refresh();

      if (mounted) {
        context.go('/checkout-confirmation', extra: summary);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: ${friendlyError(error)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back to store',
        ),
      ),
      body: Builder(
        builder: (context) {
          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Looks like you haven\'t added any bottles to your cart yet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => context.go('/'),
                      child: const Text('Shop Products'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      border: Border(bottom: BorderSide(color: theme.dividerColor)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: cart.isAllSelected,
                            onChanged: (val) => cart.toggleSelectAll(val ?? false),
                            activeColor: theme.colorScheme.primary,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Select All (${cart.items.length} items)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (cart.selectedItemCount > 0)
                          Text(
                            '${cart.selectedItemCount} selected',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cartItem = cart.items[index];

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: cartItem.isSelected,
                                        onChanged: (_) => cart.toggleSelectItem(
                                          cartItem.product.id,
                                          color: cartItem.selectedColor,
                                        ),
                                        activeColor: theme.colorScheme.primary,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 56,
                                      height: 56,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: _buildItemThumbnail(cartItem),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartItem.product.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                '\$${cartItem.product.price.toStringAsFixed(2)}',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                              if (cartItem.selectedColor != null) ...[
                                                const SizedBox(width: 8),
                                                CircleAvatar(
                                                  radius: 4,
                                                  backgroundColor: cartItem.selectedColor!.color,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  cartItem.selectedColor!.name,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    fontSize: 11,
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Subtotal: ',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          '\$${cartItem.subtotal.toStringAsFixed(2)}',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    QuantityControl(
                                      quantity: cartItem.quantity,
                                      onIncrement: () {
                                        final success = cart.updateQuantity(
                                          cartItem.product.id,
                                          1,
                                          color: cartItem.selectedColor,
                                        );
                                        if (!success) {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 1),
                                              content: Text('Cannot exceed available stock.'),
                                            ),
                                          );
                                        }
                                      },
                                      onDecrement: () => cart.updateQuantity(
                                        cartItem.product.id,
                                        -1,
                                        color: cartItem.selectedColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          if (cart.items.isEmpty) return const SizedBox.shrink();

          final hasSelected = cart.selectedItemCount > 0;

          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount:',
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  hasSelected
                                      ? '${cart.selectedItemCount} items selected'
                                      : 'No items selected',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${cart.selectedSubtotal.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: hasSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (hasSelected && !_isSubmitting)
                                ? _proceedToCheckout
                                : null,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    hasSelected
                                        ? 'PROCEED TO CHECKOUT (${cart.selectedItemCount})'
                                        : 'SELECT ITEMS TO CHECKOUT',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
