import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/dashboard/screens/admin/admin_dashboard_screen.dart';
import '../features/dashboard/screens/therapist/therapist_dashboard_screen.dart';
import '../features/auth/providers/auth_provider.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';
  static const String adminDashboardRoute = '/admin/dashboard';
  static const String therapistDashboardRoute = '/therapist/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (kDebugMode) print("Generating route for: ${settings.name}");
    
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
        
      case signupRoute:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
        
      case forgotPasswordRoute:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
        
      case homeRoute:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Loading Home...")),
          ),
          settings: settings,
        );
        
      case adminDashboardRoute:
        return MaterialPageRoute(
          builder: (context) => Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              // Simple auth check - redirect if not authenticated
              if (authProvider.authStatus != AuthStatus.authenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                });
                return const Scaffold(
                  body: Center(
                    child: Text('Redirecting to login...'),
                  ),
                );
              }
              return const AdminDashboardScreen();
            },
          ),
          settings: settings,
        );
        
      case therapistDashboardRoute:
        return MaterialPageRoute(
          builder: (context) => Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              // Simple auth check - redirect if not authenticated
              if (authProvider.authStatus != AuthStatus.authenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                });
                return const Scaffold(
                  body: Center(
                    child: Text('Redirecting to login...'),
                  ),
                );
              }
              return const TherapistDashboardScreen();
            },
          ),
          settings: settings,
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
