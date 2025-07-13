import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalForm extends StatefulWidget {
  final Goal? goal;
  final Function(Map<String, dynamic>) onSave;

  const GoalForm({
    Key? key,
    this.goal,
    required this.onSave,
  }) : super(key: key);

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _unitController = TextEditingController();
  
  String _selectedFrequency = 'daily';
  String _selectedPriority = 'medium';
  String _selectedStatus = 'active';
  String _selectedColor = '#4CAF50';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;

  final List<String> _frequencies = ['daily', 'weekly', 'monthly', 'yearly'];
  final List<String> _priorities = ['low', 'medium', 'high', 'critical'];
  final List<String> _statuses = ['active', 'completed', 'paused', 'cancelled'];
  final List<String> _colors = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#607D8B', // Blue Grey
    '#795548', // Brown
    '#009688', // Teal
  ];

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final goal = widget.goal!;
    _titleController.text = goal.title;
    _descriptionController.text = goal.description ?? '';
    _targetValueController.text = goal.targetValue?.toString() ?? '';
    _currentValueController.text = goal.currentValue.toString();
    _unitController.text = goal.unit ?? '';
    _selectedFrequency = goal.frequency;
    _selectedPriority = goal.priority;
    _selectedStatus = goal.status;
    _selectedColor = goal.color;
    _startDate = goal.startDate;
    _endDate = goal.endDate;
    _isActive = goal.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.goal != null ? 'Edit Goal' : 'Create Goal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Frequency and Priority Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Frequency *',
                        border: OutlineInputBorder(),
                      ),
                      items: _frequencies.map((frequency) {
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequency = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority *',
                        border: OutlineInputBorder(),
                      ),
                      items: _priorities.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status and Color Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status *',
                        border: OutlineInputBorder(),
                      ),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Color'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _colors.map((color) {
                            final isSelected = color == _selectedColor;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.grey,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Target Value and Unit Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetValueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target Value',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 10000',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., steps, hours',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current Value (only for editing)
              if (widget.goal != null) ...[
                TextFormField(
                  controller: _currentValueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Value',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Start Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_startDate.toString().split(' ')[0]),
                ),
              ),
              const SizedBox(height: 16),

              // End Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
                    firstDate: _startDate,
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_endDate != null)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _endDate = null;
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  child: Text(_endDate?.toString().split(' ')[0] ?? 'No end date'),
                ),
              ),
              const SizedBox(height: 16),

              // Active Toggle
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Goal is currently active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.goal != null ? 'Update Goal' : 'Create Goal',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goalData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
        'frequency': _selectedFrequency,
        'priority': _selectedPriority,
        'status': _selectedStatus,
        'target_value': _targetValueController.text.isNotEmpty 
          ? int.tryParse(_targetValueController.text) 
          : null,
        'current_value': widget.goal != null && _currentValueController.text.isNotEmpty
          ? int.tryParse(_currentValueController.text) 
          : 0,
        'unit': _unitController.text.trim().isNotEmpty 
          ? _unitController.text.trim() 
          : null,
        'start_date': _startDate.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'color': _selectedColor,
        'is_active': _isActive,
      };

      widget.onSave(goalData);
    }
  }
}