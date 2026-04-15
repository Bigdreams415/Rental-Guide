import 'package:flutter/material.dart';
import '../../../core/models/property.dart';
import '../services/property_service.dart';

class HomeProvider extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();

  // States
  List<Property> _featuredProperties = [];
  List<Property> _recentlyAdded = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedLocation = 'Benin City';

  // Getters
  List<Property> get featuredProperties => _featuredProperties;
  List<Property> get recentlyAdded => _recentlyAdded;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedLocation => _selectedLocation;

  HomeProvider() {
    loadHomeData();
  }

  // Load all home screen data
  Future<void> loadHomeData() async {
    _setLoading(true);
    _clearError();

    try {
      // Load both in parallel for better performance
      final results = await Future.wait([
        _propertyService.getFeaturedProperties(),
        _propertyService.getRecentlyAdded(),
      ]);

      _featuredProperties = results[0];
      _recentlyAdded = results[1];
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadHomeData();
  }

  // Update selected location
  void updateLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  // Filter properties by type
  Future<List<Property>> filterByType(String type) async {
    try {
      _setLoading(true);
      notifyListeners();

      String? listingType;
      String? propertyType;

      switch (type) {
        case 'For Rent':
          listingType = 'rent';
          break;
        case 'For Sale':
          listingType = 'sale';
          break;
        case 'Land':
          propertyType = 'land';
          break;
        case 'Commercial':
          propertyType = 'commercial';
          break;
        case 'Short Stay':
          listingType = 'shortlet';
          break;
        case 'All':
        default:
          // No filters
          break;
      }

      final properties = await _propertyService.getProperties(
        listingType: listingType,
        propertyType: propertyType,
      );

      _setLoading(false);
      return properties;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return [];
    }
  }

  // Search properties
  Future<List<Property>> searchProperties(String query) async {
    if (query.isEmpty) return [];

    try {
      // You can implement search endpoint later
      // For now, filter client-side or use backend search
      final properties = await _propertyService.getProperties();
      return properties.where((property) {
        return property.title.toLowerCase().contains(query.toLowerCase()) ||
            property.city.toLowerCase().contains(query.toLowerCase()) ||
            property.state.toLowerCase().contains(query.toLowerCase()) ||
            property.address.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}