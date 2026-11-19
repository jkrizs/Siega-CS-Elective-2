import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_messages.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  int _selectedColorIndex = 0;

  Widget _buildProductImage() {
    final colors = widget.product.colors;
    final colorOption = colors.isNotEmpty && _selectedColorIndex < colors.length
        ? colors[_selectedColorIndex]
        : null;
    final currentImage = colorOption?.imageUrl ?? widget.product.imageUrl;

    final Widget imageWidget = currentImage.startsWith('assets/')
        ? Image.asset(
            currentImage,
            key: ValueKey(currentImage),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 40),
          )
        : Image.network(
            currentImage,
            key: ValueKey(currentImage),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 40),
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: imageWidget,
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${widget.product.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(productsProvider).deleteProduct(widget.product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "${widget.product.name}".')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not delete: ${friendlyError(e)}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionProvider);
    final isAdmin = session.isAdmin;
    final isOut = widget.product.isOutOfStock;
    final colors = widget.product.colors;
    final hasColors = colors.isNotEmpty;

    final selectedColor = hasColors && _selectedColorIndex < colors.length
        ? colors[_selectedColorIndex]
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.product.categoryName != null &&
                      widget.product.categoryName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.product.categoryName!.toUpperCase(),
                        style: AppTextStyles.productBadge.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOut
                          ? AppColors.danger.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isOut ? 'OUT OF STOCK' : 'Stock: ${widget.product.stock}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOut ? AppColors.danger : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(4),
                  child: Center(child: _buildProductImage()),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (selectedColor != null)
                    Text(
                      selectedColor.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Color selection circles that switch the image!
              if (hasColors)
                SizedBox(
                  height: 18,
                  child: Row(
                    children: List.generate(colors.length, (index) {
                      final option = colors[index];
                      final isSelected = _selectedColorIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedColorIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 5,
                            backgroundColor: option.color,
                          ),
                        ),
                      );
                    }),
                  ),
                )
              else
                const SizedBox(height: 18),
              const SizedBox(height: 6),
              if (isAdmin)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => context.go(
                          '/admin/edit-product',
                          extra: widget.product,
                        ),
                        child: const Text('Edit', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _confirmDelete,
                        child: const Text('Delete', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: isOut
                        ? null
                        : () {
                            final added = ref.read(cartProvider).addItem(
                                  widget.product,
                                  color: selectedColor,
                                );
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            if (added) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 2),
                                  content: Text(
                                    selectedColor != null
                                        ? 'Added "${widget.product.name} (${selectedColor.name})" to cart!'
                                        : 'Added "${widget.product.name}" to cart!',
                                  ),
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    onPressed: () => context.go('/cart'),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cannot add more than available stock.'),
                                ),
                              );
                            }
                          },
                    child: Text(
                      isOut ? 'OUT OF STOCK' : 'ADD TO CART',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
