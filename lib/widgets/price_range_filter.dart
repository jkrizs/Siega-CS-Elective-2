import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/product_provider.dart';

String _dollars(double value) => '\$${value.toStringAsFixed(0)}';

class PriceRangeFilter extends StatelessWidget {
  const PriceRangeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final bounds = provider.priceBounds;
    final range = provider.priceRange;
    if (bounds == null || range == null || bounds.max <= bounds.min) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Price range',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (provider.isPriceFiltered)
                  TextButton(
                    onPressed: provider.resetPriceRange,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _PriceTag(label: 'Min', value: _dollars(range.start)),
                const Spacer(),
                _PriceTag(label: 'Max', value: _dollars(range.end)),
              ],
            ),
            RangeSlider(
              values: range,
              min: bounds.min,
              max: bounds.max,
              divisions: (bounds.max - bounds.min).round(),
              labels: RangeLabels(_dollars(range.start), _dollars(range.end)),
              onChanged: provider.updatePriceRange,
              onChangeEnd: (_) => provider.applyPriceRange(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: '$label  ',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
