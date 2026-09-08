import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';

class StoreDrawer extends StatelessWidget {
  final VoidCallback? onProductsSelected;
  final VoidCallback? onEditorPicksSelected;
  final VoidCallback? onFieldNotesSelected;

  const StoreDrawer({
    super.key,
    this.onProductsSelected,
    this.onEditorPicksSelected,
    this.onFieldNotesSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = ThemeProvider.of(context);
    final isDark = themeProvider?.isDark ?? false;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hydro Flask',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: const Text(
                      'All Products',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      Navigator.pop(context);
                      onProductsSelected?.call();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.star_outline_rounded),
                    title: const Text(
                      "Editor's Picks",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      Navigator.pop(context);
                      onEditorPicksSelected?.call();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text(
                      'Field Notes & Stories',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      Navigator.pop(context);
                      onFieldNotesSelected?.call();
                    },
                  ),
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      'PREFERENCES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                    ),
                    title: Text(
                      isDark ? 'Dark Mode' : 'Light Mode',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: isDark,
                    onChanged: (_) => themeProvider?.toggleTheme(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            // Cart Button at bottom
            AnimatedBuilder(
              animation: cartState,
              builder: (context, _) => ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text(
                  'My Cart',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cartState.totalItemCount} items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/cart');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
