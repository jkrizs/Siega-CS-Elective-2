import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../state/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/editor_picks.dart';
import '../widgets/field_notes.dart';
import '../widgets/hero_banner.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/price_range_filter.dart';
import '../widgets/product_card.dart';
import '../widgets/store_drawer.dart';
import '../widgets/store_footer.dart';
import '../widgets/trust_bar.dart';
import '../widgets/why_hydro_flask.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredSectionKey = GlobalKey();
  final GlobalKey _editorPicksKey = GlobalKey();
  final GlobalKey _fieldNotesKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  void _scrollToKey(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToProductGrid() => _scrollToKey(_featuredSectionKey);

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;
    final themeProvider = ThemeProvider.of(context);
    final products = ref.watch(productsProvider);
    final session = ref.watch(sessionProvider);
    final cart = ref.watch(cartProvider);
    final theme = Theme.of(context);
    final isAdmin = session.isAdmin;

    return Scaffold(
      drawer: isCompact
          ? StoreDrawer(
              onProductsSelected: _scrollToProductGrid,
              onEditorPicksSelected: () => _scrollToKey(_editorPicksKey),
              onFieldNotesSelected: () => _scrollToKey(_fieldNotesKey),
            )
          : null,
      appBar: AppBar(
        title: const Text('Hydro Flask'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider?.isDark == true
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: themeProvider?.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          const _AccountMenu(),
          if (!isAdmin)
            Badge(
              label: Text('${cart.totalItemCount}'),
              isLabelVisible: cart.totalItemCount > 0,
              offset: const Offset(-2, 4),
              child: IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => context.go('/cart'),
                tooltip: 'View Cart',
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/admin/add-product'),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroBanner(onExplorePressed: _scrollToProductGrid),
                  const TrustBar(),
                  const SizedBox(height: 28),
                  KeyedSubtree(
                    key: _editorPicksKey,
                    child: const EditorPicksSection(),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    key: _featuredSectionKey,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Products',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${products.totalCount} styles',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Search bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products by name...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      products.setSearchQuery('');
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (val) => products.setSearchQuery(val),
                        ),
                        const SizedBox(height: 12),
                        _buildCategoryChips(context, products),
                        const SizedBox(height: 12),
                        const PriceRangeFilter(),
                        const SizedBox(height: 16),
                        _buildProductArea(context, products),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  KeyedSubtree(
                    key: _fieldNotesKey,
                    child: const FieldNotesSection(),
                  ),
                  const SizedBox(height: 28),
                  const WhyHydroFlaskSection(),
                  const SizedBox(height: 24),
                  const StoreFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, ProductProvider products) {
    final colors = Theme.of(context).colorScheme;
    final categories = products.categories;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: products.selectedCategoryId == null,
          onSelected: (_) => products.selectCategory(null),
          showCheckmark: false,
          selectedColor: colors.primary,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: products.selectedCategoryId == null
                ? colors.onPrimary
                : colors.onSurface,
          ),
          shape: const StadiumBorder(),
        ),
        for (final cat in categories)
          FilterChip(
            label: Text(cat.name),
            selected: products.selectedCategoryId == cat.id,
            onSelected: (_) => products.selectCategory(cat.id),
            showCheckmark: false,
            selectedColor: colors.primary,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: products.selectedCategoryId == cat.id
                  ? colors.onPrimary
                  : colors.onSurface,
            ),
            shape: const StadiumBorder(),
          ),
      ],
    );
  }

  Widget _buildProductArea(BuildContext context, ProductProvider products) {
    final theme = Theme.of(context);

    if (!products.hasLoaded && products.isLoading) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (products.errorMessage != null) {
      return _MessageView(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load products',
        message: products.errorMessage!,
        actionLabel: 'Try again',
        onAction: products.retry,
      );
    }

    if (products.products.isEmpty) {
      return _MessageView(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: 'Nothing matches this category and price range.',
        actionLabel: products.isPriceFiltered ? 'Reset price range' : null,
        onAction: products.isPriceFiltered ? products.resetPriceRange : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Showing ${products.firstItemNumber}–${products.lastItemNumber} '
          'of ${products.totalCount} products',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 3,
          child: products.isLoading ? const LinearProgressIndicator() : null,
        ),
        const SizedBox(height: 8),
        AnimatedOpacity(
          opacity: products.isLoading ? 0.5 : 1,
          duration: const Duration(milliseconds: 150),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 600;
              final isDesktop = constraints.maxWidth >= 960;
              final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

              return GridView.builder(
                itemCount: products.products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  final product = products.products[index];
                  return ProductCard(
                    key: ValueKey(product.id),
                    product: product,
                    onTap: () =>
                        context.go('/product/${product.id}', extra: product),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: PaginationBar()),
      ],
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountMenu extends ConsumerWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final profile = session.profile;
    final theme = Theme.of(context);
    final isAdmin = session.isAdmin;

    return PopupMenuButton<void>(
      tooltip: 'My Account',
      icon: const Icon(Icons.person_outline),
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.displayName ?? session.user?.email ?? 'User',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isAdmin ? 'ADMIN' : 'CUSTOMER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isAdmin
                        ? AppColors.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (isAdmin) ...[
          PopupMenuItem<void>(
            onTap: () => context.go('/admin/orders'),
            child: const Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 20),
                SizedBox(width: 12),
                Text('Store Orders'),
              ],
            ),
          ),
          PopupMenuItem<void>(
            onTap: () => context.go('/admin/categories'),
            child: const Row(
              children: [
                Icon(Icons.category_outlined, size: 20),
                SizedBox(width: 12),
                Text('Categories'),
              ],
            ),
          ),
          PopupMenuItem<void>(
            onTap: () => context.go('/admin/add-product'),
            child: const Row(
              children: [
                Icon(Icons.add_box_outlined, size: 20),
                SizedBox(width: 12),
                Text('Add Product'),
              ],
            ),
          ),
        ] else ...[
          PopupMenuItem<void>(
            onTap: () => context.go('/order-history'),
            child: const Row(
              children: [
                Icon(Icons.receipt_long_outlined, size: 20),
                SizedBox(width: 12),
                Text('My Orders'),
              ],
            ),
          ),
        ],
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: session.logout,
          child: const Row(
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 12),
              Text('Log out'),
            ],
          ),
        ),
      ],
    );
  }
}
