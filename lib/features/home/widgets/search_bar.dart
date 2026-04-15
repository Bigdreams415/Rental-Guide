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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.greyLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search properties, locations...',
                  hintStyle: TextStyle(
                    color: AppColors.grey.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    color: AppColors.grey,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: onFilterTap,
              icon: const Icon(Iconsax.filter, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
