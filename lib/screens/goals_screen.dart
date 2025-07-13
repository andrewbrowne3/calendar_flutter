import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import '../widgets/goal_form.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedFrequency;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadGoals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'all_freq') {
                  _selectedFrequency = null;
                } else if (value == 'all_status') {
                  _selectedStatus = null;
                } else if (['daily', 'weekly', 'monthly', 'yearly'].contains(value)) {
                  _selectedFrequency = value;
                } else if (['active', 'completed', 'paused', 'cancelled'].contains(value)) {
                  _selectedStatus = value;
                }
              });
              context.read<GoalProvider>().loadGoals(
                frequency: _selectedFrequency,
                status: _selectedStatus,
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter_header',
                enabled: false,
                child: Text('Filter by Frequency', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const PopupMenuItem(value: 'all_freq', child: Text('All Frequencies')),
              const PopupMenuItem(value: 'daily', child: Text('Daily')),
              const PopupMenuItem(value: 'weekly', child: Text('Weekly')),
              const PopupMenuItem(value: 'monthly', child: Text('Monthly')),
              const PopupMenuItem(value: 'yearly', child: Text('Yearly')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'status_header',
                enabled: false,
                child: Text('Filter by Status', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const PopupMenuItem(value: 'all_status', child: Text('All Statuses')),
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'paused', child: Text('Paused')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, goalProvider, child) {
          if (goalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (goalProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${goalProvider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => goalProvider.loadGoals(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildGoalsList(goalProvider.activeGoals),
              _buildGoalsList(goalProvider.completedGoals),
              _buildGoalsList(goalProvider.goals),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGoalForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalsList(List<Goal> goals) {
    if (goals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No goals found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create your first goal',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<GoalProvider>().loadGoals(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return GoalCard(
            goal: goal,
            onTap: () => _showGoalDetails(context, goal),
            onEdit: () => _showGoalForm(context, goal: goal),
            onDelete: () => _deleteGoal(context, goal),
          );
        },
      ),
    );
  }

  void _showGoalForm(BuildContext context, {Goal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GoalForm(
          goal: goal,
          onSave: (goalData) async {
            try {
              if (goal != null) {
                await context.read<GoalProvider>().updateGoal(goal.id, goalData);
              } else {
                final newGoal = Goal(
                  id: '',
                  title: goalData['title'],
                  description: goalData['description'],
                  frequency: goalData['frequency'],
                  priority: goalData['priority'],
                  status: goalData['status'] ?? 'active',
                  targetValue: goalData['target_value'],
                  currentValue: goalData['current_value'] ?? 0,
                  unit: goalData['unit'],
                  startDate: DateTime.parse(goalData['start_date']),
                  endDate: goalData['end_date'] != null 
                    ? DateTime.parse(goalData['end_date']) 
                    : null,
                  color: goalData['color'] ?? '#4CAF50',
                  isActive: goalData['is_active'] ?? true,
                  progressPercentage: 0.0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await context.read<GoalProvider>().createGoal(newGoal);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(goal != null ? 'Goal updated!' : 'Goal created!'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showGoalDetails(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (goal.description?.isNotEmpty == true) ...[
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(goal.description!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Text('Frequency: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(goal.frequency.toUpperCase()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Priority: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(goal.priority.toUpperCase()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(goal.status.toUpperCase()),
                ],
              ),
              if (goal.targetValue != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Progress: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${goal.currentValue}/${goal.targetValue} ${goal.unit ?? ''}'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(int.parse(goal.color.replaceFirst('#', '0xFF'))),
                  ),
                ),
                Text('${goal.progressPercentage.toStringAsFixed(1)}%'),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Start Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(goal.startDate.toString().split(' ')[0]),
                ],
              ),
              if (goal.endDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('End Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(goal.endDate.toString().split(' ')[0]),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (goal.status == 'active' && goal.targetValue != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showProgressForm(context, goal);
              },
              child: const Text('Add Progress'),
            ),
        ],
      ),
    );
  }

  void _showProgressForm(BuildContext context, Goal goal) {
    final valueController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Progress - ${goal.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Progress Value',
                hintText: 'Enter progress amount',
                suffixText: goal.unit,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any notes about this progress...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(valueController.text);
              if (value != null && value > 0) {
                try {
                  final progress = GoalProgress(
                    id: '',
                    date: DateTime.now(),
                    value: value,
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                    createdAt: DateTime.now(),
                  );
                  
                  await context.read<GoalProvider>().addProgress(goal.id, progress);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress added!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<GoalProvider>().deleteGoal(goal.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Goal deleted!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}