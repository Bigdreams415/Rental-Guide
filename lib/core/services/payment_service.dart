import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/transaction_model.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  Future<TransactionModel> initiatePayment(String propertyId) async {
    final response = await _apiClient.post(
      ApiEndpoints.initiatePayment,
      data: {'property_id': propertyId},
      requiresAuth: true,
    );
    return TransactionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<TransactionModel> verifyPayment(String reference) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyPayment(reference),
      requiresAuth: true,
    );
    return TransactionModel.fromJson(response as Map<String, dynamic>);
  }

  Future<List<TransactionModel>> getMyTransactions() async {
    final response = await _apiClient.get(
      ApiEndpoints.myTransactions,
      requiresAuth: true,
    );
    return (response as List)
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}