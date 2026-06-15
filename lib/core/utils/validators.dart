class Validators {
  Validators._();

  // ---------------------------------------------------------------------------
  // Phone number validation (10-digit Indian mobile numbers)
  // ---------------------------------------------------------------------------

  static String? validatePhone(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = val.trim().replaceAll(RegExp(r'\s+'), '');
    // Accept 10-digit numbers, optionally prefixed with +91 or 0
    final stripped = cleaned.startsWith('+91')
        ? cleaned.substring(3)
        : cleaned.startsWith('91') && cleaned.length == 12
            ? cleaned.substring(2)
            : cleaned.startsWith('0')
                ? cleaned.substring(1)
                : cleaned;

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(stripped)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // OTP validation
  // ---------------------------------------------------------------------------

  static String? validateOtp(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'OTP is required';
    }
    final cleaned = val.trim();
    if (cleaned.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(cleaned)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Generic required field validation
  // ---------------------------------------------------------------------------

  static String? validateRequired(String? val, String field) {
    if (val == null || val.trim().isEmpty) {
      return '$field is required';
    }
    if (val.trim().length < 2) {
      return '$field must be at least 2 characters';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Email validation
  // ---------------------------------------------------------------------------

  static String? validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(val.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Coordinate validation
  // ---------------------------------------------------------------------------

  static bool isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    // Reject zero/null island (0,0) which usually means unset
    if (lat == 0.0 && lng == 0.0) return false;
    return true;
  }

  // ---------------------------------------------------------------------------
  // PIN code validation (6-digit Indian postal code)
  // ---------------------------------------------------------------------------

  static String? validatePinCode(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'PIN code is required';
    }
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(val.trim())) {
      return 'Enter a valid 6-digit PIN code';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Name validation
  // ---------------------------------------------------------------------------

  static String? validateName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Name is required';
    }
    if (val.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (val.trim().length > 50) {
      return 'Name must not exceed 50 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(val.trim())) {
      return 'Name can only contain letters, spaces, hyphens and apostrophes';
    }
    return null;
  }
}
