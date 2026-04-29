import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/property.dart';
import '../../../core/services/property_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../constants/colors.dart';

class MyListingsScreen extends StatefulWidget {
  final String userId;

  const MyListingsScreen({super.key, required this.userId});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final PropertyService _propertyService = PropertyService();
  List<Property> _properties = [];
  bool _isLoading = true;
  bool _showAll = false;
  String? _errorMessage;

  static const int _initialShowCount = 5;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _properties = await _propertyService.getUserProperties();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<Property> get _displayedProperties {
    if (_showAll || _properties.length <= _initialShowCount) {
      return _properties;
    }
    return _properties.take(_initialShowCount).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
              ? Center(
                  child: CustomErrorWidget(
                    message: _errorMessage!,
                    onRetry: _loadProperties,
                  ),
                )
              : _properties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.building_3,
                              size: 64, color: AppColors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No listings yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Properties you list will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProperties,
                      color: AppColors.primary,
                      child: Column(
                        children: [
                          // Total count
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            color: AppColors.surface,
                            child: Text(
                              '${_properties.length} propert${_properties.length == 1 ? 'y' : 'ies'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount:
                                  _displayedProperties.length + 1, // +1 for button
                              itemBuilder: (context, index) {
                                if (index >= _displayedProperties.length) {
                                  return _buildShowMoreButton();
                                }
                                return _buildPropertyItem(
                                    _displayedProperties[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildPropertyItem(Property property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/property-detail',
            arguments: property.id,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Property image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: property.mainImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          property.mainImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Iconsax.building_3,
                            size: 30,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Iconsax.building_3,
                        size: 30,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(property.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            property.status,
                            style: TextStyle(
                              fontSize: 11,
                              color: _statusColor(property.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Iconsax.location,
                            size: 12, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.fullLocation,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          property.formattedPrice,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Iconsax.eye,
                                size: 14, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${property.viewCount} views',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
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
      ),
    );
  }

  Widget _buildShowMoreButton() {
    if (_properties.length <= _initialShowCount) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _showAll = !_showAll;
            });
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            _showAll ? 'Hide' : 'Show all (${_properties.length - _initialShowCount} more)',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'sold':
        return Colors.blue;
      case 'rented':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
