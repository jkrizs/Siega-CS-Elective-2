import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'retro_decorations.dart';

/// Retro GBA/NDS styled Pokémon Card.
///
/// Designed after the classic Pokémon FireRed / Emerald Summary Screen (Blastoise)
/// and Nintendo DS Party Screen, featuring:
/// - Crisp Pokémon photo / artwork inside a bordered display box
/// - Decorative mini Pokéball in the photo box
/// - Retro monospace typography (ID and uppercase name)
/// - Authentic HP gauge bar
/// - GBA-styled move/type badge
/// - Dynamic Day/Night mode theming
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool usePixelSprite;
  final VoidCallback? onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.usePixelSprite = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageToUse = usePixelSprite ? pokemon.spriteUrl : pokemon.imageUrl;

    final cardBg = AppColors.cardBg(isDark);
    final cardBorder = AppColors.cardBorder(isDark);
    final headerBg = AppColors.cardHeaderBg(isDark);
    final headerBorder = AppColors.cardHeaderBorder(isDark);
    final photoBoxBg = AppColors.photoBoxBg(isDark);
    final photoBoxBorder = AppColors.photoBoxBorder(isDark);
    final scanlineColor = AppColors.scanline(isDark);
    final footerBg = AppColors.cardFooterBg(isDark);
    final footerBorder = AppColors.cardFooterBorder(isDark);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: cardBorder,
              width: 2.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x38000000),
                offset: Offset(2, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Card Top Bar (Retro ID + Name + Mini Pokéball)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: headerBg,
                border: Border(
                  bottom: BorderSide(
                    color: headerBorder,
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const PokeballWidget(size: 14),
                  const SizedBox(width: 6),
                  Text(
                    pokemon.formattedId,
                    style: AppTextStyles.pokemonId,
                  ),
                  const Spacer(),
                  // Gender icon / indicator
                  Text(
                    pokemon.id % 2 == 0 ? '♀' : '♂',
                    style: pokemon.id % 2 == 0
                        ? AppTextStyles.genderFemale
                        : AppTextStyles.genderMale,
                  ),
                ],
              ),
            ),

            // 2. Photo Display Box (Inspired by the Blastoise screen in Image 1)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: photoBoxBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: photoBoxBorder,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Subtle horizontal gridlines in photo frame
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ScanlinePainter(
                          scanlineColor: scanlineColor,
                          spacing: 4.0,
                        ),
                      ),
                    ),

                    // Subtle type-colored circular glow to fill empty space
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                      ),
                    ),

                    // Pokémon Photo / Sprite
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Image.network(
                          imageToUse,
                          fit: BoxFit.contain,
                          filterQuality: usePixelSprite
                              ? FilterQuality.none
                              : FilterQuality.medium,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? const Color(0xFF38BDF8) : const Color(0xFF3B4860),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to default sprite if official artwork is unavailable
                            return Image.network(
                              pokemon.spriteUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.catching_pokemon,
                                  size: 36,
                                  color: Color(0xFF9EA8BA),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Authentic mini Pokéball in bottom-right corner (as in GBA Blastoise screen)
                    const Positioned(
                      right: 5,
                      bottom: 5,
                      child: PokeballWidget(size: 13),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Name & Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: footerBg,
                border: Border(
                  top: BorderSide(
                    color: footerBorder,
                    width: 1.2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pokémon Name
                  Text(
                    pokemon.retroName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.pokemonName(isDark),
                  ),

                  const SizedBox(height: 3),

                  // Retro HP Gauge (Inspired by Image 2 - Nintendo DS party screen)
                  Row(
                    children: [
                      const Text(
                        'HP',
                        style: AppTextStyles.hpLabel,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: AppColors.hpBarBg,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: AppColors.hpBarBorder,
                              width: 0.8,
                            ),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1.0, // Full HP
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.hpGaugeHigh, // Retro bright green HP
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pokemon.maxHp}/${pokemon.maxHp}',
                        style: AppTextStyles.hpRatio(isDark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Type Badges (Inspired by Image 1 - GBA move badges)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RetroTypeBadge(typeName: pokemon.primaryType),
                      if (pokemon.secondaryType != null) ...[
                        const SizedBox(width: 4),
                        RetroTypeBadge(typeName: pokemon.secondaryType!),
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
);
  }
}
