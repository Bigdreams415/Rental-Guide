import 'package:flutter/material.dart';
import '../../../core/models/property.dart';
import '../../home/services/property_service.dart';

class PropertyDetailProvider extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();

  Property? _property;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Property? get property => _property;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load property by ID
  Future<void> loadProperty(String propertyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _property = await _propertyService.getPropertyById(propertyId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
