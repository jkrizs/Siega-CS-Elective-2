import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ScanlinePainter extends CustomPainter {
  final Color scanlineColor;
  final double spacing;

  const ScanlinePainter({
    this.scanlineColor = AppColors.dayScanline,
    this.spacing = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scanlineColor
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ScanlinePainter oldDelegate) {
    return oldDelegate.scanlineColor != scanlineColor || oldDelegate.spacing != spacing;
  }
}

class PokeballWidget extends StatelessWidget {
  final double size;
  final bool isOpened;

  const PokeballWidget({
    super.key,
    this.size = 20,
    this.isOpened = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PokeballPainter(),
      ),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final redPaint = Paint()
      ..color = AppColors.pokeballRed
      ..style = PaintingStyle.fill;
    canvas.drawArc(rect, 3.14159, 3.14159, true, redPaint);

    final whitePaint = Paint()
      ..color = AppColors.pokeballWhite
      ..style = PaintingStyle.fill;
    canvas.drawArc(rect, 0, 3.14159, true, whitePaint);

    final borderPaint = Paint()
      ..color = AppColors.pokeballBand
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;
    canvas.drawCircle(center, radius - (borderPaint.strokeWidth / 2), borderPaint);

    final bandPaint = Paint()
      ..color = AppColors.pokeballBand
      ..style = PaintingStyle.fill;
    final bandHeight = size.height * 0.14;
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: size.width,
        height: bandHeight,
      ),
      bandPaint,
    );

    final buttonOuterPaint = Paint()
      ..color = AppColors.pokeballBand
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.34, buttonOuterPaint);

    final buttonInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.22, buttonInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RetroTypeBadge extends StatelessWidget {
  final String typeName;

  const RetroTypeBadge({
    super.key,
    required this.typeName,
  });

  @override
  Widget build(BuildContext context) {
    final color = PokemonTypeColors.getColor(typeName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.pokeballBand,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        typeName.toUpperCase(),
        style: AppTextStyles.typeBadge,
      ),
    );
  }
}

class RetroDialogueBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RetroDialogueBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final outerBg = AppColors.dialogueOuterBg(isDark);
    final outerBorder = AppColors.dialogueOuterBorder(isDark);
    final innerBg = AppColors.dialogueInnerBg(isDark);
    final innerBorder = AppColors.dialogueInnerBorder(isDark);

    return Container(
      decoration: BoxDecoration(
        color: outerBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: outerBorder,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            offset: Offset(0, 3),
            blurRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: padding,
        decoration: BoxDecoration(
          color: innerBg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: innerBorder,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8890A0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8890A0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
