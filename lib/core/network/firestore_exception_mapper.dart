class FirestoreExceptionMapper {
  static String map(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('permission-denied')) {
      return 'Permission denied. Check admin/staff access rules.';
    }
    if (text.contains('unavailable')) {
      return 'Network unavailable. Please try again.';
    }
    return 'Unexpected error occurred.';
  }
}
