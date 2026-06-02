/// Arabic auth error messages (no BuildContext in cubit).
abstract final class AuthMessages {
  static const permissionDenied =
      'تم رفض الصلاحية. انشر قواعد firestore.rules وأنشئ مستند المسؤول.';
  static const invalidCredentials = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
  static const notInAdmins =
      'هذا الحساب غير مسجّل كمسؤول/موظف. اطلب من مالك النادي إضافتك.';
  static const adminNotCreated = 'لم يُنشأ ملف المسؤول. تحقق من قواعد Firestore.';
  static const notAssignedAdmins = 'هذا الحساب غير مُعيَّن في مجموعة المسؤولين.';
  static const noAdminRole = 'لا يوجد دور مسؤول/موظف لهذا الحساب.';

  static String fromError(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied')) return permissionDenied;
    if (text.contains('user-not-found') || text.contains('wrong-password')) {
      return invalidCredentials;
    }
    return text.replaceFirst('Exception: ', '');
  }
}
