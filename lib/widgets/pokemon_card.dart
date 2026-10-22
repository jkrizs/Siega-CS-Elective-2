import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'nickname_editor_dialog.dart';
import 'retro_decorations.dart';

class PokemonCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageToUse = usePixelSprite ? pokemon.spriteUrl : pokemon.imageUrl;

    final isFav = ref.watch(
      pokemonProvider.select((s) => s.isFavorite(pokemon.id)),
    );
    final nickname = ref.watch(
      pokemonProvider.select((s) => s.getNickname(pokemon.id)),
    );

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
              color: isFav ? const Color(0xFFEF4444) : cardBorder,
              width: isFav ? 2.4 : 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isFav
                    ? const Color(0x3DEF4444)
                    : const Color(0x38000000),
                offset: const Offset(2, 3),
                blurRadius: isFav ? 4 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      const PokeballWidget(size: 13),
                      const SizedBox(width: 5),
                      Text(
                        pokemon.formattedId,
                        style: AppTextStyles.pokemonId,
                      ),
                      const Spacer(),
                      Text(
                        pokemon.id % 2 == 0 ? '♀' : '♂',
                        style: pokemon.id % 2 == 0
                            ? AppTextStyles.genderFemale
                            : AppTextStyles.genderMale,
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          ref
                              .read(pokemonProvider.notifier)
                              .toggleFavorite(pokemon.id);
                        },
                        child: AnimatedScale(
                          scale: isFav ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 17,
                            color: isFav
                                ? const Color(0xFFEF4444)
                                : (isDark
                                    ? const Color(0xFF9EA8BA)
                                    : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(5),
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
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ScanlinePainter(
                              scanlineColor: scanlineColor,
                              spacing: 4.0,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Image.network(
                              imageToUse,
                              fit: BoxFit.contain,
                              filterQuality: usePixelSprite
                                  ? FilterQuality.none
                                  : FilterQuality.medium,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        isDark
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFF3B4860),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  pokemon.spriteUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) {
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
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              NicknameEditorDialog.show(context, pokemon);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFF0D1117)
                                        : Colors.white)
                                    .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF30363D)
                                      : const Color(0xFFCBD5E1),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.edit_note,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF3B4860),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          right: 4,
                          bottom: 4,
                          child: PokeballWidget(size: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                      if (nickname != null && nickname.isNotEmpty) ...[
                        Text(
                          '“$nickname”',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
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
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
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
                          style: AppTextStyles.pokemonName(isDark),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text(
                            'HP',
                            style: AppTextStyles.hpLabel,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 4.0,
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
                                widthFactor: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.hpGaugeHigh,
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
                      const SizedBox(height: 3),
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
