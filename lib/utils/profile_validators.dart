class ProfileValidationResult {
  const ProfileValidationResult({this.error});
  final String? error;
  bool get ok => error == null;
}

class ProfileValidators {
  ProfileValidators._();

  static ProfileValidationResult validateName(String name) {
    final t = name.trim();
    if (t.isEmpty) return const ProfileValidationResult(error: 'Name is required');
    if (t.length < 2) {
      return const ProfileValidationResult(error: 'Name must be at least 2 characters');
    }
    return const ProfileValidationResult();
  }

  static ProfileValidationResult validatePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const ProfileValidationResult(error: 'Phone number is required');
    }
    if (digits.length < 10 || digits.length > 13) {
      return const ProfileValidationResult(
        error: 'Enter a valid phone (10–13 digits, e.g. 03001234567)',
      );
    }
    return const ProfileValidationResult();
  }

  static ProfileValidationResult validateAge(String ageText) {
    if (ageText.trim().isEmpty) return const ProfileValidationResult();
    final age = int.tryParse(ageText.trim());
    if (age == null) return const ProfileValidationResult(error: 'Age must be a number');
    if (age < 16 || age > 100) {
      return const ProfileValidationResult(error: 'Age must be between 16 and 100');
    }
    return const ProfileValidationResult();
  }

  static ProfileValidationResult validateDob(String dob) {
    if (dob.trim().isEmpty) return const ProfileValidationResult();
    final m = RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})$').firstMatch(dob.trim());
    if (m == null) {
      return const ProfileValidationResult(error: 'Use date format DD/MM/YYYY');
    }
    final day = int.parse(m.group(1)!);
    final month = int.parse(m.group(2)!);
    final year = int.parse(m.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return const ProfileValidationResult(error: 'Invalid date');
    }
    try {
      final dt = DateTime(year, month, day);
      if (dt.year != year || dt.month != month || dt.day != day) {
        return const ProfileValidationResult(error: 'Invalid date');
      }
      if (dt.isAfter(DateTime.now())) {
        return const ProfileValidationResult(error: 'Date of birth cannot be in the future');
      }
      if (year < 1940) {
        return const ProfileValidationResult(error: 'Please enter a valid year');
      }
    } catch (_) {
      return const ProfileValidationResult(error: 'Invalid date');
    }
    return const ProfileValidationResult();
  }
}
