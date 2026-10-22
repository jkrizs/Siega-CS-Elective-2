import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'retro_decorations.dart';

class LoadingView extends StatefulWidget {
  final String message;

  const LoadingView({
    super.key,
    this.message = 'ACCESSING POKÉDEX...',
  });

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: RetroDialogueBox(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _controller,
                child: const PokeballWidget(size: 44),
              ),
              const SizedBox(height: 18),
              Text(
                widget.message,
                style: AppTextStyles.dialogueTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '▶ PLEASE WAIT...',
                style: AppTextStyles.dialogueSubtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
