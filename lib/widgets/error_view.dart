import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'retro_decorations.dart';

/// Error state widget displayed with classic RPG dialogue box styling.
class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.signal_cellular_connected_no_internet_4_bar,
                  size: 40,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'LINK ERROR!',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.errorRedDark,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '▶ $errorMessage',
                style: AppTextStyles.dialogueSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Retro GBA-style button
              GestureDetector(
                onTap: onRetry,
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
                        'A: RETRY',
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
