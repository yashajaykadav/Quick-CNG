class AppValidators {
  /// Validates that a string is not empty
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a full name (alphabets and spaces only, 2-50 chars)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    final nameRegExp = RegExp(r"^[a-zA-Z\s]{2,50}$");
    if (!nameRegExp.hasMatch(value.trim())) {
      if (RegExp(r"[0-9]").hasMatch(value)) {
        return 'Name should not contain numbers';
      }
      if (value.trim().length < 2) {
        return 'Name is too short';
      }
      return 'Please enter a valid name (alphabets only)';
    }
    return null;
  }

  /// Validates an Indian phone number (10 digits, starts with 6-9)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any spaces or dashes if they exist
    final cleanPhone = value.replaceAll(RegExp(r"[\s\-\(\)]"), "");
    
    final phoneRegExp = RegExp(r"^[6-9]\d{9}$");
    if (!phoneRegExp.hasMatch(cleanPhone)) {
      if (cleanPhone.length != 10) {
        return 'Phone number must be exactly 10 digits';
      }
      return 'Please enter a valid Indian mobile number';
    }
    return null;
  }

  /// Validates a standard email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
