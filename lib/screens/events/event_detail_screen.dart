import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/calendar_provider.dart';
import 'create_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateEventScreen(
                        selectedDate: event.startTime,
                        event: event,
                      ),
                    ),
                  );
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title and color
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: event.color != null
                        ? Color(int.parse(event.color!.replaceFirst('#', '0xff')))
                        : event.calendar?.color != null
                            ? Color(int.parse(event.calendar!.color.replaceFirst('#', '0xff')))
                            : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date and time
            _buildInfoCard(
              context,
              icon: Icons.schedule,
              title: 'Date & Time',
              content: _formatDateTime(),
            ),

            if (event.location != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                icon: Icons.location_on,
                title: 'Location',
                content: event.location!,
              ),
            ],

            if (event.description != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                icon: Icons.description,
                title: 'Description',
                content: event.description!,
              ),
            ],

            if (event.url != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                icon: Icons.link,
                title: 'URL',
                content: event.url!,
                isUrl: true,
              ),
            ],

            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.calendar_view_day,
              title: 'Calendar',
              content: event.calendar?.name ?? 'Unknown',
            ),

            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.info,
              title: 'Status',
              content: event.status.toUpperCase(),
            ),

            if (event.recurrenceRule != 'none') ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                icon: Icons.repeat,
                title: 'Repeats',
                content: event.recurrenceRule.toUpperCase(),
              ),
            ],

            if (event.isPrivate) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                icon: Icons.lock,
                title: 'Privacy',
                content: 'Private Event',
              ),
            ],

            if (event.attendees != null && event.attendees!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAttendeesCard(context),
            ],

            if (event.reminders != null && event.reminders!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRemindersCard(context),
            ],

            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.person,
              title: 'Created by',
              content: event.creator?.fullName ?? 'Unknown',
            ),

            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.access_time,
              title: 'Created',
              content: DateFormat('MMM dd, yyyy hh:mm a').format(event.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    bool isUrl = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            isUrl
                ? InkWell(
                    onTap: () {
                      // TODO: Launch URL
                    },
                    child: Text(
                      content,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Attendees',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...event.attendees!.map((attendee) {
              final name = attendee.user?.fullName ?? attendee.name ?? attendee.email ?? 'Unknown';
              final responseColor = _getResponseColor(attendee.response);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: responseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name)),
                    Text(
                      attendee.response.toUpperCase(),
                      style: TextStyle(
                        color: responseColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (attendee.isOrganizer)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.star, size: 16, color: Colors.amber),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notification_important, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Reminders',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...event.reminders!.map((reminder) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(_getReminderIcon(reminder.reminderType), size: 16),
                    const SizedBox(width: 8),
                    Text('${reminder.minutesBefore} minutes before'),
                    const Spacer(),
                    Text(
                      reminder.reminderType.toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDateTime() {
    if (event.allDay) {
      if (event.startTime.day == event.endTime.day &&
          event.startTime.month == event.endTime.month &&
          event.startTime.year == event.endTime.year) {
        return '${DateFormat('EEEE, MMMM dd, yyyy').format(event.startTime)}\nAll day';
      } else {
        return '${DateFormat('MMM dd, yyyy').format(event.startTime)} - ${DateFormat('MMM dd, yyyy').format(event.endTime)}\nAll day';
      }
    } else {
      final startStr = DateFormat('EEEE, MMMM dd, yyyy hh:mm a').format(event.startTime);
      final endStr = DateFormat('hh:mm a').format(event.endTime);
      
      if (event.startTime.day == event.endTime.day &&
          event.startTime.month == event.endTime.month &&
          event.startTime.year == event.endTime.year) {
        return '$startStr - $endStr';
      } else {
        return '$startStr - ${DateFormat('MMMM dd, yyyy hh:mm a').format(event.endTime)}';
      }
    }
  }

  Color _getResponseColor(String response) {
    switch (response) {
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'tentative':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getReminderIcon(String type) {
    switch (type) {
      case 'email':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      default:
        return Icons.notifications;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEvent(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    
    final success = await calendarProvider.deleteEvent(event.id);
    
    if (success && context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(calendarProvider.error ?? 'Failed to delete event')),
      );
    }
  }
}