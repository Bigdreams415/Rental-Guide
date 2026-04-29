import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../providers/home_provider.dart';
import '../widgets/property_card.dart';
import '../widgets/recent_property_item.dart';
import '../widgets/search_bar.dart';
import '../widgets/property_type_filter.dart';
import '../../../constants/colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/models/property.dart';
import '../../../core/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> propertyTypes = [
    'All',
    'For Rent',
    'For Sale',
    'Land',
    'Commercial',
    'Short Stay',
  ];

  int selectedTypeIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final Set<String> _favoritedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<HomeProvider>().loadHomeData();
      await _loadFavoritesFromServer();
    });
  }

  /// Load all favorited property IDs from the backend so the UI is persistent.
  Future<void> _loadFavoritesFromServer() async {
    try {
      final response = await _authService.getFavorites(limit: 50);
      final favorites = List<Map<String, dynamic>>.from(response['favorites'] ?? []);
      if (mounted) {
        setState(() {
          _favoritedIds.clear();
          for (final f in favorites) {
            _favoritedIds.add(f['property_id']?.toString() ?? '');
          }
        });
      }
    } catch (_) {
      // Silently fail — the server might be unreachable
    }
  }

  Future<void> _toggleFavorite(Property property) async {
    final propertyId = property.id;
    final isFav = _favoritedIds.contains(propertyId);

    // Optimistic update — update UI immediately
    setState(() {
      if (isFav) {
        _favoritedIds.remove(propertyId);
      } else {
        _favoritedIds.add(propertyId);
      }
    });

    try {
      if (isFav) {
        await _authService.removeFavorite(propertyId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Removed from favorites'),
              backgroundColor: AppColors.grey,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        await _authService.addFavorite(propertyId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Iconsax.heart, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Added to favorites'),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (_) {
      // Revert optimistic update on failure
      setState(() {
        if (isFav) {
          _favoritedIds.add(propertyId);
        } else {
          _favoritedIds.remove(propertyId);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().refreshData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),

                // Search Bar
                HomeSearchBar(
                  controller: _searchController,
                  onFilterTap: _navigateToSearch,
                  onSubmitted: (query) => _performSearch(query),
                ),

                // Property Types Filter
                PropertyTypeFilter(
                  types: propertyTypes,
                  selectedIndex: selectedTypeIndex,
                  onTypeSelected: _onTypeSelected,
                ),

                // Main Content
                Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading &&
                        provider.featuredProperties.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: LoadingIndicator(),
                        ),
                      );
                    }

                    if (provider.errorMessage != null &&
                        provider.featuredProperties.isEmpty) {
                      return CustomErrorWidget(
                        message: provider.errorMessage!,
                        onRetry: () => provider.loadHomeData(),
                      );
                    }

                    return Column(
                      children: [
                        // Featured Properties
                        _buildFeaturedProperties(provider.featuredProperties),

                        // Recently Added
                        _buildRecentlyAdded(provider.recentlyAdded),

                        // Location Based Recommendations
                        _buildLocationRecommendations(),

                        // Benefits Section
                        const BenefitsSection(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back 👋',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find Your Dream Property',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _navigateToNotifications,
                  icon: const Icon(Iconsax.notification),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<HomeProvider>(
            builder: (context, provider, child) {
              return GestureDetector(
                onTap: _showLocationPicker,
                child: Row(
                  children: [
                    Icon(Iconsax.location, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      provider.selectedLocation,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Iconsax.arrow_down_1,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProperties(List<Property> properties) {
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🌟 Featured Properties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _navigateToAllFeatured,
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: properties.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < properties.length - 1 ? 16 : 0,
                  ),
                  child: PropertyCard(
                    property: properties[index],
                    onTap: () =>
                        _navigateToPropertyDetail(properties[index].id),
                    onFavoriteTap: () =>
                        _toggleFavorite(properties[index]),
                    isFavorited:
                        _favoritedIds.contains(properties[index].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyAdded(List<Property> properties) {
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🕐 Recently Added',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _navigateToAllRecent,
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: properties
                .map(
                  (property) => RecentPropertyItem(
                    property: property,
                    onTap: () => _navigateToPropertyDetail(property.id),
                    onFavoriteTap: () => _toggleFavorite(property),
                    isFavorited: _favoritedIds.contains(property.id),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRecommendations() {
    List<String> popularLocations = [
      'Lagos',
      'Abuja',
      'Port Harcourt',
      'Benin City',
      'Kano',
      'Ibadan',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 Popular Locations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: popularLocations.map((location) {
              return GestureDetector(
                onTap: () => _searchByLocation(location),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.greyLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        location,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _onTypeSelected(int index) {
    setState(() {
      selectedTypeIndex = index;
    });

    if (index == 0) {
      // All - refresh with no filters
      context.read<HomeProvider>().loadHomeData();
    } else {
      // Filter by selected type
      context.read<HomeProvider>().filterByType(propertyTypes[index]);
    }
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      Navigator.pushNamed(context, '/search', arguments: {'query': query});
    }
  }

  void _searchByLocation(String location) {
    context.read<HomeProvider>().updateLocation(location);
    Navigator.pushNamed(context, '/search', arguments: {'location': location});
  }

  void _showLocationPicker() {
    // Show bottom sheet with location picker
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildLocationPickerSheet();
      },
    );
  }

  Widget _buildLocationPickerSheet() {
    List<String> nigerianStates = [
      'Lagos',
      'Abuja (FCT)',
      'Rivers',
      'Edo',
      'Kano',
      'Oyo',
      'Anambra',
      'Enugu',
      'Delta',
      'Kaduna',
      'Abia',
      'Imo',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Location',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: nigerianStates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Iconsax.location),
                  title: Text(nigerianStates[index]),
                  onTap: () {
                    context.read<HomeProvider>().updateLocation(
                      nigerianStates[index],
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, '/search');
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  void _navigateToAllFeatured() {
    Navigator.pushNamed(context, '/search', arguments: {'filter': 'featured'});
  }

  void _navigateToAllRecent() {
    Navigator.pushNamed(context, '/search', arguments: {'filter': 'recent'});
  }

  void _navigateToPropertyDetail(String propertyId) {
    Navigator.pushNamed(context, '/property-detail', arguments: propertyId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Benefits Section remains mostly the same
class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🚀 Why Choose Rental Guide?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            '👥 No Agents',
            'Connect directly with property owners, save on agent fees',
          ),
          _buildBenefitItem(
            '💵 Transparent Pricing',
            'No hidden charges, see actual property prices',
          ),
          _buildBenefitItem(
            '✅ Verified Listings',
            'All properties are verified for authenticity',
          ),
          _buildBenefitItem(
            '📱 Easy Process',
            'From search to deal closure, all in one app',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/post-property');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Post Your Property for Free',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                title.substring(0, 2),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
