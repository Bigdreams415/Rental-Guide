import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _favorites = [];
  int _total = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  static const int _pageSize = 10;

  List<Map<String, dynamic>> get favorites => _favorites;
  int get total => _total;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.getFavorites(
        skip: 0,
        limit: _pageSize,
      );
      _favorites = List<Map<String, dynamic>>.from(response['favorites'] ?? []);
      _total = (response['total'] as num?)?.toInt() ?? 0;
      _hasMore = _favorites.length < _total;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _authService.getFavorites(
        skip: _favorites.length,
        limit: _pageSize,
      );
      final newItems = List<Map<String, dynamic>>.from(response['favorites'] ?? []);
      _favorites.addAll(newItems);
      _total = (response['total'] as num?)?.toInt() ?? _total;
      _hasMore = _favorites.length < _total;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _setError(e.toString());
    }
  }

  Future<bool> removeFavorite(String propertyId) async {
    final success = await _authService.removeFavorite(propertyId);
    if (success) {
      _favorites.removeWhere((f) => f['property_id'] == propertyId);
      _total = (_total - 1).clamp(0, 999999);
      notifyListeners();
    }
    return success;
  }

  Future<void> refresh() async {
    await loadFavorites();
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
