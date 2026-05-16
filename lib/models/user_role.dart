enum UserRole { customer, provider }

extension UserRoleCode on UserRole {
  String get code => name;

  static UserRole? fromCode(String? value) {
    if (value == 'provider') return UserRole.provider;
    if (value == 'customer') return UserRole.customer;
    return null;
  }
}

const kProviderServiceTypes = [
  'Plumber',
  'Electrician',
  'AC Technician',
  'Beautician',
  'Carpenter',
  'Painter',
  'Mason',
  'Generator Repair',
];
