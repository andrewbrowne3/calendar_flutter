import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class AutoLoginScreen extends StatefulWidget {
  const AutoLoginScreen({Key? key}) : super(key: key);

  @override
  State<AutoLoginScreen> createState() => _AutoLoginScreenState();
}

class _AutoLoginScreenState extends State<AutoLoginScreen> {
  @override
  void initState() {
    super.initState();
    // Add a small delay to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptAutoLogin();
    });
    
    // Fallback timeout to prevent getting stuck
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  Future<void> _attemptAutoLogin() async {
    try {
      print('AutoLogin: Starting auto-login attempt');
      
      // Add a small delay to ensure everything is initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) {
        print('AutoLogin: Widget not mounted, returning');
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('AutoLogin: AuthProvider isAuthenticated: ${authProvider.isAuthenticated}');
      
      // Check if user is already authenticated via AuthProvider
      if (authProvider.isAuthenticated) {
        print('AutoLogin: User already authenticated, navigating to MainScreen');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
        return;
      }

      // Check if Remember Me is enabled with saved credentials
      final rememberMe = StorageService.getRememberMe();
      final savedEmail = StorageService.getSavedEmail();
      final savedPassword = StorageService.getSavedPassword();
      
      print('AutoLogin: Remember Me: $rememberMe, Email: ${savedEmail != null}, Password: ${savedPassword != null}');

      if (rememberMe && savedEmail != null && savedPassword != null) {
        print('AutoLogin: Attempting login with saved credentials');
        // Attempt to login with saved credentials
        final success = await authProvider.login(savedEmail, savedPassword);
        print('AutoLogin: Login success: $success');

        if (success && mounted) {
          print('AutoLogin: Login successful, navigating to MainScreen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
          return;
        }
      }

      // No auto-login possible, go to login screen
      print('AutoLogin: No auto-login possible, navigating to LoginScreen');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('AutoLogin: Error during auto-login: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}