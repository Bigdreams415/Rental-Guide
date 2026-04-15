import '../models/property.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class PropertyService {
  final ApiClient _apiClient = ApiClient();

  /// Returns properties that belong to the currently logged-in user.
  Future<List<Property>> getUserProperties() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.userProperties,
        requiresAuth: true,
      );

      if (response is List) {
        return response
            .map((json) => Property.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}