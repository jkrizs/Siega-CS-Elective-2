import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import '../widgets/editor_picks.dart';
import '../widgets/field_notes.dart';
import '../widgets/hero_banner.dart';
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
                              '${mockProducts.length} styles',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isTablet = constraints.maxWidth >= 600;
                            final isDesktop = constraints.maxWidth >= 960;
                            final crossAxisCount = isDesktop
                                ? 4
                                : (isTablet ? 3 : 2);

                            return GridView.builder(
                              itemCount: mockProducts.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.63,
                              ),
                              itemBuilder: (context, index) {
                                final product = mockProducts[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () =>
                                      context.go('/product/${product.id}'),
                                );
                              },
                            );
                          },
                        ),
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
}
