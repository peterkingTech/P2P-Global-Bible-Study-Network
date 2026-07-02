/// Form-field validators used across auth and profile screens.
///
/// All validators return `null` on success and a localised error string
/// on failure. Pass these directly to TextFormField.validator.
abstract final class Validators {
  // ── Email ──────────────────────────────────────────────────────────────────

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$', caseSensitive: false);
    if (!re.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  // ── Password ───────────────────────────────────────────────────────────────

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  // ── Display name ───────────────────────────────────────────────────────────

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    if (value.trim().length > 50) return 'Name must be 50 characters or fewer';
    return null;
  }

  // ── Prayer request ─────────────────────────────────────────────────────────

  static String? prayerRequest(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please write your request';
    if (value.trim().length < 10) return 'Request is too short';
    if (value.trim().length > 500) return 'Keep it under 500 characters';
    return null;
  }

  // ── Reflection / journal ───────────────────────────────────────────────────

  static String? reflection(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (value.trim().length > 2000) return 'Keep it under 2000 characters';
    return null;
  }

  // ── Generic required ───────────────────────────────────────────────────────

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
