import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class PropertyTypeFilter extends StatelessWidget {
  final List<String> types;
  final int selectedIndex;
  final Function(int) onTypeSelected;

  const PropertyTypeFilter({
    super.key,
    required this.types,
    required this.selectedIndex,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: types.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                types[index],
                style: TextStyle(
                  color: selectedIndex == index
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              selected: selectedIndex == index,
              onSelected: (selected) {
                if (selected) {
                  onTypeSelected(index);
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: AppColors.greyLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}