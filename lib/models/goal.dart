class Goal {
  final String id;
  final String title;
  final String? description;
  final String frequency; // daily, weekly, monthly, yearly
  final String priority; // low, medium, high, critical
  final String status; // active, completed, paused, cancelled
  final int? targetValue;
  final int currentValue;
  final String? unit;
  final DateTime startDate;
  final DateTime? endDate;
  final String color;
  final bool isActive;
  final double progressPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.title,
    this.description,
    required this.frequency,
    required this.priority,
    required this.status,
    this.targetValue,
    required this.currentValue,
    this.unit,
    required this.startDate,
    this.endDate,
    required this.color,
    required this.isActive,
    required this.progressPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      frequency: json['frequency'],
      priority: json['priority'],
      status: json['status'],
      targetValue: json['target_value'],
      currentValue: json['current_value'] ?? 0,
      unit: json['unit'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      color: json['color'] ?? '#4CAF50',
      isActive: json['is_active'] ?? true,
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'frequency': frequency,
      'priority': priority,
      'status': status,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'color': color,
      'is_active': isActive,
    };
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? frequency,
    String? priority,
    String? status,
    int? targetValue,
    int? currentValue,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    String? color,
    bool? isActive,
    double? progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GoalProgress {
  final String id;
  final DateTime date;
  final int value;
  final String? notes;
  final DateTime createdAt;

  GoalProgress({
    required this.id,
    required this.date,
    required this.value,
    this.notes,
    required this.createdAt,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      id: json['id'],
      date: DateTime.parse(json['date']),
      value: json['value'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'value': value,
      'notes': notes,
    };
  }
}