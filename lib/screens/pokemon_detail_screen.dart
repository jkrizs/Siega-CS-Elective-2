import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/nickname_editor_dialog.dart';
import '../widgets/retro_decorations.dart';

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.scaffoldBg(isDark);
    final scanlineColor = AppColors.scanline(isDark);

    final Pokemon? pokemon =
        ref.watch(pokemonProvider.select((s) => s.selectedPokemon));

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: SafeArea(
          child: _buildRetroAppBar(context, ref, isDark, pokemon),
        ),
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

          pokemon == null
              ? _buildNoPokemonView(context)
              : _buildPokemonDetailView(context, ref, isDark, pokemon),
        ],
      ),
    );
  }

  Widget _buildRetroAppBar(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Pokemon? pokemon,
  ) {
    final headerBg = AppColors.headerBg(isDark);
    final tabBg = AppColors.headerTabBg(isDark);
    final borderCol = AppColors.headerBorder(isDark);

    final isFav = pokemon != null
        ? ref.watch(pokemonProvider.select((s) => s.isFavorite(pokemon.id)))
        : false;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: borderCol, width: 2.5)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: Color(0xFF1E2532),
                  ),
                  SizedBox(width: 6),
                  Text('BACK', style: AppTextStyles.headerTitle),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              pokemon != null
                  ? '${pokemon.retroName} SUMMARY'
                  : 'POKÉMON DETAILS',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFE8E088) : Colors.white,
                letterSpacing: 1.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (pokemon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Tooltip(
                message: isFav ? 'Remove from Favorites' : 'Add to Favorites',
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => ref
                      .read(pokemonProvider.notifier)
                      .toggleFavorite(pokemon.id),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F1522)
                          : const Color(0xFF00587C),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFav
                            ? const Color(0xFFEF4444)
                            : (isDark
                                ? AppColors.retroGoldGlow
                                : const Color(0xFF80D8FF)),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isFav
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
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav
                          ? const Color(0xFFEF4444)
                          : (isDark
                              ? AppColors.retroGoldGlow
                              : const Color(0xFFE0F2FE)),
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

  Widget _buildPokemonDetailView(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Pokemon pokemon,
  ) {
    final photoBoxBg = AppColors.photoBoxBg(isDark);
    final photoBoxBorder = AppColors.photoBoxBorder(isDark);
    final cardBg = AppColors.cardBg(isDark);
    final cardBorder = AppColors.cardBorder(isDark);

    final isFav = ref.watch(
      pokemonProvider.select((s) => s.isFavorite(pokemon.id)),
    );
    final nickname = ref.watch(
      pokemonProvider.select((s) => s.getNickname(pokemon.id)),
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFav ? const Color(0xFFEF4444) : cardBorder,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isFav
                          ? const Color(0x3DEF4444)
                          : const Color(0x38000000),
                      offset: const Offset(3, 5),
                      blurRadius: isFav ? 6 : 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardHeaderBg(isDark),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(11),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.cardHeaderBorder(isDark),
                            width: 1.8,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const PokeballWidget(size: 16),
                          const SizedBox(width: 8),
                          Text(
                            pokemon.formattedId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFFE8E088),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => ref
                                .read(pokemonProvider.notifier)
                                .toggleFavorite(pokemon.id),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF9EA8BA),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pokemon.hashId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xFF80D8FF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pokemon.id % 2 == 0 ? '♀' : '♂',
                            style: pokemon.id % 2 == 0
                                ? AppTextStyles.genderFemale
                                : AppTextStyles.genderMale,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 240,
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: photoBoxBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: photoBoxBorder, width: 2.0),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: isDark ? 0.08 : 0.12,
                            child: const PokeballWidget(size: 180),
                          ),

                          Image.network(
                            pokemon.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2.5,
                                  color: isDark
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF3B4860),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 44,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'NO IMAGE AVAILABLE',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardFooterBg(isDark),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(11),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.cardFooterBorder(isDark),
                            width: 1.8,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (nickname != null && nickname.isNotEmpty) ...[
                            Text(
                              '“$nickname”',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                letterSpacing: 1.2,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF0284C7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'SPECIES: ${pokemon.retroName}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: isDark
                                    ? const Color(0xFF9EA8BA)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ] else ...[
                            Text(
                              pokemon.retroName,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: 1.2,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RetroTypeBadge(typeName: pokemon.primaryType),
                              if (pokemon.secondaryType != null) ...[
                                const SizedBox(width: 8),
                                RetroTypeBadge(
                                  typeName: pokemon.secondaryType!,
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    NicknameEditorDialog.show(context, pokemon),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF161B22)
                                        : const Color(0xFF3B4860),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFF1E2532),
                                      width: 1.6,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x35000000),
                                        offset: Offset(1.5, 2.5),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_note_rounded,
                                        size: 16,
                                        color: isDark
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFFE8E088),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'EDIT NICKNAME',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 0.8,
                                          color: isDark
                                              ? const Color(0xFF38BDF8)
                                              : const Color(0xFFE8E088),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              RetroDialogueBox(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'HP',
                          style: AppTextStyles.hpLabel,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.hpBarBg,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: AppColors.hpBarBorder,
                                width: 1.0,
                              ),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.hpGaugeHigh,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${pokemon.maxHp} / ${pokemon.maxHp}',
                          style: AppTextStyles.hpRatio(isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kanto Pokédex Entry #${pokemon.id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoPokemonView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: RetroDialogueBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PokeballWidget(size: 40),
              const SizedBox(height: 12),
              const Text(
                'NO POKÉMON SELECTED',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please select a Pokémon from the grid.',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4860),
                  foregroundColor: const Color(0xFFE8E088),
                ),
                child: const Text('RETURN TO POKÉDEX'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
