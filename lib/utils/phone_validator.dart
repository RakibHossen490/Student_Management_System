// Utility functions for phone number validation and normalization
class PhoneValidator {
  // Normalize phone number by removing all non-digit characters
  static String normalizePhoneNumber(String phone) {
    // Remove all non-digit characters
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // Validate phone number (minimum 10 digits)
  static bool isValidPhoneNumber(String phone) {
    final normalized = normalizePhoneNumber(phone);
    return normalized.length >= 10;
  }

  // Format phone number for display (optional, for better UX)
  static String formatPhoneNumber(String phone) {
    final normalized = normalizePhoneNumber(phone);
    if (normalized.isEmpty) return '';
    if (normalized.length == 10) {
      return '${normalized.substring(0, 3)}-${normalized.substring(3, 6)}-${normalized.substring(6)}';
    }
    return normalized;
  }

  // Get error message for invalid phone
  static String getPhoneErrorMessage(String phone) {
    if (phone.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhoneNumber(phone)) {
      return 'Please enter at least 10 digits'; 
    }
    return '';
  }
}
