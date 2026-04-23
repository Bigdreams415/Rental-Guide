import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/property.dart';
import '../../../constants/colors.dart';
import '../../../shared/widgets/property_network_image.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 15, spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImageSection(), _buildDetailsSection()],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          // ── Property image (real or placeholder) ───────────────────────────
          PropertyNetworkImage(
            imageUrl: property.bestImage,
            height: 160,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            iconFallback: _getPropertyIcon(),
            fallbackColor: property.typeColor,
          ),

          // ── Dark gradient at the bottom for text legibility ────────────────
          if (property.hasImages)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // ── Listing type badge (top-left) ──────────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: property.typeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                property.displayType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ── Verified badge (top-right) ─────────────────────────────────────
          if (property.verified)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),

          // ── Image count badge (bottom-right) if multiple images ───────────
          if (property.images.length > 1)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.gallery, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${property.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Video badge (bottom-left) ──────────────────────────────────────
          if (property.hasVideos)
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.video, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

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

          if (property.bedrooms != null && property.bedrooms! > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpec(Iconsax.home, property.displayBedrooms),
                _buildSpec(Iconsax.drop, property.displayBathrooms),
                Flexible(
                  child: _buildSpec(Iconsax.ruler, property.displayArea),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.priceWithPeriod,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${property.viewCount} views',
                      style: TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                    if (property.isMultiUnit) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.deepPurple.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.layers_outlined,
                              size: 10,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              property.unitsDisplay,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpec(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
