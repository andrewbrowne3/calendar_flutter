import 'package:flutter/material.dart';
import '../models/calendar.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class CalendarProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Calendar> _calendars = [];
  List<Event> _events = [];
  Calendar? _selectedCalendar;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  List<Calendar> get calendars => _calendars;
  List<Event> get events => _events;
  Calendar? get selectedCalendar => _selectedCalendar;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadEvents();
  }

  void setSelectedCalendar(Calendar? calendar) {
    _selectedCalendar = calendar;
    notifyListeners();
    loadEvents();
  }

  List<Event> getEventsForDate(DateTime date) {
    print('Getting events for date: $date');
    print('Total events in memory: ${_events.length}');
    
    final filteredEvents = _events.where((event) {
      // Convert event time to local time for comparison
      final eventLocalTime = event.startTime.toLocal();
      final eventDate = DateTime(
        eventLocalTime.year,
        eventLocalTime.month,
        eventLocalTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      
      // Also check if it's an all-day event or if the event spans multiple days
      if (event.allDay) {
        return eventDate.isAtSameMomentAs(targetDate);
      }
      
      // For non-all-day events, check if the date falls within the event's duration
      final eventEndLocalTime = event.endTime.toLocal();
      final eventEndDate = DateTime(
        eventEndLocalTime.year,
        eventEndLocalTime.month,
        eventEndLocalTime.day,
      );
      
      final matches = targetDate.isAtSameMomentAs(eventDate) ||
             targetDate.isAtSameMomentAs(eventEndDate) ||
             (targetDate.isAfter(eventDate) && targetDate.isBefore(eventEndDate));
      
      if (matches) {
        print('Event matches: ${event.title} on ${event.startTime}');
      }
      
      return matches;
    }).toList();
    
    print('Filtered events for date: ${filteredEvents.length}');
    return filteredEvents;
  }

  Future<void> loadCalendars() async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Test connection first
      final connectionOk = await _apiService.testConnection();
      if (!connectionOk) {
        throw 'Cannot connect to server. Please check your internet connection.';
      }
      
      _calendars = await _apiService.getCalendars();
      if (_calendars.isNotEmpty && _selectedCalendar == null) {
        _selectedCalendar = _calendars.first;
      }
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Default to current month if no dates provided
      startDate ??= DateTime(_selectedDate.year, _selectedDate.month, 1);
      endDate ??= DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      
      print('Loading events from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      print('Selected calendar: ${_selectedCalendar?.id}');
      
      // Don't filter by calendar if none selected to see all events
      _events = await _apiService.getEvents(
        startDate: startDate.toIso8601String().split('T')[0],
        endDate: endDate.toIso8601String().split('T')[0],
        // calendarId: _selectedCalendar?.id,
      );
      
      print('Loaded ${_events.length} events');
      for (var event in _events) {
        print('Event: ${event.title} - ${event.startTime} (Calendar: ${event.calendarId})');
      }
      
      _setLoading(false);
    } catch (e) {
      print('Error loading events: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> createCalendar(Calendar calendar) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final newCalendar = await _apiService.createCalendar(calendar);
      _calendars.add(newCalendar);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCalendar(String calendarId, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final updatedCalendar = await _apiService.updateCalendar(calendarId, data);
      final index = _calendars.indexWhere((c) => c.id == calendarId);
      if (index != -1) {
        _calendars[index] = updatedCalendar;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCalendar(String calendarId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _apiService.deleteCalendar(calendarId);
      _calendars.removeWhere((c) => c.id == calendarId);
      if (_selectedCalendar?.id == calendarId) {
        _selectedCalendar = _calendars.isNotEmpty ? _calendars.first : null;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createEvent(Event event, {
    List<String>? attendeeEmails,
    List<int>? reminderMinutes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final newEvent = await _apiService.createEvent(
        event,
        attendeeEmails: attendeeEmails,
        reminderMinutes: reminderMinutes,
      );
      _events.add(newEvent);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final updatedEvent = await _apiService.updateEvent(eventId, data);
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = updatedEvent;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _apiService.deleteEvent(eventId);
      _events.removeWhere((e) => e.id == eventId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> shareCalendar(String calendarId, String userEmail, String permission) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _apiService.shareCalendar(calendarId, userEmail, permission);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> respondToEvent(String eventId, String response) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _apiService.respondToEvent(eventId, response);
      await loadEvents(); // Refresh events to show updated response
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }

  Future<void> toggleEventCompletion(Event event) async {
    try {
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        // Update the completed status locally first for immediate UI feedback
        final updatedEvent = Event(
          id: event.id,
          calendar: event.calendar,
          calendarId: event.calendarId,
          creator: event.creator,
          title: event.title,
          description: event.description,
          location: event.location,
          startTime: event.startTime,
          endTime: event.endTime,
          allDay: event.allDay,
          status: event.status,
          color: event.color,
          recurrenceRule: event.recurrenceRule,
          recurrenceEndDate: event.recurrenceEndDate,
          recurrenceCount: event.recurrenceCount,
          recurrenceInterval: event.recurrenceInterval,
          url: event.url,
          isPrivate: event.isPrivate,
          duration: event.duration,
          attendees: event.attendees,
          reminders: event.reminders,
          completed: !event.completed,
          createdAt: event.createdAt,
          updatedAt: event.updatedAt,
        );
        
        _events[index] = updatedEvent;
        notifyListeners();
        
        // Update on the server
        await updateEvent(event.id, {'completed': !event.completed});
      }
    } catch (e) {
      // If server update fails, revert the local change
      await loadEvents();
      _setError(e.toString());
    }
  }
}