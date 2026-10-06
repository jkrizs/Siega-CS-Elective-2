import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokemon_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/retro_decorations.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final ScrollController _filterScrollController = ScrollController();

  // Available Pokémon types present in the 30 Kanto Pokémon
  static const List<String> _types = PokemonTypeColors.allFilterTypes;

  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _filterScrollController.addListener(_updateScrollArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollArrows();
      // Ensure initial load from Provider if not already fetched
      final pokemonProvider = context.read<PokemonProvider>();
      if (pokemonProvider.state == PokemonState.initial) {
        pokemonProvider.fetchPokemon();
      }
    });
  }

  @override
  void dispose() {
    _filterScrollController.removeListener(_updateScrollArrows);
    _filterScrollController.dispose();
    super.dispose();
  }

  void _updateScrollArrows() {
    if (!mounted || !_filterScrollController.hasClients) return;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      if (_canScrollLeft || _canScrollRight) {
        setState(() {
          _canScrollLeft = false;
          _canScrollRight = false;
        });
      }
      return;
    }

    final maxScroll = _filterScrollController.position.maxScrollExtent;
    final offset = _filterScrollController.offset;
    final canLeft = offset > 6.0;
    final canRight = maxScroll > 10.0 && offset < (maxScroll - 6.0);

    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.scaffoldBg(isDark);
    final scanlineColor = AppColors.scanline(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: SafeArea(child: _buildGbaHeader(isDark)),
      ),
      body: Stack(
        children: [
          // 1. CRT / LCD Retro Scanline Background (Characteristic of GBA / DS)
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinePainter(
                scanlineColor: scanlineColor,
                spacing: 3.0,
              ),
            ),
          ),

          // 2. Main Content driven strictly by Provider App State
          Consumer<PokemonProvider>(
            builder: (context, pokemonProvider, child) {
              // 4b. Loading State (Manage states using Provider)
              if (pokemonProvider.isLoading) {
                return const LoadingView();
              }

              // 4c. Error State (Manage states using Provider)
              if (pokemonProvider.isError) {
                return ErrorView(
                  errorMessage: pokemonProvider.errorMessage,
                  onRetry: () => pokemonProvider.fetchPokemon(),
                );
              }

              // Empty State
              if (pokemonProvider.pokemonList.isEmpty) {
                return EmptyView(
                  onRefresh: () => pokemonProvider.fetchPokemon(),
                );
              }

              // 4a & 8. Success State - Info display from App State
              final filteredPokemons = pokemonProvider.filteredPokemonList;
              final selectedType = pokemonProvider.selectedType;

              return Column(
                children: [
                  // Mobile-optimized Retro Type Filter Bar (Sourced from Provider App State)
                  _buildTypeFilterBar(isDark, pokemonProvider),

                  // 5. Scrollable Grid of Pokémon
                  Expanded(
                    child: filteredPokemons.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: RetroDialogueBox(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const PokeballWidget(size: 36),
                                    const SizedBox(height: 12),
                                    Text(
                                      'NO $selectedType POKÉMON',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'No Pokémon match this filter in the first 30 entries.',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 14),
                                    GestureDetector(
                                      onTap: () =>
                                          pokemonProvider.setFilterType('ALL'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B4860),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'RESET FILTER (SHOW ALL)',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            color: Color(0xFFE8E088),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            // 7. Refresh functionality re-triggering the API call
                            onRefresh: () => pokemonProvider.fetchPokemon(),
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF3B4860),
                            backgroundColor: isDark
                                ? const Color(0xFF1E2532)
                                : Colors.white,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isPhone = constraints.maxWidth < 600;

                                return GridView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: EdgeInsets.all(isPhone ? 8 : 12),
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        isPhone ? 190 : 220,
                                    crossAxisSpacing: isPhone ? 8 : 12,
                                    mainAxisSpacing: isPhone ? 8 : 12,
                                    childAspectRatio:
                                        isPhone ? 0.70 : 0.74,
                                  ),
                                  itemCount: filteredPokemons.length,
                                  itemBuilder: (context, index) {
                                    final pokemon = filteredPokemons[index];
                                    // 9. When clicked, select Pokémon in Provider and navigate to detail page
                                    return PokemonCard(
                                      pokemon: pokemon,
                                      onTap: () {
                                        pokemonProvider.selectPokemon(pokemon);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const PokemonDetailScreen(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Top banner mimicking the authentic GBA summary header
  Widget _buildGbaHeader(bool isDark) {
    final headerBg = AppColors.headerBg(isDark);
    final tabBg = AppColors.headerTabBg(isDark);
    final borderCol = AppColors.headerBorder(isDark);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderCol, width: 2.5)),
      ),
      child: Row(
        children: [
          // Left golden/cream tab with rounded right end
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: tabBg,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(24),
              ),
              border: const Border(
                right: BorderSide(color: Color(0xFF333333), width: 2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('POKÉDEX', style: AppTextStyles.headerTitle),
                const SizedBox(width: 10),
                // Three retro indicator pill dots (Olive, Translucent, White)
                _buildHeaderPill(const Color(0xFF888844)),
                const SizedBox(width: 4),
                _buildHeaderPill(const Color(0x88888844)),
                const SizedBox(width: 4),
                _buildHeaderPill(Colors.white),
              ],
            ),
          ),

          const Spacer(),

          // 7. Manual Refresh Button in header (re-triggers API call)
          Consumer<PokemonProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Tooltip(
                  message: 'Refresh Pokédex',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: provider.isLoading
                        ? null
                        : () => provider.fetchPokemon(),
                    child: MouseRegion(
                      cursor: provider.isLoading
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F1522)
                              : const Color(0xFF00587C),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.retroGoldGlow
                                : const Color(0xFF80D8FF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark
                                      ? AppColors.retroGoldGlow
                                      : const Color(0xFF80D8FF))
                                  .withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: provider.isLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark
                                      ? AppColors.retroGoldGlow
                                      : const Color(0xFFE0F2FE),
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                color: isDark
                                  ? AppColors.retroGoldGlow
                                  : const Color(0xFFE0F2FE),
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Night Mode / Day Mode Toggle Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.read<ThemeProvider>().toggleTheme(),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F1522)
                      : const Color(0xFF00587C),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.retroGoldGlow
                        : const Color(0xFF80D8FF),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? AppColors.retroGoldGlow
                              : const Color(0xFF80D8FF))
                          .withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark
                      ? AppColors.retroGoldGlow
                      : const Color(0xFFE0F2FE),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Retro Horizontal Type Filter Bar with Dynamic Arrows for Phone Navigation
  Widget _buildTypeFilterBar(bool isDark, PokemonProvider pokemonProvider) {
    final barBg = AppColors.filterBarBg(isDark);
    final borderCol = AppColors.filterBarBorder(isDark);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final showLeft = !isDesktop && _canScrollLeft;
    final showRight = !isDesktop && _canScrollRight;
    final selectedType = pokemonProvider.selectedType;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: barBg,
        border: Border(bottom: BorderSide(color: borderCol, width: 2.0)),
      ),
      child: Row(
        children: [
          // Left Scroll Arrow (◀)
          if (showLeft)
            _buildScrollArrow(
              icon: Icons.chevron_left_rounded,
              tooltip: 'Previous types',
              onTap: () {
                if (_filterScrollController.hasClients) {
                  final target =
                      (_filterScrollController.offset - 160).clamp(
                    0.0,
                    _filterScrollController.position.maxScrollExtent,
                  );
                  _filterScrollController.animateTo(
                    target,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
              isDark: isDark,
            ),

          // Horizontal Scrolling Chips (App State)
          Expanded(
            child: ListView.separated(
              controller: _filterScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: showLeft ? 4 : 8,
                vertical: 7,
              ),
              itemCount: _types.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final type = _types[index];
                final isSelected = selectedType == type;
                final typeColor = PokemonTypeColors.getColor(type);

                return GestureDetector(
                  onTap: () => pokemonProvider.setFilterType(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? typeColor
                          : typeColor.withValues(
                              alpha: isDark ? 0.28 : 0.35,
                            ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : AppColors.filterChipBorder(isDark),
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: typeColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Text(
                            '▶ ',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                        Text(
                          type,
                          style: AppTextStyles.filterChip(
                            isSelected: isSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Right Scroll Arrow (▶)
          if (showRight)
            _buildScrollArrow(
              icon: Icons.chevron_right_rounded,
              tooltip: 'More types',
              onTap: () {
                if (_filterScrollController.hasClients) {
                  final target =
                      (_filterScrollController.offset + 160).clamp(
                    0.0,
                    _filterScrollController.position.maxScrollExtent,
                  );
                  _filterScrollController.animateTo(
                    target,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  /// Navigation arrow button for smooth scrolling of the retro type chips
  Widget _buildScrollArrow({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final arrowColor = AppColors.arrowColor(isDark);
    final buttonBg = AppColors.arrowButtonBg(isDark);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: buttonBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: arrowColor.withValues(alpha: 0.85),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: arrowColor.withValues(alpha: 0.35),
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Icon(icon, size: 20, color: arrowColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPill(Color color) {
    return Container(
      width: 10,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0x44000000), width: 0.8),
      ),
    );
  }
}
