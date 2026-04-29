import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../constants/colors.dart';
import '../../../core/models/property.dart';
import '../../../shared/widgets/property_network_image.dart';

/// A vertical property card used in search results.
class SearchPropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorited;

  const SearchPropertyCard({
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Column(children: [_buildImageSection(), _buildDetailsSection()]),
      ),
    );
  }

  // ─── Image / badge area ──────────────────────────────────────────────

  Widget _buildImageSection() {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          // ── Real image via shared widget ─────────────────────────────────
          PropertyNetworkImage(
            imageUrl: property.bestImage,
            height: 180,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            iconFallback: _propertyIcon,
            fallbackColor: property.typeColor,
          ),

          // ── Gradient overlay (only when image is present) ────────────────
          if (property.hasImages)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // ── Listing type badge (top-left) ─────────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            child: _badge(property.displayType, property.typeColor),
          ),

          // ── Verified badge (next to favourite, top-right area) ────────────
          if (property.verified)
            Positioned(
              top: 12,
              right: 56,
              child: _badge('Verified', Colors.green, icon: Iconsax.verify),
            ),

          // ── Favourite button (top-right) ──────────────────────────────────
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorited ? Iconsax.heart5 : Iconsax.heart,
                  size: 18,
                  color: isFavorited ? Colors.red : Colors.white,
                ),
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

          // ── Video badge (bottom-left) ─────────────────────────────────────
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

  // ─── Details section ─────────────────────────────────────────────────

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Iconsax.location, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  property.fullLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildFeaturesRow(),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.priceWithPeriod,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.timeAgo,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  Widget _buildFeaturesRow() {
    final hasBeds = property.bedrooms != null && property.bedrooms! > 0;
    final hasBaths = property.bathrooms != null && property.bathrooms! > 0;

    if (!hasBeds && !hasBaths) {
      return _featureChip(Iconsax.ruler, property.displayArea);
    }

    return Row(
      children: [
        if (hasBeds) _featureChip(Iconsax.home, '${property.bedrooms} Beds'),
        if (hasBeds) const SizedBox(width: 16),
        if (hasBaths) _featureChip(Iconsax.drop, '${property.bathrooms} Baths'),
        if (hasBaths) const SizedBox(width: 16),
        _featureChip(Iconsax.ruler, property.displayArea),
      ],
    );
  }

  Widget _featureChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _badge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _propertyIcon {
    switch (property.propertyType.toLowerCase()) {
      case 'land':
        return Iconsax.map;
      case 'commercial':
      case 'shop':
        return Iconsax.shop;
      case 'apartment':
        return Iconsax.building;
      default:
        return Iconsax.home_2;
    }
  }
}
