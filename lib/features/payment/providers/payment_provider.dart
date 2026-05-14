import 'package:flutter/material.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  List<TransactionModel> _transactions = [];
  TransactionModel? _currentTransaction;
  bool _isLoading = false;
  bool _isInitiating = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  TransactionModel? get currentTransaction => _currentTransaction;
  bool get isLoading => _isLoading;
  bool get isInitiating => _isInitiating;
  String? get errorMessage => _errorMessage;

  Future<TransactionModel?> initiatePayment(String propertyId) async {
    _isInitiating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transaction = await _service.initiatePayment(propertyId);
      _currentTransaction = transaction;
      return transaction;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isInitiating = false;
      notifyListeners();
    }
  }

  Future<TransactionModel?> verifyPayment(String reference) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transaction = await _service.verifyPayment(reference);
      _currentTransaction = transaction;

      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      } else {
        _transactions.insert(0, transaction);
      }

      return transaction;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _service.getMyTransactions();
    } catch (e) {
      _errorMessage = 'Failed to load transactions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}