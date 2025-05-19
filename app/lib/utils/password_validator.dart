class PasswordValidator {
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!password.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password must contain at least one letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static bool isStrong(String password) {
    return password.length >= 8 &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]')) &&
           password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
}
