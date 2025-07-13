import 'package:flutter/material.dart';
import '../models/responsibility.dart';
import '../services/api_service.dart';

class ResponsibilityProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Responsibility> _responsibilities = [];
  bool _isLoading = false;
  String? _error;

  List<Responsibility> get responsibilities => _responsibilities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Responsibility> get activeResponsibilities => 
    _responsibilities.where((resp) => resp.status == 'active' && resp.isActive).toList();
  
  List<Responsibility> get overdueResponsibilities => 
    _responsibilities.where((resp) => resp.isOverdue && resp.isActive).toList();

  List<Responsibility> get myResponsibilities => 
    _responsibilities.where((resp) => resp.assignedToEmail != null && resp.isActive).toList();

  Future<void> loadResponsibilities({String? frequency, String? status, String? assigned}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _responsibilities = await _apiService.getResponsibilities(
        frequency: frequency, 
        status: status, 
        assigned: assigned
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createResponsibility(Responsibility responsibility) async {
    try {
      final newResponsibility = await _apiService.createResponsibility(responsibility);
      _responsibilities.add(newResponsibility);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateResponsibility(String responsibilityId, Map<String, dynamic> data) async {
    try {
      final updatedResponsibility = await _apiService.updateResponsibility(responsibilityId, data);
      final index = _responsibilities.indexWhere((resp) => resp.id == responsibilityId);
      if (index != -1) {
        _responsibilities[index] = updatedResponsibility;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteResponsibility(String responsibilityId) async {
    try {
      await _apiService.deleteResponsibility(responsibilityId);
      _responsibilities.removeWhere((resp) => resp.id == responsibilityId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> completeResponsibility(String responsibilityId, ResponsibilityCompletion completion) async {
    try {
      await _apiService.completeResponsibility(responsibilityId, completion);
      // Reload responsibilities to get updated status
      await loadResponsibilities();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<Responsibility> getResponsibilitiesByFrequency(String frequency) {
    return _responsibilities.where((resp) => 
      resp.frequency == frequency && 
      resp.status == 'active' && 
      resp.isActive
    ).toList();
  }

  List<Responsibility> getResponsibilitiesByPriority(String priority) {
    return _responsibilities.where((resp) => 
      resp.priority == priority && 
      resp.status == 'active' && 
      resp.isActive
    ).toList();
  }
}