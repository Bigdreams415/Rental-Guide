import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/property.dart';
import '../services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  // --- State ---
  List<Property> _properties = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;

  // Search & filter state
  String _searchQuery = '';
  String? _selectedState;
  String? _selectedCity;
  String? _selectedPropertyType;
  String? _selectedListingType;
  double? _minPrice;
  double? _maxPrice;
  int? _selectedBedrooms;
  String _sortBy = 'newest';

  // Debounce timer for search input
  Timer? _debounceTimer;

  SearchProvider() {
    // Perform an initial search to load all properties by default
    _executeSearch(reset: true);
  }

  // --- Getters ---
  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String? get selectedState => _selectedState;
  String? get selectedCity => _selectedCity;
  String? get selectedPropertyType => _selectedPropertyType;
  String? get selectedListingType => _selectedListingType;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  int? get selectedBedrooms => _selectedBedrooms;
  String get sortBy => _sortBy;
  bool get hasActiveFilters =>
      _selectedState != null ||
      _selectedCity != null ||
      _selectedPropertyType != null ||
      _selectedListingType != null ||
      _minPrice != null ||
      _maxPrice != null ||
      _selectedBedrooms != null;
  int get activeFilterCount {
    int count = 0;
    if (_selectedState != null) count++;
    if (_selectedCity != null) count++;
    if (_selectedPropertyType != null) count++;
    if (_selectedListingType != null) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_selectedBedrooms != null) count++;
    return count;
  }

  // --- Actions ---

  /// Called on every keystroke; debounces 400ms then triggers search.
  void onSearchChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _executeSearch(reset: true);
    });
  }

  /// Trigger search immediately (e.g. pressing the search button).
  Future<void> search() async {
    _debounceTimer?.cancel();
    await _executeSearch(reset: true);
  }

  /// Load next page of results (infinite scroll).
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final results = await _searchService.searchProperties(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        state: _selectedState,
        city: _selectedCity,
        propertyType: _selectedPropertyType,
        listingType: _selectedListingType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        bedrooms: _selectedBedrooms,
        sortBy: _sortBy,
        skip: (_currentPage + 1) * _pageSize,
        limit: _pageSize,
      );

      _currentPage++;
      _properties.addAll(results);
      _hasMore = results.length >= _pageSize;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // --- Filter setters ---

  void setPropertyType(String? type) {
    _selectedPropertyType = type;
    _executeSearch(reset: true);
  }

  void setListingType(String? type) {
    _selectedListingType = type;
    _executeSearch(reset: true);
  }

  void setState(String? state) {
    _selectedState = state;
    _selectedCity = null; // reset city when state changes
    _executeSearch(reset: true);
  }

  void setCity(String? city) {
    _selectedCity = city;
    _executeSearch(reset: true);
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _executeSearch(reset: true);
  }

  void setBedrooms(int? bedrooms) {
    _selectedBedrooms = bedrooms;
    _executeSearch(reset: true);
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _executeSearch(reset: true);
  }

  void clearFilters() {
    _selectedState = null;
    _selectedCity = null;
    _selectedPropertyType = null;
    _selectedListingType = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedBedrooms = null;
    _sortBy = 'newest';
    _executeSearch(reset: true);
  }

  void clearAll() {
    _searchQuery = '';
    _selectedState = null;
    _selectedCity = null;
    _selectedPropertyType = null;
    _selectedListingType = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedBedrooms = null;
    _sortBy = 'newest';
    _executeSearch(reset: true);
  }

  // --- Internal ---

  Future<void> _executeSearch({bool reset = false}) async {
    if (reset) {
      _currentPage = 0;
      _properties = [];
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _searchService.searchProperties(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        state: _selectedState,
        city: _selectedCity,
        propertyType: _selectedPropertyType,
        listingType: _selectedListingType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        bedrooms: _selectedBedrooms,
        sortBy: _searchQuery.isNotEmpty ? 'relevance' : _sortBy,
        skip: 0,
        limit: _pageSize,
      );

      _properties = results;
      _hasMore = results.length >= _pageSize;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load properties. Please try again.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
