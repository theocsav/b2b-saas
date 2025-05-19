import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_auth_model.dart';
import 'dart:async';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _firebaseUser;
  UserAuthModel? _user;
  AuthStatus _authStatus = AuthStatus.unknown;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<User?>? _authSubscription;
  Timer? _navigationTimer;

  User? get firebaseUser => _firebaseUser;
  UserAuthModel? get user => _user;
  AuthStatus get authStatus => _authStatus;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (kDebugMode) print("Initializing AuthProvider");
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
    final currentUser = await _authService.getCurrentUser();
    await _onAuthStateChanged(currentUser);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (kDebugMode) print("Auth state changed: ${firebaseUser?.uid ?? 'null'}");
    
    _isLoading = true;
    notifyListeners();

    try {
      _firebaseUser = firebaseUser;
      if (firebaseUser == null) {
        if (kDebugMode) print("User signed out");
        _user = null;
        _authStatus = AuthStatus.unauthenticated;
        _errorMessage = null;
      } else {
        if (kDebugMode) print("User signed in: ${firebaseUser.uid}");
        try {
          // Try multiple times to get user profile (in case Firestore needs time)
          Map<String, dynamic>? userProfileData;
          for (int attempt = 0; attempt < 3; attempt++) {
            userProfileData = await _authService.getUserProfile(firebaseUser.uid)
                .timeout(const Duration(seconds: 5));
            
            if (userProfileData != null) break;
            
            if (kDebugMode) print("Attempt ${attempt + 1}: User profile not found, retrying...");
            await Future.delayed(const Duration(milliseconds: 500));
          }
              
          if (userProfileData != null) {
            if (kDebugMode) print("User profile loaded: ${userProfileData['role']}");
            _user = UserAuthModel.fromFirebaseUser(
              firebaseUser,
              role: userProfileData['role'] as String?,
              name: userProfileData['name'] as String?,
            );
          } else {
            if (kDebugMode) print("No user profile found after retries, using basic info");
            _user = UserAuthModel.fromFirebaseUser(
              firebaseUser, 
              role: 'user',
              name: firebaseUser.displayName
            );
          }
          _authStatus = AuthStatus.authenticated;
          _errorMessage = null;
          if (kDebugMode) print("Authentication successful, role: ${_user?.role}");
        } catch (e) {
          if (kDebugMode) print("Error loading user profile: $e");
          _user = UserAuthModel.fromFirebaseUser(firebaseUser);
          _authStatus = AuthStatus.authenticated;
          _errorMessage = null;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Critical error in auth state change: $e");
      _authStatus = AuthStatus.unauthenticated;
      _errorMessage = "Authentication error occurred";
    }

    _isLoading = false;
    if (kDebugMode) print("Auth state update complete: $_authStatus, notifying listeners");
    notifyListeners();
    
    // Force navigation after successful authentication
    if (_authStatus == AuthStatus.authenticated && _user?.role != null) {
      _scheduleNavigationCheck();
    }
  }

  /// Schedule a navigation check to ensure UI updates
  void _scheduleNavigationCheck() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(milliseconds: 500), () {
      if (kDebugMode) print("Navigation check: forcing notification for auth status: $_authStatus");
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    if (kDebugMode) print("Starting sign in for: $email");
    _setLoading(true);
    
    try {
      await _authService.signInWithEmailAndPassword(email, password)
          .timeout(const Duration(seconds: 30));
      if (kDebugMode) print("Sign in successful");
      
      // Wait for auth state to stabilize
      await _waitForAuthState(AuthStatus.authenticated, timeout: const Duration(seconds: 15));
      
      // Force refresh if still not navigated
      if (_authStatus == AuthStatus.authenticated) {
        _triggerAppRefresh();
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("Firebase auth error: ${e.code} - ${e.message}");
      _errorMessage = e.message;
      return false;
    } catch (e) {
      if (kDebugMode) print("Sign in error: $e");
      _errorMessage = "Sign in failed. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String name, String email, String password, String role) async {
    if (kDebugMode) print("Starting sign up for: $email with role: $role");
    _setLoading(true);
    
    try {
      User? newUser = await _authService.signUpWithEmailAndPassword(name, email, password, role)
          .timeout(const Duration(seconds: 30));
      if (kDebugMode) print("Sign up successful: ${newUser?.uid}");
      
      if (newUser != null) {
        // Wait longer for signup since profile needs to be created
        await _waitForAuthState(AuthStatus.authenticated, timeout: const Duration(seconds: 20));
        
        // Additional wait for profile creation if still no role
        if (_user?.role == null || _user?.role == 'user') {
          if (kDebugMode) print("Waiting additional time for profile creation...");
          await Future.delayed(const Duration(seconds: 2));
          
          // Try to refresh user profile
          final profileData = await _authService.getUserProfile(newUser.uid);
          if (profileData != null) {
            _user = UserAuthModel.fromFirebaseUser(
              newUser,
              role: profileData['role'] as String?,
              name: profileData['name'] as String?,
            );
            notifyListeners();
          }
        }
        
        // Force app refresh to ensure navigation
        _triggerAppRefresh();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print("Firebase auth error during signup: ${e.code} - ${e.message}");
      _errorMessage = e.message;
      return false;
    } catch (e) {
      if (kDebugMode) print("Sign up error: $e");
      _errorMessage = "Sign up failed. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    
    try {
      await _authService.sendPasswordResetEmail(email)
          .timeout(const Duration(seconds: 15));
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Failed to send reset email. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    if (kDebugMode) print("Starting sign out");
    _setLoading(true);
    
    try {
      await _authService.signOut().timeout(const Duration(seconds: 10));
      if (kDebugMode) print("Sign out successful");
      
      // Wait for auth state to become unauthenticated
      await _waitForAuthState(AuthStatus.unauthenticated);
    } catch (e) {
      if (kDebugMode) print("Sign out error: $e");
      // Force local state reset
      _firebaseUser = null;
      _user = null;
      _authStatus = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Wait for auth state to reach expected status
  Future<void> _waitForAuthState(AuthStatus expectedStatus, {Duration timeout = const Duration(seconds: 10)}) async {
    if (kDebugMode) print("Waiting for auth state: $expectedStatus");
    
    const checkInterval = Duration(milliseconds: 100);
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      if (_authStatus == expectedStatus) {
        if (kDebugMode) print("Auth state reached: $expectedStatus");
        return;
      }
      await Future.delayed(checkInterval);
    }
    
    if (kDebugMode) print("Timeout waiting for auth state: $expectedStatus (current: $_authStatus)");
  }

  /// Trigger an app refresh by forcing a complete state update
  void _triggerAppRefresh() {
    if (kDebugMode) print("Triggering app refresh...");
    
    // Small delay to ensure all operations complete
    Timer(const Duration(milliseconds: 100), () {
      if (kDebugMode) print("Executing app refresh - notifying all listeners");
      notifyListeners();
      
      // Additional notification after a short delay
      Timer(const Duration(milliseconds: 300), () {
        if (kDebugMode) print("Secondary refresh notification");
        notifyListeners();
      });
    });
  }

  /// Force reload the entire app state
  void forceReload() {
    if (kDebugMode) print("Force reloading app state...");
    _triggerAppRefresh();
  }

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }
}
