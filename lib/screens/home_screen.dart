import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/product_provider.dart';
import '../state/session_state.dart';
import '../state/cart_state.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredSectionKey = GlobalKey();
  final GlobalKey _editorPicksKey = GlobalKey();
  final GlobalKey _fieldNotesKey = GlobalKey();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;
    final themeProvider = ThemeProvider.of(context);
    final products = context.watch<ProductProvider>();
    final theme = Theme.of(context);

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
          AnimatedBuilder(
            animation: cartState,
            builder: (context, _) => Badge(
              label: Text('${cartState.totalItemCount}'),
              isLabelVisible: cartState.totalItemCount > 0,
              offset: const Offset(-2, 4),
              child: IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => context.go('/cart'),
                tooltip: 'View Cart',
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in [
          ProductProvider.allCategories,
          ...products.categories,
        ])
          FilterChip(
            label: Text(category),
            selected: products.selectedCategory == category,
            onSelected: (_) => products.selectCategory(category),
            showCheckmark: false,
            selectedColor: colors.primary,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: products.selectedCategory == category
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
                  childAspectRatio: 0.63,
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

class _AccountMenu extends StatelessWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final account = session.account;
    final theme = Theme.of(context);

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
                account?.displayName ?? '',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (account?.provider != null)
                Text(
                  'Signed in with ${account!.provider == 'github' ? 'GitHub' : 'email'}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
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
