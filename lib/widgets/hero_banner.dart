import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback onExplorePressed;

  const HeroBanner({super.key, required this.onExplorePressed});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;
    final bannerAsset = isTablet
        ? 'assets/hero_banner_desktop.png'
        : 'assets/hero_banner_mobile.png';

    return Container(
      height: isTablet ? 420 : 360,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        image: DecorationImage(
          image: AssetImage(bannerAsset),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: const Alignment(0, 0.2),
              ),
            ),
          ),
          Positioned(
            left: isTablet ? 36 : 22,
            top: isTablet ? 48 : 32,
            child: Text(
              'New\nFresh\nColours',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 52 : 36,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: isTablet ? 36 : 22,
            bottom: 24,
            child: ElevatedButton.icon(
              style: AppButtonStyles.pillHero,
              onPressed: onExplorePressed,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Explore Collection'),
            ),
          ),
        ],
      ),
    );
  }
}
