import 'dart:convert';
import '../models/user.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/secure_storage.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  /// Returns the current user IF their token is valid.
  Future<User?> getCurrentUser() async {
    try {
      final token = await _storage.getToken();
      if (token == null) return null;

      try {
        final response = await _apiClient.get(
          ApiEndpoints.me,
          requiresAuth: true,
        );

        final user = User.fromJson(response as Map<String, dynamic>);
        await _storage.saveUser(jsonEncode(response));
        return user;
      } on ApiException catch (e) {
        if (e.statusCode == 401 || e.statusCode == 403) {
          await _storage.deleteToken();
          return null;
        }

        final userJson = await _storage.getUser();
        if (userJson != null) {
          try {
            return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
          } catch (_) {
            await _storage.deleteToken();
            return null;
          }
        }

        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Returns user stats: total_listings, total_views, favorites_count.
  Future<Map<String, int>> getUserStats() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.userStats,
        requiresAuth: true,
      );
      return {
        'total_listings': (response['total_listings'] as num?)?.toInt() ?? 0,
        'total_views': (response['total_views'] as num?)?.toInt() ?? 0,
        'favorites_count': (response['favorites_count'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      return {'total_listings': 0, 'total_views': 0, 'favorites_count': 0};
    }
  }

  /// Returns the favorites count for the current user.
  Future<int> getFavoritesCount() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.favoritesCount,
        requiresAuth: true,
      );
      return (response['count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Add a property to favorites.
  Future<bool> addFavorite(String propertyId) async {
    try {
      await _apiClient.post(
        ApiEndpoints.addFavorite(propertyId),
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a property from favorites.
  Future<bool> removeFavorite(String propertyId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.removeFavorite(propertyId),
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if a property is favorited.
  Future<bool> checkFavorite(String propertyId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.checkFavorite(propertyId),
        requiresAuth: true,
      );
      return (response['is_favorited'] as bool?) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get the full list of user's favorite properties.
  Future<Map<String, dynamic>> getFavorites({int skip = 0, int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.favorites,
        queryParams: {'skip': skip, 'limit': limit},
        requiresAuth: true,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      return {'favorites': [], 'total': 0};
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }
}
