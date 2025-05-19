import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class UserAuthModel {
  final String uid;
  final String? email;
  final String? firebaseDisplayName;
  final String? name;
  final String? role;

  UserAuthModel({
    required this.uid,
    this.email,
    this.firebaseDisplayName,
    this.name,
    this.role,
  });

  String? get bestName => name ?? firebaseDisplayName;

  factory UserAuthModel.fromFirebaseUser(fb_auth.User user, {String? role, String? name}) {
    return UserAuthModel(
      uid: user.uid,
      email: user.email,
      firebaseDisplayName: user.displayName,
      name: name,
      role: role,
    );
  }
}
