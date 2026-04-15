import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../providers/search_provider.dart';
import '../widgets/search_property_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  static const List<Map<String, String>> propertyTypes = [
    {'label': 'All', 'value': ''},
    {'label': 'Apartment', 'value': 'apartment'},
    {'label': 'House', 'value': 'house'},
    {'label': 'Duplex', 'value': 'duplex'},
    {'label': 'Land', 'value': 'land'},
    {'label': 'Commercial', 'value': 'commercial'},
    {'label': 'Shop', 'value': 'shop'},
  ];

  static const List<Map<String, String>> listingTypes = [
    {'label': 'All', 'value': ''},
    {'label': 'For Sale', 'value': 'sale'},
    {'label': 'For Rent', 'value': 'rent'},
    {'label': 'Short Stay', 'value': 'shortlet'},
    {'label': 'Lease', 'value': 'lease'},
  ];

  static const List<Map<String, dynamic>> priceRanges = [
    {'label': 'Any', 'min': null, 'max': null},
    {'label': 'Under \u20a65M', 'min': null, 'max': 5000000.0},
    {'label': '\u20a65M \u2013 \u20a610M', 'min': 5000000.0, 'max': 10000000.0},
    {'label': '\u20a610M \u2013 \u20a620M', 'min': 10000000.0, 'max': 20000000.0},
    {'label': '\u20a620M \u2013 \u20a650M', 'min': 20000000.0, 'max': 50000000.0},
    {'label': 'Above \u20a650M', 'min': 50000000.0, 'max': null},
  ];

  static const List<Map<String, dynamic>> bedroomOptions = [
    {'label': 'Any', 'value': null},
    {'label': '1+', 'value': 1},
    {'label': '2+', 'value': 2},
    {'label': '3+', 'value': 3},
    {'label': '4+', 'value': 4},
    {'label': '5+', 'value': 5},
  ];

  static const List<Map<String, String>> sortOptions = [
    {'label': 'Newest', 'value': 'newest'},
    {'label': 'Oldest', 'value': 'oldest'},
    {'label': 'Price: Low to High', 'value': 'price_low'},
    {'label': 'Price: High to Low', 'value': 'price_high'},
    {'label': 'Most Viewed', 'value': 'most_viewed'},
    {'label': 'Relevance', 'value': 'relevance'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Search Properties',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Consumer<SearchProvider>(
                builder: (_, provider, __) {
                  if (!provider.hasActiveFilters) return const SizedBox();
                  return TextButton.icon(
                    onPressed: () => provider.clearAll(),
                    icon: const Icon(Iconsax.close_circle, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.greyLight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Consumer<SearchProvider>(
                    builder: (_, provider, __) {
                      return TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Location, property name...',
                          hintStyle: TextStyle(
                            color: AppColors.grey.withValues(alpha: 0.6),
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Iconsax.search_normal,
                            color: AppColors.grey,
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Iconsax.close_circle,
                                    color: AppColors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.clearAll();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          provider.onSearchChanged(value);
                        },
                        onSubmitted: (_) => provider.search(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  _searchFocusNode.unfocus();
                  context.read<SearchProvider>().search();
                },
                child: Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Iconsax.search_normal,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: Consumer<SearchProvider>(
        builder: (_, provider, __) {
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _chipButton(
                label: provider.selectedPropertyType != null
                    ? _propertyTypeLabel(provider.selectedPropertyType!)
                    : 'Property Type',
                icon: Iconsax.home,
                active: provider.selectedPropertyType != null,
                onTap: () => _showPropertyTypeSheet(provider),
              ),
              const SizedBox(width: 10),
              _chipButton(
                label: provider.selectedListingType != null
                    ? _listingTypeLabel(provider.selectedListingType!)
                    : 'Listing Type',
                icon: Iconsax.tag,
                active: provider.selectedListingType != null,
                onTap: () => _showListingTypeSheet(provider),
              ),
              const SizedBox(width: 10),
              _chipButton(
                label: (provider.minPrice != null || provider.maxPrice != null)
                    ? _priceRangeLabel(provider.minPrice, provider.maxPrice)
                    : 'Price Range',
                icon: Iconsax.wallet,
                active: provider.minPrice != null || provider.maxPrice != null,
                onTap: () => _showPriceRangeSheet(provider),
              ),
              const SizedBox(width: 10),
              _chipButton(
                label: provider.selectedBedrooms != null
                    ? '${provider.selectedBedrooms}+ Beds'
                    : 'Bedrooms',
                icon: Iconsax.home_hashtag,
                active: provider.selectedBedrooms != null,
                onTap: () => _showBedroomsSheet(provider),
              ),
              const SizedBox(width: 10),
              _chipButton(
                label: 'Sort',
                icon: Iconsax.sort,
                active: provider.sortBy != 'newest',
                onTap: () => _showSortSheet(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chipButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: active
                ? AppColors.primary
                : AppColors.greyLight.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<SearchProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading && provider.properties.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.errorMessage != null && provider.properties.isEmpty) {
          return _buildError(provider);
        }

        if (provider.properties.isEmpty &&
            provider.searchQuery.isEmpty &&
            !provider.hasActiveFilters) {
          return _buildEmptyState();
        }

        if (provider.properties.isEmpty && !provider.isLoading) {
          return _buildNoResults();
        }

        return _buildResults(provider);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.search_normal,
            size: 80,
            color: AppColors.greyLight.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 20),
          const Text(
            'Find Your Dream Property',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Search by location, property name, or use filters to narrow down results.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _quickSuggestion('Benin City'),
              _quickSuggestion('Lagos'),
              _quickSuggestion('Abuja'),
              _quickSuggestion('Duplex'),
              _quickSuggestion('Land'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickSuggestion(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        setState(() {});
        context.read<SearchProvider>().onSearchChanged(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.search_status,
            size: 70,
            color: AppColors.greyLight.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'No properties found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Try adjusting your search or filters to find what you are looking for.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Consumer<SearchProvider>(
            builder: (_, provider, __) {
              if (!provider.hasActiveFilters) return const SizedBox();
              return TextButton.icon(
                onPressed: () => provider.clearFilters(),
                icon: const Icon(Iconsax.filter_remove, size: 18),
                label: const Text('Clear Filters'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildError(SearchProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.warning_2, size: 60, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.search(),
            icon: const Icon(Iconsax.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Text(
                '${provider.properties.length}${provider.hasMore ? '+' : ''} Properties Found',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showSortSheet(provider),
                child: Row(
                  children: [
                    const Icon(Iconsax.sort, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _sortLabel(provider.sortBy),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount:
                provider.properties.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.properties.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              }

              final property = provider.properties[index];
              return SearchPropertyCard(
                property: property,
                onTap: () => _navigateToDetail(property.id),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToDetail(String propertyId) {
    Navigator.pushNamed(
      context,
      '/property-detail',
      arguments: propertyId,
    );
  }

  void _showPropertyTypeSheet(SearchProvider provider) {
    _showSelectionSheet(
      title: 'Property Type',
      items: propertyTypes.map((e) => e['label']!).toList(),
      selected: provider.selectedPropertyType != null
          ? _propertyTypeLabel(provider.selectedPropertyType!)
          : 'All',
      onSelected: (label) {
        final match = propertyTypes.firstWhere((e) => e['label'] == label);
        provider.setPropertyType(
            match['value']!.isEmpty ? null : match['value']);
      },
    );
  }

  void _showListingTypeSheet(SearchProvider provider) {
    _showSelectionSheet(
      title: 'Listing Type',
      items: listingTypes.map((e) => e['label']!).toList(),
      selected: provider.selectedListingType != null
          ? _listingTypeLabel(provider.selectedListingType!)
          : 'All',
      onSelected: (label) {
        final match = listingTypes.firstWhere((e) => e['label'] == label);
        provider.setListingType(
            match['value']!.isEmpty ? null : match['value']);
      },
    );
  }

  void _showPriceRangeSheet(SearchProvider provider) {
    _showSelectionSheet(
      title: 'Price Range',
      items: priceRanges.map((e) => e['label'] as String).toList(),
      selected: (provider.minPrice != null || provider.maxPrice != null)
          ? _priceRangeLabel(provider.minPrice, provider.maxPrice)
          : 'Any',
      onSelected: (label) {
        final match = priceRanges.firstWhere((e) => e['label'] == label);
        provider.setPriceRange(
          match['min'] as double?,
          match['max'] as double?,
        );
      },
    );
  }

  void _showBedroomsSheet(SearchProvider provider) {
    _showSelectionSheet(
      title: 'Minimum Bedrooms',
      items: bedroomOptions.map((e) => e['label'] as String).toList(),
      selected: provider.selectedBedrooms != null
          ? '${provider.selectedBedrooms}+'
          : 'Any',
      onSelected: (label) {
        final match = bedroomOptions.firstWhere((e) => e['label'] == label);
        provider.setBedrooms(match['value'] as int?);
      },
    );
  }

  void _showSortSheet(SearchProvider provider) {
    _showSelectionSheet(
      title: 'Sort By',
      items: sortOptions.map((e) => e['label']!).toList(),
      selected: _sortLabel(provider.sortBy),
      onSelected: (label) {
        final match = sortOptions.firstWhere((e) => e['label'] == label);
        provider.setSortBy(match['value']!);
      },
    );
  }

  void _showSelectionSheet({
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              final isSelected = item == selected;
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : null,
                title: Text(
                  item,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Iconsax.tick_circle,
                        color: AppColors.primary, size: 22)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onSelected(item);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _propertyTypeLabel(String value) {
    return propertyTypes
            .firstWhere(
              (e) => e['value'] == value,
              orElse: () => {'label': value},
            )['label'] ??
        value;
  }

  String _listingTypeLabel(String value) {
    return listingTypes
            .firstWhere(
              (e) => e['value'] == value,
              orElse: () => {'label': value},
            )['label'] ??
        value;
  }

  String _priceRangeLabel(double? min, double? max) {
    for (final range in priceRanges) {
      if (range['min'] == min && range['max'] == max) {
        return range['label'] as String;
      }
    }
    return 'Custom';
  }

  String _sortLabel(String value) {
    return sortOptions
            .firstWhere(
              (e) => e['value'] == value,
              orElse: () => {'label': value},
            )['label'] ??
        value;
  }
}
