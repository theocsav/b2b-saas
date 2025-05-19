import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/screens/login_screen.dart';
import 'app_theme.dart';
import '../features/auth/providers/auth_provider.dart';
import 'app_router.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABA CRM',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (kDebugMode) {
            print("AppWidget rebuilding - Auth Status: ${authProvider.authStatus}, Loading: ${authProvider.isLoading}");
          }

          // Show loading during authentication process
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          }

          // Handle different auth states with immediate navigation
          switch (authProvider.authStatus) {
            case AuthStatus.authenticated:
              if (kDebugMode) print("User authenticated, navigating to dashboard for role: ${authProvider.user?.role}");
              
              // Use addPostFrameCallback to ensure navigation happens after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (authProvider.user?.role == 'admin') {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.adminDashboardRoute,
                    (route) => false,
                  );
                } else if (authProvider.user?.role == 'therapist') {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.therapistDashboardRoute,
                    (route) => false,
                  );
                } else {
                  // Default to admin dashboard for unknown roles
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.adminDashboardRoute,
                    (route) => false,
                  );
                }
              });
              
              // Show loading while navigation is happening
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Redirecting to dashboard...'),
                    ],
                  ),
                ),
              );

            case AuthStatus.unauthenticated:
              if (kDebugMode) print("User not authenticated, showing login");
              return const LoginScreen();

            case AuthStatus.unknown:
              if (kDebugMode) print("Auth status unknown, showing loading");
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing...'),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
