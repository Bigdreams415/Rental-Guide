import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/inspection_model.dart';

class InspectionService {
  final ApiClient _apiClient = ApiClient();

  Future<InspectionModel> requestInspection({
    required String propertyId,
    required DateTime requestedDate,
    String? note,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.requestInspection,
      data: {
        'property_id': propertyId,
        'requested_date': requestedDate.toIso8601String(),
        if (note != null && note.isNotEmpty) 'requester_note': note,
      },
      requiresAuth: true,
    );
    return InspectionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<InspectionModel>> getMyInspections({String? statusFilter}) async {
    final endpoint = statusFilter != null
        ? '${ApiEndpoints.myInspections}?status_filter=$statusFilter'
        : ApiEndpoints.myInspections;

    final response = await _apiClient.get(endpoint, requiresAuth: true);
    return (response as List)
        .map((e) => InspectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InspectionModel> confirmInspection(String id) async {
    final response = await _apiClient.post(
      ApiEndpoints.confirmInspection(id),
      requiresAuth: true,
    );
    return InspectionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<InspectionModel> rescheduleInspection({
    required String id,
    required DateTime newDate,
    String? note,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.rescheduleInspection(id),
      data: {
        'confirmed_date': newDate.toIso8601String(),
        if (note != null && note.isNotEmpty) 'owner_note': note,
      },
      requiresAuth: true,
    );
    return InspectionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<InspectionModel> cancelInspection(String id) async {
    final response = await _apiClient.post(
      ApiEndpoints.cancelInspection(id),
      requiresAuth: true,
    );
    return InspectionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<InspectionModel> completeInspection(String id) async {
    final response = await _apiClient.post(
      ApiEndpoints.completeInspection(id),
      requiresAuth: true,
    );
    return InspectionModel.fromJson(response as Map<String, dynamic>);
  }
}
