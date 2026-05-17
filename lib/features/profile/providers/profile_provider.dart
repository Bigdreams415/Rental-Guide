import 'package:flutter/material.dart';
import '../../../core/models/property.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/property_service.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final PropertyService _propertyService = PropertyService();

  User? _currentUser;
  List<Property> _userProperties = [];
  int _totalViews = 0;
  int _favoritesCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  List<Property> get userProperties => _userProperties;
  int get totalViews => _totalViews;
  int get favoritesCount => _favoritesCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get needsProfileCompletion =>
      _currentUser != null && !_currentUser!.isProfileComplete;

  ProfileProvider() {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.getCurrentUser();

      if (_currentUser != null) {
        // Load user's properties
        _userProperties = await _propertyService.getUserProperties();

        // Get accurate stats from the server
        final stats = await _authService.getUserStats();
        _totalViews = stats['total_views'] ?? 0;
        _favoritesCount = stats['favorites_count'] ?? 0;
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  Future<void> refreshProfile() async {
    await loadProfileData();
  }

  /// Reload just the favorites count (called when returning from favorites screen).
  Future<void> refreshFavoritesCount() async {
    try {
      _favoritesCount = await _authService.getFavoritesCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _userProperties = [];
    _totalViews = 0;
    _favoritesCount = 0;
    notifyListeners();
  }

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
