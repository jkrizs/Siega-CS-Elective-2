import 'package:flutter/material.dart';

class TrustBar extends StatelessWidget {
  const TrustBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.cardTheme.color?.withValues(alpha: 0.7) ??
          theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _TrustItem(
              icon: Icons.local_shipping_outlined,
              title: 'Free Shipping',
            ),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.shield_outlined,
              title: 'Built to Last',
            ),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.water_drop_outlined,
              title: 'Leakproof Design',
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _TrustItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
