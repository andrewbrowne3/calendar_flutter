import 'user.dart';
import 'calendar.dart';

class Event {
  final String id;
  final Calendar? calendar;
  final String? calendarId;
  final User? creator;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final bool allDay;
  final String status;
  final String? color;
  final String recurrenceRule;
  final DateTime? recurrenceEndDate;
  final int? recurrenceCount;
  final int recurrenceInterval;
  final String? url;
  final bool isPrivate;
  final Duration? duration;
  final List<EventAttendee>? attendees;
  final List<EventReminder>? reminders;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    this.calendar,
    this.calendarId,
    this.creator,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    required this.allDay,
    required this.status,
    this.color,
    required this.recurrenceRule,
    this.recurrenceEndDate,
    this.recurrenceCount,
    required this.recurrenceInterval,
    this.url,
    required this.isPrivate,
    this.duration,
    this.attendees,
    this.reminders,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      calendar: json['calendar'] != null ? Calendar.fromJson(json['calendar']) : null,
      calendarId: json['calendar_id'] ?? json['calendar']?['id'],
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      title: json['title'],
      description: json['description'],
      location: json['location'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      allDay: json['all_day'],
      status: json['status'],
      color: json['color'],
      recurrenceRule: json['recurrence_rule'],
      recurrenceEndDate: json['recurrence_end_date'] != null 
          ? DateTime.parse(json['recurrence_end_date']) 
          : null,
      recurrenceCount: json['recurrence_count'],
      recurrenceInterval: json['recurrence_interval'],
      url: json['url'],
      isPrivate: json['is_private'],
      duration: json['duration'] != null 
          ? Duration(seconds: double.parse(json['duration'].toString()).round()) 
          : null,
      attendees: json['attendees'] != null
          ? (json['attendees'] as List).map((a) => EventAttendee.fromJson(a)).toList()
          : null,
      reminders: json['reminders'] != null
          ? (json['reminders'] as List).map((r) => EventReminder.fromJson(r)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calendar': calendarId,
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'all_day': allDay,
      'status': status,
      'color': color,
      'recurrence_rule': recurrenceRule,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      'recurrence_count': recurrenceCount,
      'recurrence_interval': recurrenceInterval,
      'url': url,
      'is_private': isPrivate,
    };
  }
}

class EventAttendee {
  final int? id;
  final User? user;
  final String? email;
  final String? name;
  final String response;
  final bool isOrganizer;
  final DateTime createdAt;

  EventAttendee({
    this.id,
    this.user,
    this.email,
    this.name,
    required this.response,
    required this.isOrganizer,
    required this.createdAt,
  });

  factory EventAttendee.fromJson(Map<String, dynamic> json) {
    return EventAttendee(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      email: json['email'],
      name: json['name'],
      response: json['response'],
      isOrganizer: json['is_organizer'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class EventReminder {
  final int? id;
  final String reminderType;
  final int minutesBefore;
  final bool isSent;
  final DateTime createdAt;

  EventReminder({
    this.id,
    required this.reminderType,
    required this.minutesBefore,
    required this.isSent,
    required this.createdAt,
  });

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
      id: json['id'],
      reminderType: json['reminder_type'],
      minutesBefore: json['minutes_before'],
      isSent: json['is_sent'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminder_type': reminderType,
      'minutes_before': minutesBefore,
    };
  }
}