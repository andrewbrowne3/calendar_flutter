import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar.dart';

class CalendarListScreen extends StatefulWidget {
  const CalendarListScreen({Key? key}) : super(key: key);

  @override
  State<CalendarListScreen> createState() => _CalendarListScreenState();
}

class _CalendarListScreenState extends State<CalendarListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarProvider>(context, listen: false).loadCalendars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Calendars'),
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, calendarProvider, child) {
          if (calendarProvider.isLoading && calendarProvider.calendars.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (calendarProvider.calendars.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_view_month, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No calendars yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first calendar to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: calendarProvider.calendars.length,
            itemBuilder: (context, index) {
              final calendar = calendarProvider.calendars[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(int.parse(calendar.color.replaceFirst('#', '0xff'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    calendar.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (calendar.description != null) Text(calendar.description!),
                      Text('${calendar.eventCount ?? 0} events • ${calendar.visibility}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditCalendarDialog(context, calendar);
                          break;
                        case 'share':
                          _showShareDialog(context, calendar);
                          break;
                        case 'delete':
                          _showDeleteDialog(context, calendar);
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
                        value: 'share',
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text('Share'),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCalendarDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCalendarDialog(BuildContext context) {
    _showCalendarDialog(context, null);
  }

  void _showEditCalendarDialog(BuildContext context, Calendar calendar) {
    _showCalendarDialog(context, calendar);
  }

  void _showCalendarDialog(BuildContext context, Calendar? calendar) {
    final nameController = TextEditingController(text: calendar?.name ?? '');
    final descriptionController = TextEditingController(text: calendar?.description ?? '');
    String selectedVisibility = calendar?.visibility ?? 'private';
    Color selectedColor = calendar != null
        ? Color(int.parse(calendar.color.replaceFirst('#', '0xff')))
        : Colors.blue;

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(calendar != null ? 'Edit Calendar' : 'Create Calendar'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Calendar Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedVisibility,
                      decoration: const InputDecoration(
                        labelText: 'Visibility',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'private', child: Text('Private')),
                        DropdownMenuItem(value: 'public', child: Text('Public')),
                        DropdownMenuItem(value: 'shared', child: Text('Shared')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedVisibility = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Calendar Color'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selectedColor == color
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                            child: selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
                      
                      bool success;
                      if (calendar != null) {
                        success = await calendarProvider.updateCalendar(
                          calendar.id,
                          {
                            'name': nameController.text.trim(),
                            'description': descriptionController.text.trim().isNotEmpty 
                                ? descriptionController.text.trim() 
                                : null,
                            'visibility': selectedVisibility,
                            'color': '#${selectedColor.value.toRadixString(16).substring(2)}',
                          },
                        );
                      } else {
                        final newCalendar = Calendar(
                          id: '',
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim().isNotEmpty 
                              ? descriptionController.text.trim() 
                              : null,
                          color: '#${selectedColor.value.toRadixString(16).substring(2)}',
                          visibility: selectedVisibility,
                          timezone: 'UTC',
                          isActive: true,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        success = await calendarProvider.createCalendar(newCalendar);
                      }

                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calendar ${calendar != null ? 'updated' : 'created'} successfully'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(calendar != null ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShareDialog(BuildContext context, Calendar calendar) {
    final emailController = TextEditingController();
    String selectedPermission = 'view';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Share Calendar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPermission,
                    decoration: const InputDecoration(
                      labelText: 'Permission',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'view', child: Text('View Only')),
                      DropdownMenuItem(value: 'edit', child: Text('Edit Events')),
                      DropdownMenuItem(value: 'manage', child: Text('Full Access')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPermission = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.trim().isNotEmpty) {
                      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
                      
                      final success = await calendarProvider.shareCalendar(
                        calendar.id,
                        emailController.text.trim(),
                        selectedPermission,
                      );

                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calendar shared successfully')),
                        );
                      }
                    }
                  },
                  child: const Text('Share'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Calendar calendar) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Calendar'),
          content: Text('Are you sure you want to delete "${calendar.name}"? This will also delete all events in this calendar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
                
                final success = await calendarProvider.deleteCalendar(calendar.id);
                
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calendar deleted successfully')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}