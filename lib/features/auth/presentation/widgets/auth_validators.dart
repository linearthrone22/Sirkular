String? validateRequired(String? value, String message) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? validateName(String? value) {
  return validateRequired(value, 'Name is required');
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePasswordLogin(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  return null;
}

String? validatePasswordNew(String? value) {
  if (value == null || value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
