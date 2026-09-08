import 'package:flutter/material.dart';

class FieldNotesSection extends StatelessWidget {
  const FieldNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Center(
      child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _FieldNoteCard(
                      category: 'FEATURE STORY',
                      headline: 'Built for the long way home.',
                      imageAsset: 'assets/field_notes_1.jpg',
                      isTablet: isTablet,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _FieldNoteCard(
                      category: 'FIELD NOTES',
                      headline: 'Cold drinks on trail, now available.',
                      imageAsset: 'assets/field_notes_2.jpg',
                      isTablet: isTablet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

class _FieldNoteCard extends StatelessWidget {
  final String category;
  final String headline;
  final String imageAsset;
  final bool isTablet;

  const _FieldNoteCard({
    required this.category,
    required this.headline,
    required this.imageAsset,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: isTablet ? 140 : 115,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.3 : 0.08,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background lifestyle photo
            Positioned.fill(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            // Gradient low-opacity overlay for sleek look and readable text
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            // Card Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    headline,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
