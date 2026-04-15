import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/property.dart';

class PropertyService {
  final ApiClient _apiClient = ApiClient();

  // Get all properties with filters
  Future<List<Property>> getProperties({
    String? state,
    String? city,
    String? propertyType,
    String? listingType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };

      if (state != null) queryParams['state'] = state;
      if (city != null) queryParams['city'] = city;
      if (propertyType != null) queryParams['property_type'] = propertyType;
      if (listingType != null) queryParams['listing_type'] = listingType;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (bedrooms != null) queryParams['bedrooms'] = bedrooms;

      final response = await _apiClient.get(
        ApiEndpoints.properties,
        queryParams: queryParams,
      );

      if (response is List) {
        return response.map((json) => Property.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Get single property by ID
  Future<Property> getPropertyById(String id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.propertyDetail(id),
      );

      return Property.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get featured properties (can be custom logic)
  Future<List<Property>> getFeaturedProperties() async {
    try {
      final properties = await getProperties(limit: 5);
      // You can add custom logic for featured properties
      // For now, we'll return the first 5 or mark some as featured in backend
      return properties.take(5).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get recently added properties
  Future<List<Property>> getRecentlyAdded() async {
    try {
      final properties = await getProperties(limit: 10);
      // Already sorted by created_at desc from backend
      return properties.take(3).toList();
    } catch (e) {
      rethrow;
    }
  }
}