class EmailValidator {
  static bool isValid(String email) {
    // More comprehensive email validation
    const pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  static String? validate(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValid(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
