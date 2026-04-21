import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../constants/colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final Function(String) onSubmitted;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            // Search Icon & Input
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search properties, locations...',
                  hintStyle: TextStyle(
                    color: AppColors.grey.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      Iconsax.search_normal_1,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            // Divider
            Container(
              height: 32,
              width: 1,
              color: AppColors.greyLight.withValues(alpha: 0.5),
            ),
            // Filter Button
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: onFilterTap,
                  splashColor: AppColors.primary.withValues(alpha: 0.1),
                  highlightColor: AppColors.primary.withValues(alpha: 0.05),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Iconsax.setting_4,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
