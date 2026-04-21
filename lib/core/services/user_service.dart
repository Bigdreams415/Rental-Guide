import '../models/user.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.userById(userId),
        requiresAuth: true,
      );

      if (response is Map<String, dynamic>) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}