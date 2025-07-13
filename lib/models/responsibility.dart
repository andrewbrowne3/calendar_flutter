class Responsibility {
  final String id;
  final String title;
  final String? description;
  final String frequency; // daily, weekly, monthly
  final String priority; // low, medium, high, urgent
  final String status; // active, completed, overdue, cancelled
  final String? assignedToEmail;
  final DateTime startDate;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final DateTime? nextDueDate;
  final double? estimatedHours;
  final double? actualHours;
  final String color;
  final bool isActive;
  final bool isOverdue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Responsibility({
    required this.id,
    required this.title,
    this.description,
    required this.frequency,
    required this.priority,
    required this.status,
    this.assignedToEmail,
    required this.startDate,
    this.dueDate,
    this.completedDate,
    this.nextDueDate,
    this.estimatedHours,
    this.actualHours,
    required this.color,
    required this.isActive,
    required this.isOverdue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Responsibility.fromJson(Map<String, dynamic> json) {
    return Responsibility(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      frequency: json['frequency'],
      priority: json['priority'],
      status: json['status'],
      assignedToEmail: json['assigned_to']?['email'],
      startDate: DateTime.parse(json['start_date']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completedDate: json['completed_date'] != null ? DateTime.parse(json['completed_date']) : null,
      nextDueDate: json['next_due_date'] != null ? DateTime.parse(json['next_due_date']) : null,
      estimatedHours: json['estimated_hours'] != null ? double.parse(json['estimated_hours'].toString()) : null,
      actualHours: json['actual_hours'] != null ? double.parse(json['actual_hours'].toString()) : null,
      color: json['color'] ?? '#FF9800',
      isActive: json['is_active'] ?? true,
      isOverdue: json['is_overdue'] ?? false,
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
      'assigned_to_email': assignedToEmail,
      'start_date': startDate.toIso8601String().split('T')[0],
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'estimated_hours': estimatedHours,
      'actual_hours': actualHours,
      'color': color,
      'is_active': isActive,
    };
  }

  Responsibility copyWith({
    String? id,
    String? title,
    String? description,
    String? frequency,
    String? priority,
    String? status,
    String? assignedToEmail,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedDate,
    DateTime? nextDueDate,
    double? estimatedHours,
    double? actualHours,
    String? color,
    bool? isActive,
    bool? isOverdue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Responsibility(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedToEmail: assignedToEmail ?? this.assignedToEmail,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      isOverdue: isOverdue ?? this.isOverdue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ResponsibilityCompletion {
  final String id;
  final DateTime completedDate;
  final double? hoursSpent;
  final String? notes;
  final int? qualityRating;

  ResponsibilityCompletion({
    required this.id,
    required this.completedDate,
    this.hoursSpent,
    this.notes,
    this.qualityRating,
  });

  factory ResponsibilityCompletion.fromJson(Map<String, dynamic> json) {
    return ResponsibilityCompletion(
      id: json['id'],
      completedDate: DateTime.parse(json['completed_date']),
      hoursSpent: json['hours_spent'] != null ? double.parse(json['hours_spent'].toString()) : null,
      notes: json['notes'],
      qualityRating: json['quality_rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_date': completedDate.toIso8601String(),
      'hours_spent': hoursSpent,
      'notes': notes,
      'quality_rating': qualityRating,
    };
  }
}