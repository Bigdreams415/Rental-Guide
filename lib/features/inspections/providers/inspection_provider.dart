import 'package:flutter/material.dart';
import '../../../core/models/inspection_model.dart';
import '../../../core/services/inspection_service.dart';

class InspectionProvider extends ChangeNotifier {
  final InspectionService _service = InspectionService();

  List<InspectionModel> _inspections = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<InspectionModel> get inspections => _inspections;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  List<InspectionModel> get upcoming => _inspections
      .where((i) => i.isPending || i.isConfirmed || i.isRescheduled)
      .toList();

  List<InspectionModel> get past =>
      _inspections.where((i) => i.isCompleted || i.isCancelled).toList();

  Future<void> loadInspections() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _inspections = await _service.getMyInspections();
    } catch (e) {
      _errorMessage = 'Failed to load inspections';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestInspection({
    required String propertyId,
    required DateTime date,
    String? note,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inspection = await _service.requestInspection(
        propertyId: propertyId,
        requestedDate: date,
        note: note,
      );
      _inspections.insert(0, inspection);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> confirmInspection(String id) async {
    return _updateInspection(id, () => _service.confirmInspection(id));
  }

  Future<bool> cancelInspection(String id) async {
    return _updateInspection(id, () => _service.cancelInspection(id));
  }

  Future<bool> completeInspection(String id) async {
    return _updateInspection(id, () => _service.completeInspection(id));
  }

  Future<bool> rescheduleInspection({
    required String id,
    required DateTime newDate,
    String? note,
  }) async {
    return _updateInspection(
      id,
      () => _service.rescheduleInspection(id: id, newDate: newDate, note: note),
    );
  }

  Future<bool> _updateInspection(
    String id,
    Future<InspectionModel> Function() call,
  ) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await call();
      final index = _inspections.indexWhere((i) => i.id == id);
      if (index != -1) _inspections[index] = updated;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
