import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/retro_decorations.dart';

/// Individual Pokémon Detail Page.
///
/// Complies with:
/// 8. All UI values must come from APP STATE (not ephemeral).
/// 9. Page contents (name, image, and ID) come directly from the Provider.
class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.scaffoldBg(isDark);
    final scanlineColor = AppColors.scanline(isDark);

    // Data sourced from App State via Provider
    final pokemonProvider = Provider.of<PokemonProvider>(context);
    final Pokemon? pokemon = pokemonProvider.selectedPokemon;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: SafeArea(
          child: _buildRetroAppBar(context, isDark, pokemon),
        ),
      ),
      body: Stack(
        children: [
          // CRT / GBA Scanline overlay
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinePainter(
                scanlineColor: scanlineColor,
                spacing: 3.0,
              ),
            ),
          ),

          // Main Detail Contents
          pokemon == null
              ? _buildNoPokemonView(context)
              : _buildPokemonDetailView(context, isDark, pokemon),
        ],
      ),
    );
  }

  Widget _buildRetroAppBar(
    BuildContext context,
    bool isDark,
    Pokemon? pokemon,
  ) {
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
          // Back button styled as retro GBA tab
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

          // Title
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

          // Theme toggle button
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
    bool isDark,
    Pokemon pokemon,
  ) {
    final photoBoxBg = AppColors.photoBoxBg(isDark);
    final photoBoxBorder = AppColors.photoBoxBorder(isDark);
    final cardBg = AppColors.cardBg(isDark);
    final cardBorder = AppColors.cardBorder(isDark);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Pokémon Card (ID, Image, Name, Type)
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x38000000),
                      offset: Offset(3, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar with ID & Gender
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

                    // Pokémon Image Display Box
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
                          // Subtle Watermark Pokéball
                          Opacity(
                            opacity: isDark ? 0.08 : 0.12,
                            child: const PokeballWidget(size: 180),
                          ),

                          // Official Artwork Image
                          Image.network(
                            pokemon.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
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

                    // Pokémon Name & Type Badges Section
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
                          Text(
                            pokemon.displayName,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: 1.2,
                            ),
                          ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Clean Stats Dialogue Box (HP Gauge Bar & Summary)
              RetroDialogueBox(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // HP Gauge Row
                    Row(
                      children: [
                        Text(
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
                    // Clean Subtitle
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
