class ApiEndpoints {
  // Base
  static const String _base = '/api/v1';

  // Auth
  static const String register = '$_base/auth/register';
  static const String login = '$_base/auth/login';
  static const String me = '$_base/auth/me';

  // Users
  static String userById(String id) => '$_base/users/$id';

  // Properties
  static const String properties = '$_base/properties/';
  static const String createProperty = '$_base/properties/';
  static const String userProperties = '$_base/properties/user';

  static String propertyDetail(String id) => '$_base/properties/$id';
  static String updateProperty(String id) => '$_base/properties/$id';

  // Favorites
  static const String favorites = '$_base/favorites/';
  static const String favoritesCount = '$_base/favorites/count';

  static String addFavorite(String propertyId) =>
      '$_base/favorites/$propertyId';
  static String removeFavorite(String propertyId) =>
      '$_base/favorites/$propertyId';
}
