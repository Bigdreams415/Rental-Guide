class ApiEndpoints {
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

  // User Stats
  static const String userStats = '$_base/auth/me/stats';

  // Favorites
  static const String favorites = '$_base/favorites/';
  static const String favoritesCount = '$_base/favorites/count';
  static String addFavorite(String propertyId) =>
      '$_base/favorites/$propertyId';
  static String removeFavorite(String propertyId) =>
      '$_base/favorites/$propertyId';
  static String checkFavorite(String propertyId) =>
      '$_base/favorites/check/$propertyId';

  // Inspections
  static const String requestInspection = '$_base/inspections/';
  static const String myInspections = '$_base/inspections/mine';
  static String confirmInspection(String id) =>
      '$_base/inspections/$id/confirm';
  static String rescheduleInspection(String id) =>
      '$_base/inspections/$id/reschedule';
  static String cancelInspection(String id) => '$_base/inspections/$id/cancel';
  static String completeInspection(String id) =>
      '$_base/inspections/$id/complete';
}
