import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../constants/colors.dart';

class PropertyNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final IconData iconFallback;
  final Color? fallbackColor;

  const PropertyNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.iconFallback = Iconsax.home,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = fallbackColor ?? AppColors.primary;

    // No image — show placeholder immediately
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(color);
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl!,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        // ── Loading state ──────────────────────────────────────────────────
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child; // fully loaded
          return _buildShimmer(color);
        },
        // ── Error state (broken URL, network issue, etc.) ──────────────────
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(color);
        },
      ),
    );
  }

  Widget _buildShimmer(Color color) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ColoredBox(
        color: color.withValues(alpha: 0.08),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: color.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          iconFallback,
          size: 40,
          color: color.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
