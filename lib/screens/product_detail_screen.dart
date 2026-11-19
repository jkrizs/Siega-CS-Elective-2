import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_messages.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

enum _ManageAction { edit, delete }

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _isAdded = false;
  late Product _product = widget.product;
  int _selectedColorIndex = 0;
  bool _isDeleting = false;

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product) {
      _product = widget.product;
      _selectedColorIndex = 0;
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'This removes "${_product.name}" from the store. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = ref.read(productsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final deletedName = _product.name;

    setState(() => _isDeleting = true);
    try {
      await provider.deleteProduct(_product.id);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text('Deleted $deletedName.')),
      );
      router.go('/');
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete: ${friendlyError(error)}')),
      );
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _handleAddToCart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snackBarBg = isDark ? const Color(0xFF222222) : AppColors.primary;
    final accentColor = isDark ? AppColors.primaryLight : Colors.white;

    final colors = _product.colors;
    final selectedColor = colors.isNotEmpty && _selectedColorIndex < colors.length
        ? colors[_selectedColorIndex]
        : null;

    final success = ref.read(cartProvider).addItem(_product, color: selectedColor);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add more than available stock.')),
      );
      return;
    }

    setState(() => _isAdded = true);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: snackBarBg,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedColor != null
                    ? 'Added ${_product.name} (${selectedColor.name}) to cart!'
                    : 'Added ${_product.name} to cart!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: accentColor,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.go('/cart');
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isAdded = false);
    });
  }

  Widget _buildProductImage() {
    final colors = _product.colors;
    final colorOption = colors.isNotEmpty && _selectedColorIndex < colors.length
        ? colors[_selectedColorIndex]
        : null;
    final currentImage = colorOption?.imageUrl ?? _product.imageUrl;

    final Widget imageWidget = currentImage.startsWith('assets/')
        ? Image.asset(
            currentImage,
            key: ValueKey(currentImage),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 64),
          )
        : Image.network(
            currentImage,
            key: ValueKey(currentImage),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 64),
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: imageWidget,
    );
  }

  Widget _buildColorSelector(ThemeData theme) {
    final colors = _product.colors;
    if (colors.isEmpty) return const SizedBox.shrink();

    final selectedColor = _selectedColorIndex < colors.length
        ? colors[_selectedColorIndex]
        : colors.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SELECT COLOR',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                selectedColor.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(colors.length, (index) {
            final option = colors[index];
            final isSelected = _selectedColorIndex == index;
            final isDarkColor =
                ThemeData.estimateBrightnessForColor(option.color) ==
                Brightness.dark;

            return Tooltip(
              message: option.name,
              child: GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: option.color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: option.color,
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: isDarkColor ? Colors.white : Colors.black87,
                          )
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    final isOut = _product.isOutOfStock;
    return ElevatedButton(
      onPressed: isOut ? null : _handleAddToCart,
      child: Text(
        isOut
            ? 'OUT OF STOCK'
            : (_isAdded ? 'ADDED TO CART ✓' : 'ADD TO CART'),
      ),
    );
  }

  Widget _buildHeaderInfo(ThemeData theme) {
    final isOut = _product.isOutOfStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_product.categoryName != null)
              Text(
                _product.categoryName!.toUpperCase(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              )
            else
              const SizedBox.shrink(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOut
                    ? AppColors.danger.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isOut ? 'OUT OF STOCK' : 'In Stock: ${_product.stock} available',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOut ? AppColors.danger : AppColors.success,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _product.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '\$${_product.price.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final session = ref.watch(sessionProvider);
    final cart = ref.watch(cartProvider);
    final isAdmin = session.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.go('/');
          },
          tooltip: 'Back to products',
        ),
        actions: [
          if (isAdmin)
            PopupMenuButton<_ManageAction>(
              tooltip: 'Manage product',
              enabled: !_isDeleting,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.more_vert),
              onSelected: (action) {
                switch (action) {
                  case _ManageAction.edit:
                    context.go('/admin/edit-product', extra: _product);
                  case _ManageAction.delete:
                    _deleteProduct();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ManageAction.edit,
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit product'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _ManageAction.delete,
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.danger),
                    title: Text('Delete product', style: TextStyle(color: AppColors.danger)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          Badge(
            label: Text('${cart.totalItemCount}'),
            isLabelVisible: cart.totalItemCount > 0,
            offset: const Offset(-2, 4),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                context.go('/cart');
              },
              tooltip: 'View Cart',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isTablet
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          color: Colors.white,
                          child: Container(
                            height: 440,
                            padding: const EdgeInsets.all(28),
                            child: Center(child: _buildProductImage()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderInfo(theme),
                            const SizedBox(height: 20),
                            _buildColorSelector(theme),
                            const SizedBox(height: 24),
                            if (!isAdmin) ...[
                              SizedBox(
                                width: double.infinity,
                                child: _buildAddToCartButton(),
                              ),
                              const SizedBox(height: 24),
                            ],
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Product Overview',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _product.description,
                              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.white,
                    child: Container(
                      height: 320,
                      padding: const EdgeInsets.all(24),
                      child: Center(child: _buildProductImage()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildHeaderInfo(theme),
                  const SizedBox(height: 20),
                  _buildColorSelector(theme),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Product Overview',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: (isTablet || isAdmin)
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: _buildAddToCartButton(),
              ),
            ),
    );
  }
}
