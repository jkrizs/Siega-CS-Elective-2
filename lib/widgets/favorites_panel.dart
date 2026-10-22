import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import '../theme/app_colors.dart';
import 'retro_decorations.dart';

class FavoritesPanel extends ConsumerStatefulWidget {
  const FavoritesPanel({super.key});

  @override
  ConsumerState<FavoritesPanel> createState() => _FavoritesPanelState();
}

class _FavoritesPanelState extends ConsumerState<FavoritesPanel> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicators);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final canLeft = offset > 4.0;
    final canRight = maxScroll > 8.0 && offset < (maxScroll - 4.0);

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
    final state = ref.watch(pokemonProvider);
    final isExpanded = state.isFavoritesPanelExpanded;
    final favoriteList = state.favoritePokemonList;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
    });

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      child: isExpanded
          ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161B22)
                    : const Color(0xFFE2E8F0),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF30363D)
                        : const Color(0xFF94A3B8),
                    width: 2.0,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x35000000),
                    offset: Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderBar(isDark, favoriteList.length),
                  favoriteList.isEmpty
                      ? _buildEmptyFavorites(isDark)
                      : _buildFavoritesList(isDark, favoriteList, state),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildHeaderBar(bool isDark, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFCBD5E1),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF21262D) : const Color(0xFFB0BEC5),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.favorite,
            size: 15,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Text(
            'FAVORITE POKÉMON ($count)',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xFFE8E088) : const Color(0xFF1E2532),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () =>
                ref.read(pokemonProvider.notifier).toggleFavoritesPanel(),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF21262D)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF30363D)
                      : const Color(0xFF94A3B8),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'COLLAPSE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark
                          ? const Color(0xFF9EA8BA)
                          : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_up,
                    size: 14,
                    color: isDark
                        ? const Color(0xFF9EA8BA)
                        : const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 20,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'No favorites yet! Tap the ♥ heart on any Pokémon card to add them here.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF9EA8BA)
                        : const Color(0xFF475569),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(
    bool isDark,
    List<Pokemon> favoriteList,
    PokemonState state,
  ) {
    return SizedBox(
      height: 156,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            itemCount: favoriteList.length,
            itemBuilder: (context, index) {
              final pokemon = favoriteList[index];
              final nickname = state.getNickname(pokemon.id);

              return _FavoritePokemonMiniCard(
                pokemon: pokemon,
                nickname: nickname,
                isDark: isDark,
                onTap: () {
                  ref.read(pokemonProvider.notifier).selectPokemon(pokemon);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PokemonDetailScreen(),
                    ),
                  );
                },
                onRemove: () {
                  ref.read(pokemonProvider.notifier).toggleFavorite(pokemon.id);
                },
              );
            },
          ),
          if (_canScrollLeft)
            Positioned(
              left: 2,
              top: 0,
              bottom: 0,
              child: Center(
                child: InkWell(
                  onTap: () {
                    final target = (_scrollController.offset - 130).clamp(
                      0.0,
                      _scrollController.position.maxScrollExtent,
                    );
                    _scrollController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white)
                          .withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF3B4860),
                      ),
                    ),
                    child: const Icon(Icons.chevron_left, size: 16),
                  ),
                ),
              ),
            ),
          if (_canScrollRight)
            Positioned(
              right: 2,
              top: 0,
              bottom: 0,
              child: Center(
                child: InkWell(
                  onTap: () {
                    final target = (_scrollController.offset + 130).clamp(
                      0.0,
                      _scrollController.position.maxScrollExtent,
                    );
                    _scrollController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white)
                          .withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF3B4860),
                      ),
                    ),
                    child: const Icon(Icons.chevron_right, size: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FavoritePokemonMiniCard extends StatelessWidget {
  final Pokemon pokemon;
  final String? nickname;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoritePokemonMiniCard({
    required this.pokemon,
    required this.nickname,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF21262D) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF38BDF8) : const Color(0xFF3B4860);
    final headerBg =
        isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9);

    return Container(
      width: 132,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cardBorder, width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x35000000),
                  offset: Offset(2, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    color: headerBg,
                    child: Row(
                      children: [
                        const PokeballWidget(size: 11),
                        const SizedBox(width: 4),
                        Text(
                          pokemon.formattedId,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? const Color(0xFFE8E088)
                                : const Color(0xFF3B4860),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pokemon.id % 2 == 0 ? '♀' : '♂',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: pokemon.id % 2 == 0
                                ? AppColors.genderFemale
                                : AppColors.genderMale,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onRemove,
                          child: const Icon(
                            Icons.favorite,
                            size: 13,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Image.network(
                          pokemon.spriteUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Image.network(
                            pokemon.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.catching_pokemon,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    color: isDark
                        ? const Color(0xFF161B22)
                        : const Color(0xFFF8FAFC),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (nickname != null && nickname!.isNotEmpty) ...[
                          Text(
                            '“$nickname”',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0284C7),
                            ),
                          ),
                          Text(
                            pokemon.retroName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF9EA8BA)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ] else ...[
                          Text(
                            pokemon.retroName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Text(
                              'HP',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Container(
                                height: 3.5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${pokemon.maxHp}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 7.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? const Color(0xFF9EA8BA)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RetroTypeBadge(
                              typeName: pokemon.primaryType,
                            ),
                            if (pokemon.secondaryType != null) ...[
                              const SizedBox(width: 3),
                              RetroTypeBadge(
                                typeName: pokemon.secondaryType!,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
