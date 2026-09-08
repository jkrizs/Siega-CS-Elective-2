import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAdded = false;
  late int _selectedColorIndex;

  @override
  void initState() {
    super.initState();
    _selectedColorIndex = 0;
  }

  void _handleAddToCart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snackBarBg = isDark ? const Color(0xFF222222) : AppColors.primary;
    final accentColor = isDark ? AppColors.primaryLight : Colors.white;

    final selectedColor = widget.product.colors.isNotEmpty
        ? widget.product.colors[_selectedColorIndex]
        : ProductColorOption(
            name: 'Default',
            color: widget.product.swatches.first,
            imageUrl: widget.product.imageUrl,
          );
    cartState.addItem(widget.product, selectedColor);

    setState(() => _isAdded = true);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: snackBarBg,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark
              ? BorderSide(
                  color: AppColors.primaryLight.withValues(alpha: 0.35),
                  width: 1,
                )
              : BorderSide.none,
        ),
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${widget.product.title} (${selectedColor.name}) to cart!',
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
      if (mounted) {
        setState(() => _isAdded = false);
      }
    });
  }

  Widget _buildProductImage() {
    final colorOption = widget.product.colors.isNotEmpty
        ? widget.product.colors[_selectedColorIndex]
        : null;
    final currentImage = colorOption?.imageUrl ?? widget.product.imageUrl;

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
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: imageWidget,
    );
  }

  Widget _buildAddToCartButton() {
    return ElevatedButton(
      onPressed: _handleAddToCart,
      child: Text(_isAdded ? 'ADDED TO CART ✓' : 'ADD TO CART'),
    );
  }

  Widget _buildHeaderInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.product.size,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, color: AppTheme.starColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${widget.product.rating} (128 reviews)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '\$${widget.product.price.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector(ThemeData theme) {
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
            if (widget.product.colors.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.product.colors[_selectedColorIndex].name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(widget.product.colors.length, (index) {
            final option = widget.product.colors[index];
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

  Widget _buildOverview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Overview',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.go('/');
          },
          tooltip: 'Back to products',
        ),
        actions: [
          AnimatedBuilder(
            animation: cartState,
            builder: (context, _) => Badge(
              label: Text('${cartState.totalItemCount}'),
              isLabelVisible: cartState.totalItemCount > 0,
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
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isTablet
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Product Image
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
                      // Right Column: Details + Add to Cart right in flow
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderInfo(theme),
                            const SizedBox(height: 20),
                            _buildColorSelector(theme),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: _buildAddToCartButton(),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildOverview(theme),
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
                  const SizedBox(height: 24),
                  _buildColorSelector(theme),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildOverview(theme),
                ],
              ),
            ),
      bottomNavigationBar: isTablet
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
