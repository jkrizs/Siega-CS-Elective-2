import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'retro_decorations.dart';

class EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyView({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: RetroDialogueBox(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PokeballWidget(size: 44),
              const SizedBox(height: 16),
              const Text(
                'BOX IS EMPTY!',
                style: AppTextStyles.dialogueTitle,
              ),
              const SizedBox(height: 10),
              const Text(
                '▶ No Pokémon registered in this Pokédex sector.',
                style: AppTextStyles.dialogueSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.dayCardHeaderBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.dayCardBorder,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.retroGold,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'A: REFRESH',
                        style: AppTextStyles.retroButton,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
