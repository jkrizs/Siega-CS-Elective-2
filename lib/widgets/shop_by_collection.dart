import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ShopByCollectionSection extends StatelessWidget {
  final VoidCallback? onCollectionTap;

  const ShopByCollectionSection({super.key, this.onCollectionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by collection',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'View all',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CollectionCard(
                  title: 'Wide Mouth',
                  bgColor: AppTheme.collectionCardBackground(context, 0),
                  badgeColor: AppColors.primaryLight,
                  imageUrl: 'assets/products/wide-mouth.jpg',
                  onTap: onCollectionTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CollectionCard(
                  title: 'Coffee',
                  bgColor: AppTheme.collectionCardBackground(context, 1),
                  badgeColor: AppColors.ratingStar,
                  imageUrl: 'assets/products/coffee.jpg',
                  onTap: onCollectionTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CollectionCard(
                  title: 'Trail Series',
                  bgColor: AppTheme.collectionCardBackground(context, 2),
                  badgeColor: theme.colorScheme.primary,
                  imageUrl: 'assets/products/straw-cap.jpg',
                  onTap: onCollectionTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final String title;
  final Color bgColor;
  final Color badgeColor;
  final String imageUrl;
  final VoidCallback? onTap;

  const _CollectionCard({
    required this.title,
    required this.bgColor,
    required this.badgeColor,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Positioned(
              top: 2,
              left: 2,
              child: CircleAvatar(radius: 4, backgroundColor: badgeColor),
            ),
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  imageUrl,
                  width: 38,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image, size: 24),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
