import 'package:flutter/material.dart';
import '../../../core/models/property.dart';
import '../../../core/models/user.dart';
import '../../../core/services/user_service.dart';
import '../../home/services/property_service.dart';

class PropertyDetailProvider extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  final UserService _userService = UserService();

  Property? _property;
  User? _owner;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Property? get property => _property;
  User? get owner => _owner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load property by ID
  Future<void> loadProperty(String propertyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _property = await _propertyService.getPropertyById(propertyId);

      // Fetch owner information if property has ownerId
      if (_property?.ownerId != null) {
        _owner = await _userService.getUserById(_property!.ownerId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
