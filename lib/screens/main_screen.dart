import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/calendar/calendar_list_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const GoalsScreen(),
    const Center(child: Text('Responsibilities\n(Coming Soon)', textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
        ],
      ),
      appBar: _currentIndex == 0 ? null : AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'calendars':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CalendarListScreen()),
                  );
                  break;
                case 'profile':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'calendars',
                child: ListTile(
                  leading: Icon(Icons.calendar_view_month),
                  title: Text('Calendars'),
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Calendar';
      case 1:
        return 'Goals';
      case 2:
        return 'Responsibilities';
      default:
        return 'Calendar App';
    }
  }

  Future<void> _logout() async {
    print('MainScreen: Logout button pressed');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print('MainScreen: Auth state before logout: ${authProvider.isAuthenticated}');
    
    await authProvider.logout();
    
    print('MainScreen: Auth state after logout: ${authProvider.isAuthenticated}');
    
    if (mounted) {
      print('MainScreen: Navigating to login screen');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}