import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/property.dart';
import '../../../constants/colors.dart';
import '../../../shared/widgets/property_network_image.dart';

class RecentPropertyItem extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorited;

  const RecentPropertyItem({
    super.key,
    required this.property,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: Row(
          children: [
            // ── Thumbnail ────────────────────────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: PropertyNetworkImage(
                    imageUrl: property.bestImage,
                    width: 90,
                    height: 90,
                    borderRadius: BorderRadius.circular(12),
                    iconFallback: _getPropertyIcon(),
                    fallbackColor: property.typeColor,
                  ),
                ),

                // Video indicator on thumbnail
                if (property.hasVideos)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.video,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // ── Details ───────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(Iconsax.location, size: 13, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.fullLocation,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Price + listing type badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property.priceWithPeriod,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: property.typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          property.displayType,
                          style: TextStyle(
                            color: property.typeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Time ago + verified + favorite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property.timeAgo,
                        style: TextStyle(fontSize: 11, color: AppColors.grey),
                      ),
                      Row(
                        children: [
                          if (property.verified)
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.tick_circle,
                                  size: 13,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 3),
                                const Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          GestureDetector(
                            onTap: onFavoriteTap,
                            child: Icon(
                              isFavorited ? Iconsax.heart5 : Iconsax.heart,
                              size: 18,
                              color: isFavorited
                                  ? AppColors.error
                                  : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPropertyIcon() {
    switch (property.propertyType.toLowerCase()) {
      case 'land':
        return Iconsax.map;
      case 'commercial':
      case 'shop':
      case 'office':
        return Iconsax.building;
      case 'shortlet':
        return Iconsax.house;
      default:
        return Iconsax.home;
    }
  }
}
