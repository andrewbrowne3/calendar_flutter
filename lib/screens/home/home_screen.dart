import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../models/event.dart';
import '../events/event_detail_screen.dart';
import '../events/create_event_screen.dart';
import '../calendar/calendar_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('User logged in: ${authProvider.isAuthenticated}');
      print('User: ${authProvider.user?.email}');
      
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      await calendarProvider.loadCalendars();
      await calendarProvider.loadEvents();
      print('Initial load complete - calendars: ${calendarProvider.calendars.length}, events: ${calendarProvider.events.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CalendarProvider>(
        builder: (context, calendarProvider, child) {
          if (calendarProvider.isLoading && calendarProvider.calendars.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (calendarProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(calendarProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      calendarProvider.loadCalendars();
                      calendarProvider.loadEvents();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Calendar selector
              if (calendarProvider.calendars.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text(
                            'No calendars available',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create a calendar in the Django admin or through the Calendars menu',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CalendarListScreen()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Manage Calendars'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (calendarProvider.calendars.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: calendarProvider.selectedCalendar?.id,
                    decoration: const InputDecoration(
                      labelText: 'Calendar',
                      border: OutlineInputBorder(),
                    ),
                    items: calendarProvider.calendars.map((calendar) {
                      return DropdownMenuItem(
                        value: calendar.id,
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
                      print('Calendar selected: $value');
                      final calendar = calendarProvider.calendars.firstWhere((c) => c.id == value);
                      calendarProvider.setSelectedCalendar(calendar);
                    },
                  ),
                ),
              
              // Calendar widget
              TableCalendar<Event>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: calendarProvider.getEventsForDate,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    calendarProvider.setSelectedDate(selectedDay);
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  calendarProvider.loadEvents(
                    startDate: DateTime(focusedDay.year, focusedDay.month, 1),
                    endDate: DateTime(focusedDay.year, focusedDay.month + 1, 0),
                  );
                },
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Events list
              Expanded(
                child: _selectedDay != null
                    ? _buildEventsList(calendarProvider.getEventsForDate(_selectedDay!))
                    : const Center(child: Text('Select a date to view events')),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateEventScreen(selectedDate: _selectedDay ?? DateTime.now()),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No events for this day',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 12,
              height: 40,
              decoration: BoxDecoration(
                color: event.color != null
                    ? Color(int.parse(event.color!.replaceFirst('#', '0xff')))
                    : event.calendar?.color != null
                        ? Color(int.parse(event.calendar!.color.replaceFirst('#', '0xff')))
                        : Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            title: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.location != null)
                  Text(
                    event.location!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                Text(
                  event.allDay
                      ? 'All day'
                      : '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $amPm';
  }

}