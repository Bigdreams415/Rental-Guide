import 'dart:convert';
import '../models/user.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/secure_storage.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _storage = SecureStorage();

  /// Returns the current user IF their token is valid.
  ///
  /// Strategy:
  ///   1. No token in storage → not logged in, return null immediately
  ///   2. Token exists → call /auth/me to validate it with the server
  ///      - Success → save fresh user data locally, return User
  ///      - 401/error → token expired or invalid, clear storage, return null
  ///
  /// This prevents the "appears logged in but all API calls fail" problem.
  Future<User?> getCurrentUser() async {
    try {
      final token = await _storage.getToken();
      if (token == null) return null;

      // Always validate token with the server — don't trust local storage alone.
      // This catches expired tokens immediately on app startup.
      try {
        final response = await _apiClient.get(
          ApiEndpoints.me,
          requiresAuth: true,
        );

        final user = User.fromJson(response as Map<String, dynamic>);

        // Refresh the locally stored user data with the latest from server
        await _storage.saveUser(jsonEncode(response));

        return user;
      } on ApiException catch (e) {
        if (e.statusCode == 401 || e.statusCode == 403) {
          // Token is expired or invalid — clear everything and force re-login
          await _storage.deleteToken();
          return null;
        }

        // Network error (no connection etc.) — fall back to locally stored
        // user so the app doesn't force logout when offline
        final userJson = await _storage.getUser();
        if (userJson != null) {
          try {
            return User.fromJson(
              jsonDecode(userJson) as Map<String, dynamic>,
            );
          } catch (_) {
            // Corrupted local data — clear it
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

  /// Returns the favorites count for the current user.
  /// Returns 0 gracefully if the endpoint isn't available or user isn't authed.
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

  Future<void> logout() async {
    await _storage.deleteToken();
  }
}