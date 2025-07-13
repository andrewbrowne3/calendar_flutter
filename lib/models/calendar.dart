import 'user.dart';

class Calendar {
  final String id;
  final User? owner;
  final String name;
  final String? description;
  final String color;
  final String visibility;
  final String timezone;
  final bool isActive;
  final int? eventCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Calendar({
    required this.id,
    this.owner,
    required this.name,
    this.description,
    required this.color,
    required this.visibility,
    required this.timezone,
    required this.isActive,
    this.eventCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'],
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      name: json['name'],
      description: json['description'],
      color: json['color'],
      visibility: json['visibility'],
      timezone: json['timezone'],
      isActive: json['is_active'],
      eventCount: json['event_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'visibility': visibility,
      'timezone': timezone,
    };
  }
}

class CalendarShare {
  final int? id;
  final Calendar? calendar;
  final User? user;
  final String permission;
  final DateTime? createdAt;

  CalendarShare({
    this.id,
    this.calendar,
    this.user,
    required this.permission,
    this.createdAt,
  });

  factory CalendarShare.fromJson(Map<String, dynamic> json) {
    return CalendarShare(
      id: json['id'],
      calendar: json['calendar'] != null ? Calendar.fromJson(json['calendar']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      permission: json['permission'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}