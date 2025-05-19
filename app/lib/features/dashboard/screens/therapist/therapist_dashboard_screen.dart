import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';

class TherapistDashboardScreen extends StatelessWidget {
  const TherapistDashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    try {
      await authProvider.signOut();
      // Navigation will be handled by AppWidget
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Therapist Dashboard'),
              automaticallyImplyLeading: false,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await _handleLogout(context, authProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            (authProvider.user?.bestName ?? authProvider.user?.email ?? 'T')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome Therapist!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authProvider.user?.bestName ?? authProvider.user?.email ?? 'Therapist',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Role: ${authProvider.user?.role ?? "N/A"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Therapist Dashboard Features Coming Soon:'),
                          SizedBox(height: 8),
                          Text('• Client Management'),
                          Text('• Session Scheduling'),
                          Text('• Progress Tracking'),
                          Text('• Treatment Plans'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
