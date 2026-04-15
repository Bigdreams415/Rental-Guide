import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/property.dart';

class SearchService {
  final ApiClient _apiClient = ApiClient();

  /// Search and filter properties using the backend API.
  ///
  /// Supports full-text search, location filters, property/listing type,
  /// price range, bedroom count, sorting, and pagination.
  Future<List<Property>> searchProperties({
    String? search,
    String? state,
    String? city,
    String? propertyType,
    String? listingType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String sortBy = 'newest',
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
        'sort_by': sortBy,
      };

      if (search != null && search.trim().length >= 2) {
        queryParams['search'] = search.trim();
      }
      if (state != null) queryParams['state'] = state;
      if (city != null) queryParams['city'] = city;
      if (propertyType != null) queryParams['property_type'] = propertyType;
      if (listingType != null) queryParams['listing_type'] = listingType;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (bedrooms != null && bedrooms > 0) queryParams['bedrooms'] = bedrooms;

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
}
