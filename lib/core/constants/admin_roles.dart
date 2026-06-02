/// Admin roles for Goo GYM (single gym, multiple admins/staff).
class AdminRoles {
  static const admin = 'admin';
  static const staff = 'staff';

  /// Full access: finance, members, attendance, settings, staff management.
  static bool hasFullAccess(String role) => role == admin;

  /// Staff can operate day-to-day modules but not manage other admins.
  static bool canManageAdmins(String role) => role == admin;
}
