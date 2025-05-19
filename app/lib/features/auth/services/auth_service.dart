import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print("AuthService Sign In Error: $e");
      throw Exception("An unexpected error occurred during sign in.");
    }
  }

  Future<User?> signUpWithEmailAndPassword(String name, String email, String password, String role) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;
      
      if (firebaseUser != null) {
        if (kDebugMode) print("Firebase user created successfully: ${firebaseUser.uid}");
        
        try {
          // Update display name
          await firebaseUser.updateDisplayName(name);
          if (kDebugMode) print("Display name updated successfully");
          
          // Create user profile in Firestore
          final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
          final userData = {
            'uid': firebaseUser.uid,
            'name': name,
            'email': email,
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
          };
          
          if (kDebugMode) print("Attempting to write user data to Firestore: $userData");
          await userDoc.set(userData);
          if (kDebugMode) print("User profile created successfully in Firestore");
          
          // Verify the document was created
          final docSnapshot = await userDoc.get();
          if (docSnapshot.exists) {
            if (kDebugMode) print("Verification successful: User document exists in Firestore");
          } else {
            if (kDebugMode) print("WARNING: User document not found after creation!");
            throw Exception("Failed to verify user profile creation");
          }
          
        } catch (firestoreError) {
          if (kDebugMode) print("Firestore Error: $firestoreError");
          // Don't fail the entire signup process, but log the error
        }
      }
      return firebaseUser;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print("AuthService Sign Up Error: $e");
      throw Exception("An unexpected error occurred during sign up: $e");
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) print("AuthService Sign Out Error: $e");
      throw Exception("An unexpected error occurred during sign out.");
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      if (kDebugMode) print("AuthService Password Reset Error: $e");
      throw Exception("An unexpected error occurred during password reset.");
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      if (kDebugMode) print("Fetching user profile for UID: $uid");
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        if (kDebugMode) print("User profile found: ${doc.data()}");
        return doc.data() as Map<String, dynamic>;
      }
      if (kDebugMode) print("User profile not found in Firestore for UID: $uid");
      return null;
    } catch (e) {
      if (kDebugMode) print("Error fetching user profile from Firestore: $e");
      return null;
    }
  }
}
