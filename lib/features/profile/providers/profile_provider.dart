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

  ProfileProvider() {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    _setLoading(true);
    _clearError();

    try {
      // Check if user is logged in
      _currentUser = await _authService.getCurrentUser();

      if (_currentUser != null) {
        // Load user's properties
        _userProperties = await _propertyService.getUserProperties();

        // Calculate total views
        _totalViews = _userProperties.fold(
          0,
          (sum, property) => sum + property.viewCount,
        );

        // Load favorites count (you'll implement this)
        _favoritesCount = await _authService.getFavoritesCount();
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
