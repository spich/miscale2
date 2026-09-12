import 'package:flutter/material.dart';

import '../core/body/body_rating.dart';

/// Boja ocjene. Dobre vrijednosti prate boju teme, odstupanja idu u jantar,
/// a ono što traži pozornost u boju greške.
Color ratingColor(RatingQuality quality, ThemeData theme) => switch (quality) {
      RatingQuality.good => theme.colorScheme.primary,
      RatingQuality.low => const Color(0xFF4A9BD1),
      RatingQuality.caution => const Color(0xFFE0921F),
      RatingQuality.bad => theme.colorScheme.error,
    };

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.rating,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final MetricRating? rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = this.rating;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: theme.textTheme.titleLarge),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (rating != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rating.label,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ratingColor(rating.quality, theme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (rating != null) ...[
              const SizedBox(height: 8),
              RatingBar(rating: rating),
            ],
          ],
        ),
      ),
    );
  }
}

/// Traka raspona: svaki raspon jednako širok, s oznakom gdje vrijednost pada.
/// Ne prikazuje mjerilo nego pripadnost rasponu, kao u Mi Fitu.
class RatingBar extends StatelessWidget {
  const RatingBar({super.key, required this.rating, this.height = 6});

  final MetricRating rating;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeIndex = rating.bandIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final markerSize = height + 6;
        final width = constraints.maxWidth;

        return SizedBox(
          height: markerSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: SizedBox(
                  height: height,
                  child: Row(
                    children: [
                      for (var i = 0; i < rating.labels.length; i++)
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i == rating.labels.length - 1 ? 0 : 1.5),
                            color: ratingColor(rating.qualities[i], theme)
                                .withValues(alpha: i == activeIndex ? 1 : 0.22),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: (rating.position * width - markerSize / 2)
                    .clamp(0.0, width - markerSize),
                child: Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ratingColor(rating.quality, theme),
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mreža pločica s izvedenim vrijednostima; koristi se i nakon vaganja i u
/// detaljima mjerenja iz povijesti.
class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.tiles});

  final List<MetricTile> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: tiles,
    );
  }
}
