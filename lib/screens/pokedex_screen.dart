import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pokemon_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/loading_view.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/retro_decorations.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  final ScrollController _filterScrollController = ScrollController();

  static const List<String> _types = PokemonTypeColors.allFilterTypes;

  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _filterScrollController.addListener(_updateScrollArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollArrows();
      final status = ref.read(pokemonProvider).status;
      if (status == PokemonStatus.initial) {
        ref.read(pokemonProvider.notifier).fetchPokemon();
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

    final pokemonState = ref.watch(pokemonProvider);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: SafeArea(child: _buildGbaHeader(isDark, pokemonState)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinePainter(
                scanlineColor: scanlineColor,
                spacing: 3.0,
              ),
            ),
          ),

          Column(
            children: [
              const FavoritesPanel(),

              Expanded(
                child: _buildBodyContent(isDark, pokemonState),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(bool isDark, PokemonState pokemonState) {
    if (pokemonState.isLoading) {
      return const LoadingView();
    }

    if (pokemonState.isError) {
      return ErrorView(
        errorMessage: pokemonState.errorMessage,
        onRetry: () => ref.read(pokemonProvider.notifier).fetchPokemon(),
      );
    }

    if (pokemonState.pokemonList.isEmpty) {
      return EmptyView(
        onRefresh: () => ref.read(pokemonProvider.notifier).fetchPokemon(),
      );
    }

    final filteredPokemons = pokemonState.filteredPokemonList;
    final selectedType = pokemonState.selectedType;

    return Column(
      children: [
        _buildTypeFilterBar(isDark, selectedType),

        Expanded(
          child: filteredPokemons.isEmpty
              ? _buildNoFilteredPokemonView(selectedType)
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(pokemonProvider.notifier).fetchPokemon(),
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
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.all(isPhone ? 8 : 12),
                        gridDelegate:
                            SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isPhone ? 190 : 220,
                          crossAxisSpacing: isPhone ? 8 : 12,
                          mainAxisSpacing: isPhone ? 8 : 12,
                          childAspectRatio: isPhone ? 0.68 : 0.72,
                        ),
                        itemCount: filteredPokemons.length,
                        itemBuilder: (context, index) {
                          final pokemon = filteredPokemons[index];
                          return PokemonCard(
                            pokemon: pokemon,
                            onTap: () {
                              ref
                                  .read(pokemonProvider.notifier)
                                  .selectPokemon(pokemon);
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
  }

  Widget _buildNoFilteredPokemonView(String selectedType) {
    return Center(
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
                'No Pokémon match this filter in the registered list.',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () =>
                    ref.read(pokemonProvider.notifier).clearTypeFilter(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B4860),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'CLEAR FILTER (SHOW ALL)',
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
    );
  }

  Widget _buildGbaHeader(bool isDark, PokemonState pokemonState) {
    final headerBg = AppColors.headerBg(isDark);
    final tabBg = AppColors.headerTabBg(isDark);
    final borderCol = AppColors.headerBorder(isDark);
    final isFavOpen = pokemonState.isFavoritesPanelExpanded;
    final favCount = pokemonState.favorites.length;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderCol, width: 2.5)),
      ),
      child: Row(
        children: [
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
                const SizedBox(width: 8),
                _buildHeaderPill(const Color(0xFF888844)),
                const SizedBox(width: 4),
                _buildHeaderPill(const Color(0x88888844)),
                const SizedBox(width: 4),
                _buildHeaderPill(Colors.white),
              ],
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Tooltip(
              message: isFavOpen ? 'Collapse Favorites' : 'Expand Favorites',
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => ref
                    .read(pokemonProvider.notifier)
                    .toggleFavoritesPanel(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: isFavOpen
                        ? const Color(0xFFEF4444)
                        : (isDark
                            ? const Color(0xFF0F1522)
                            : const Color(0xFF00587C)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFavOpen
                          ? Colors.white
                          : (isDark
                              ? AppColors.retroGoldGlow
                              : const Color(0xFF80D8FF)),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isFavOpen
                                ? const Color(0xFFEF4444)
                                : (isDark
                                    ? AppColors.retroGoldGlow
                                    : const Color(0xFF80D8FF)))
                            .withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 15,
                        color: isFavOpen
                            ? Colors.white
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$favCount',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isFavOpen
                              ? Colors.white
                              : (isDark
                                  ? AppColors.retroGoldGlow
                                  : const Color(0xFFE0F2FE)),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        isFavOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: isFavOpen
                            ? Colors.white
                            : (isDark
                                ? AppColors.retroGoldGlow
                                : const Color(0xFFE0F2FE)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Tooltip(
              message: 'Refresh Pokémon',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: pokemonState.isLoading
                    ? null
                    : () => ref
                        .read(pokemonProvider.notifier)
                        .fetchPokemon(),
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
                  child: pokemonState.isLoading
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

          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
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

  Widget _buildTypeFilterBar(bool isDark, String selectedType) {
    final barBg = AppColors.filterBarBg(isDark);
    final borderCol = AppColors.filterBarBorder(isDark);
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final showLeft = !isDesktop && _canScrollLeft;
    final showRight = !isDesktop && _canScrollRight;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: barBg,
        border: Border(bottom: BorderSide(color: borderCol, width: 2.0)),
      ),
      child: Row(
        children: [
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
                  onTap: () {
                    if (isSelected && type != 'ALL') {
                      ref.read(pokemonProvider.notifier).clearTypeFilter();
                    } else {
                      ref.read(pokemonProvider.notifier).setTypeFilter(type);
                    }
                  },
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

          if (selectedType != 'ALL')
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Tooltip(
                message: 'Clear Type Filter',
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () =>
                      ref.read(pokemonProvider.notifier).clearTypeFilter(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFEF4444),
                        width: 1.2,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_off_rounded,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'CLEAR',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

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
