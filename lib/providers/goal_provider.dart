import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/api_service.dart';

class GoalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Goal> get activeGoals => _goals.where((goal) => goal.status == 'active' && goal.isActive).toList();
  List<Goal> get completedGoals => _goals.where((goal) => goal.status == 'completed').toList();

  Future<void> loadGoals({String? frequency, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _apiService.getGoals(frequency: frequency, status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGoal(Goal goal) async {
    try {
      final newGoal = await _apiService.createGoal(goal);
      _goals.add(newGoal);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateGoal(String goalId, Map<String, dynamic> data) async {
    try {
      final updatedGoal = await _apiService.updateGoal(goalId, data);
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _apiService.deleteGoal(goalId);
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addProgress(String goalId, GoalProgress progress) async {
    try {
      await _apiService.addGoalProgress(goalId, progress);
      // Reload goals to get updated progress
      await loadGoals();
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

  List<Goal> getGoalsByFrequency(String frequency) {
    return _goals.where((goal) => 
      goal.frequency == frequency && 
      goal.status == 'active' && 
      goal.isActive
    ).toList();
  }
}