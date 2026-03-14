enum UserRole {
  volunteer,
  support,
  admin;

  String get value {
    switch (this) {
      case UserRole.volunteer:
        return 'volunteer';
      case UserRole.support:
        return 'support';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String? value) {
    if (value == null) return UserRole.volunteer;
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'support':
        return UserRole.support;
      case 'admin':
        return UserRole.admin;
      case 'volunteer':
      default:
        return UserRole.volunteer;
    }
  }
}

