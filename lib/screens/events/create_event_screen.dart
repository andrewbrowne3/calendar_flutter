import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/calendar_provider.dart';
import '../../models/event.dart';
import '../../models/calendar.dart';

class CreateEventScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Event? event; // For editing existing events

  const CreateEventScreen({
    Key? key,
    required this.selectedDate,
    this.event,
  }) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _urlController = TextEditingController();
  final _attendeesController = TextEditingController();

  Calendar? _selectedCalendar;
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.now();
  bool _allDay = false;
  String _status = 'confirmed';
  String _recurrenceRule = 'none';
  bool _isPrivate = false;
  Color _eventColor = Colors.blue;
  
  final List<String> _statusOptions = ['confirmed', 'tentative', 'cancelled'];
  final List<String> _recurrenceOptions = ['none', 'daily', 'weekly', 'monthly', 'yearly'];
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedDate;
    _endDate = widget.selectedDate;
    _endTime = TimeOfDay(hour: _startTime.hour + 1, minute: _startTime.minute);
    
    if (widget.event != null) {
      _loadEventData();
    }
  }

  void _loadEventData() {
    final event = widget.event!;
    _titleController.text = event.title;
    _descriptionController.text = event.description ?? '';
    _locationController.text = event.location ?? '';
    _urlController.text = event.url ?? '';
    
    _startDate = event.startTime;
    _startTime = TimeOfDay.fromDateTime(event.startTime);
    _endDate = event.endTime;
    _endTime = TimeOfDay.fromDateTime(event.endTime);
    _allDay = event.allDay;
    _status = event.status;
    _recurrenceRule = event.recurrenceRule;
    _isPrivate = event.isPrivate;
    
    if (event.color != null) {
      try {
        _eventColor = Color(int.parse(event.color!.replaceFirst('#', '0xff')));
      } catch (e) {
        _eventColor = Colors.blue;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _urlController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'Create Event'),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, calendarProvider, child) {
          if (calendarProvider.calendars.isEmpty) {
            return const Center(
              child: Text('No calendars available. Please create a calendar first.'),
            );
          }

          _selectedCalendar ??= calendarProvider.selectedCalendar ?? calendarProvider.calendars.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an event title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Calendar>(
                    value: _selectedCalendar,
                    decoration: const InputDecoration(
                      labelText: 'Calendar',
                      border: OutlineInputBorder(),
                    ),
                    items: calendarProvider.calendars.map((calendar) {
                      return DropdownMenuItem(
                        value: calendar,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(int.parse(calendar.color.replaceFirst('#', '0xff'))),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(calendar.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCalendar = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('All Day'),
                    value: _allDay,
                    onChanged: (value) {
                      setState(() {
                        _allDay = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Start Date'),
                          subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      if (!_allDay)
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Time'),
                            subtitle: Text(_startTime.format(context)),
                            onTap: () => _selectTime(context, true),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('End Date'),
                          subtitle: Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                      if (!_allDay)
                        Expanded(
                          child: ListTile(
                            title: const Text('End Time'),
                            subtitle: Text(_endTime.format(context)),
                            onTap: () => _selectTime(context, false),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _recurrenceRule,
                    decoration: const InputDecoration(
                      labelText: 'Repeat',
                      border: OutlineInputBorder(),
                    ),
                    items: _recurrenceOptions.map((rule) {
                      return DropdownMenuItem(
                        value: rule,
                        child: Text(rule == 'none' ? 'Does not repeat' : rule.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _recurrenceRule = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Event Color'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _eventColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _eventColor == color
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: _eventColor == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Private Event'),
                    subtitle: const Text('Only you can see this event'),
                    value: _isPrivate,
                    onChanged: (value) {
                      setState(() {
                        _isPrivate = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _attendeesController,
                    decoration: const InputDecoration(
                      labelText: 'Invite Others (optional)',
                      hintText: 'Enter email addresses separated by commas',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_add),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate() && _selectedCalendar != null) {
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _allDay ? 0 : _startTime.hour,
        _allDay ? 0 : _startTime.minute,
      );
      
      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _allDay ? 23 : _endTime.hour,
        _allDay ? 59 : _endTime.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }

      final event = Event(
        id: widget.event?.id ?? '',
        calendarId: _selectedCalendar!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        startTime: startDateTime,
        endTime: endDateTime,
        allDay: _allDay,
        status: _status,
        color: '#${_eventColor.value.toRadixString(16).substring(2)}',
        recurrenceRule: _recurrenceRule,
        recurrenceInterval: 1,
        url: _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null,
        isPrivate: _isPrivate,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      List<String>? attendeeEmails;
      if (_attendeesController.text.trim().isNotEmpty) {
        attendeeEmails = _attendeesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      bool success;
      if (widget.event != null) {
        success = await calendarProvider.updateEvent(widget.event!.id, event.toJson());
      } else {
        success = await calendarProvider.createEvent(event, attendeeEmails: attendeeEmails);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event ${widget.event != null ? 'updated' : 'created'} successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(calendarProvider.error ?? 'Failed to save event')),
        );
      }
    }
  }
}