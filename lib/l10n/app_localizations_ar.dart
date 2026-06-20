// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Goo Gym';

  @override
  String get gymName => 'Goo Gym';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAttendance => 'الحضور';

  @override
  String get navMembers => 'الأعضاء';

  @override
  String get navFinance => 'المالية';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInSubtitle => 'سجّل الدخول لإدارة النادي';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'you@gym.com';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => '••••••••';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get secureAdminAccess => 'وصول آمن للمسؤولين';

  @override
  String get emailInvalid => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get passwordMinLength => 'ستة أحرف على الأقل';

  @override
  String get createOwnerAdmin => 'إنشاء مسؤول المالك';

  @override
  String get setupAdminSubtitle => 'إعداد صلاحيات كاملة للنادي.';

  @override
  String get account => 'الحساب';

  @override
  String get signedInAccount => 'حسابك المسجّل';

  @override
  String get roleAdminFull => 'الدور: مسؤول (صلاحيات كاملة)';

  @override
  String get firestoreAdminProfile => 'ملف مسؤول في Firestore';

  @override
  String get gymBootstrapConfig => 'إعداد تهيئة النادي';

  @override
  String get createAdminFullAccess => 'إنشاء مسؤول (صلاحيات كاملة)';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get signOutConfirmMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get members => 'الأعضاء';

  @override
  String get visitors => 'الزوار';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get balance => 'الرصيد';

  @override
  String get todayAttendance => 'حضور اليوم';

  @override
  String get trendUp => '+٪٨';

  @override
  String get expiringSoon => 'تنتهي قريباً';

  @override
  String get expiringSoonSubtitle => 'اشتراكات تنتهي خلال ٥ أيام';

  @override
  String get noExpiringSubscriptions => 'لا توجد اشتراكات منتهية قريباً';

  @override
  String get allMembershipsUpToDate => 'جميع الاشتراكات سارية.';

  @override
  String get memberDefault => 'عضو';

  @override
  String get noPhoneOnFile => 'لا يوجد رقم هاتف';

  @override
  String endsOnDaysLeft(String date, int days) {
    return 'تنتهي $date · متبقي $days يوم';
  }

  @override
  String whatsappReminder(String name, String date) {
    return 'مرحباً $name، نذكّرك بأن اشتراك النادي ينتهي في $date. يرجى تجديد العضوية.';
  }

  @override
  String get filterAll => 'الكل';

  @override
  String get filterMembers => 'الأعضاء';

  @override
  String get filterVisitors => 'الزوار';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get addVisitor => 'إضافة زائر';

  @override
  String get registerMemberAttendance => 'تسجيل حضور عضو';

  @override
  String get registerMemberSheetTitle => 'اختيار عضو';

  @override
  String get registerMemberSheetSubtitle => 'تسجيل الحضور لليوم المحدد';

  @override
  String get memberAttendanceRecorded => 'تم تسجيل حضور العضو';

  @override
  String get noMembersToCheckIn => 'لا يوجد أعضاء للتسجيل';

  @override
  String get noCheckInsToday => 'لا يوجد حضور لهذا اليوم';

  @override
  String get noCheckInsSubtitle => 'أضف زائراً أو سجّل حضور عضو.';

  @override
  String get newDailyVisitor => 'زائر يومي جديد';

  @override
  String get visitorSheetSubtitle => 'إنشاء ملف وتسجيل الحضور';

  @override
  String get fullNameRequired => 'الاسم الكامل *';

  @override
  String get phoneOptional => 'الهاتف (اختياري)';

  @override
  String get phoneHint => '+20 100 000 0000';

  @override
  String get sessionPriceRequired => 'سعر الجلسة *';

  @override
  String get amountHint => '0.00';

  @override
  String get saveAndCheckIn => 'حفظ وتسجيل الحضور';

  @override
  String get searchNameOrPhone => 'ابحث بالاسم أو الهاتف';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String get tryDifferentSearch => 'جرّب كلمة بحث أخرى.';

  @override
  String get noMembersYet => 'لا يوجد أعضاء بعد';

  @override
  String get addVisitorsFromAttendance => 'أضف زواراً من تبويب الحضور.';

  @override
  String get addMembersFromButton => 'اضغط الزر أعلاه لإضافة أول عضو.';

  @override
  String get addMember => 'إضافة عضو';

  @override
  String get newMemberSheetTitle => 'عضو جديد';

  @override
  String get newMemberSheetSubtitle => 'تسجيل اشتراك شهري';

  @override
  String get subscriptionStartDate => 'تاريخ بداية الاشتراك';

  @override
  String get discountOptional => 'خصم (اختياري)';

  @override
  String get subscriptionFee => 'رسوم الاشتراك';

  @override
  String get subscriptionFeeRequired => 'رسوم الاشتراك *';

  @override
  String get subscriptionFeeHint => 'رسوم الاشتراك: 200 ج.م.';

  @override
  String get saveMember => 'حفظ';

  @override
  String get memberAddedSuccess => 'تم إضافة العضو بنجاح';

  @override
  String get invalidDiscount => 'الخصم أكبر من رسوم الاشتراك';

  @override
  String get invalidSubscriptionFee => 'أدخل رسوم اشتراك صالحة';

  @override
  String subscriptionSummary(String amount, String date) {
    return 'المبلغ: $amount · ينتهي $date';
  }

  @override
  String get memberProfile => 'ملف العضو';

  @override
  String get noPhone => 'لا يوجد هاتف';

  @override
  String get profileComingSoon =>
      'الملف الكامل وتجديد الاشتراكات وسجل الاشتراكات قريباً.';

  @override
  String get filterSubscriptionFrom => 'من تاريخ';

  @override
  String get filterSubscriptionTo => 'إلى تاريخ';

  @override
  String get clearDateFilter => 'مسح التواريخ';

  @override
  String get subscriptionDetails => 'بيانات الاشتراك';

  @override
  String get subscriptionEndDate => 'تاريخ انتهاء الاشتراك';

  @override
  String get subscriptionAmount => 'قيمة الاشتراك';

  @override
  String get subscriptionStatus => 'الحالة';

  @override
  String get statusActive => 'ساري';

  @override
  String get statusExpired => 'منتهي';

  @override
  String get noActiveSubscription => 'لا يوجد اشتراك نشط';

  @override
  String get renewSubscription => 'تجديد الاشتراك';

  @override
  String get endSubscription => 'إنهاء الاشتراك';

  @override
  String get endSubscriptionConfirmTitle => 'إنهاء الاشتراك؟';

  @override
  String get endSubscriptionConfirmMessage =>
      'سيتم إنهاء اشتراك هذا العضو اليوم ولن يُعتبر عضواً نشطاً.';

  @override
  String get subscriptionEnded => 'تم إنهاء الاشتراك';

  @override
  String get pickNewEndDate => 'اختر تاريخ انتهاء جديد';

  @override
  String get subscriptionRenewed => 'تم تحديث تاريخ انتهاء الاشتراك';

  @override
  String get endDateBeforeStart =>
      'تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية';

  @override
  String daysRemaining(int days) {
    return 'متبقي $days يوم';
  }

  @override
  String get editUser => 'تعديل';

  @override
  String get deleteUser => 'حذف';

  @override
  String get editUserSheetTitle => 'تعديل بيانات المستخدم';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get deleteUserConfirmTitle => 'حذف المستخدم؟';

  @override
  String get deleteUserConfirmMessage =>
      'سيتم حذف المستخدم وسجل حضوره. الاشتراكات المنتهية تبقى في السجلات المالية. تُحذف الاشتراكات النشطة فقط. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get userUpdatedSuccess => 'تم تحديث بيانات المستخدم';

  @override
  String get userDeletedSuccess => 'تم حذف المستخدم';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get memberBadge => 'عضو';

  @override
  String get visitorBadge => 'زائر';

  @override
  String get previousMonth => 'الشهر السابق';

  @override
  String get currentMonth => 'الشهر الحالي';

  @override
  String get expenses => 'المصروفات';

  @override
  String get netProfit => 'صافي الربح';

  @override
  String get chartRev => 'إيراد';

  @override
  String get chartExp => 'مصروف';

  @override
  String get chartProfit => 'ربح';

  @override
  String get chartBal => 'رصيد';

  @override
  String get noExpensesThisMonth => 'لا مصروفات هذا الشهر';

  @override
  String get noExpensesSubtitle =>
      'اضغط الزر أعلاه لتسجيل الإيجار والمرافق وغيرها.';

  @override
  String get expenseAddedSuccess => 'تم تسجيل المصروف بنجاح';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get expenseRecordedMonth => 'يُسجّل للشهر الحالي';

  @override
  String get expenseTitle => 'العنوان';

  @override
  String get expenseTitleHint => 'إيجار شهري';

  @override
  String get category => 'التصنيف';

  @override
  String get amount => 'المبلغ';

  @override
  String get saveExpense => 'حفظ المصروف';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String get categoryRent => 'إيجار';

  @override
  String get categoryElectricity => 'كهرباء';

  @override
  String get categoryWater => 'مياه';

  @override
  String get categoryEquipment => 'معدات';

  @override
  String get categoryMaintenance => 'صيانة';

  @override
  String get categorySalaries => 'رواتب';

  @override
  String get categoryMarketing => 'تسويق';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get enableExpiryNotifications => 'تفعيل تنبيهات انتهاء الاشتراك';

  @override
  String get expiryNotificationsSubtitle =>
      'يُدار عبر Firebase Cloud Messaging';

  @override
  String get language => 'اللغة';

  @override
  String get languageArabic => 'العربية (مصر)';

  @override
  String get errorPermissionDenied =>
      'تم رفض الصلاحية. انشر قواعد firestore.rules وأنشئ مستند المسؤول.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorNotInAdmins =>
      'هذا الحساب غير مسجّل كمسؤول/موظف. اطلب من مالك النادي إضافتك.';

  @override
  String get errorAdminNotCreated =>
      'لم يُنشأ ملف المسؤول. تحقق من قواعد Firestore.';

  @override
  String get errorNotAssignedAdmins =>
      'هذا الحساب غير مُعيَّن في مجموعة المسؤولين.';

  @override
  String get errorNoAdminRole => 'لا يوجد دور مسؤول/موظف لهذا الحساب.';

  @override
  String get validationEnterValidEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get validationMinPassword => '٦ أحرف على الأقل';

  @override
  String get openInMembersTab => 'عرض في تبويب الأعضاء';

  @override
  String get openInAttendanceTab => 'عرض في تبويب الحضور';

  @override
  String get openInFinanceTab => 'عرض في تبويب المالية';

  @override
  String get revenueFromSubscriptions => 'اشتراكات الأعضاء';

  @override
  String get revenueFromVisitorSessions => 'جلسات الزوار (اليوم)';

  @override
  String get memberSessionsToday => 'حضور الأعضاء المدفوع (اليوم)';

  @override
  String get subscriptionCount => 'عدد الاشتراكات';

  @override
  String get sessionCount => 'عدد الجلسات';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get totalExpenses => 'إجمالي المصروفات';

  @override
  String get netBalance => 'صافي الرصيد';

  @override
  String get revenueBreakdownSubtitle =>
      'إجمالي الاشتراكات يشمل جميع سجلات الاشتراك في النظام. إيراد الزوار من جلسات اليوم فقط.';

  @override
  String get allSubscriptions => 'جميع الاشتراكات';

  @override
  String get todayPaidSessions => 'جلسات اليوم المدفوعة';

  @override
  String get monthExpenses => 'مصروفات الشهر';

  @override
  String get biometricPromptShell => 'تحقق من هويتك لفتح التطبيق';

  @override
  String get biometricPromptFinanceAmounts =>
      'تحقق من هويتك لعرض المبالغ المالية';

  @override
  String get showFinanceAmounts => 'عرض المبالغ';

  @override
  String get financeAmountsHidden => 'المبالغ مخفية للخصوصية';

  @override
  String get financeChartHidden => 'الرسم البياني مخفي حتى عرض المبالغ';

  @override
  String get lockScreenTitle => 'المحتوى مقفل';

  @override
  String get lockScreenSubtitle =>
      'استخدم بصمة الإصبع أو كلمة مرور حسابك للمتابعة';

  @override
  String get unlockWithBiometric => 'فتح بالبصمة';

  @override
  String get unlockWithPassword => 'فتح بكلمة المرور';

  @override
  String get reenterPasswordTitle => 'تأكيد كلمة المرور';

  @override
  String get reenterPasswordSubtitle => 'أدخل كلمة مرور حسابك للمتابعة';

  @override
  String get biometricUnavailable => 'البصمة غير متاحة على هذا الجهاز';

  @override
  String get biometricFailedTryAgain =>
      'تعذّر التحقق بالبصمة. حاول مرة أخرى أو استخدم كلمة المرور.';

  @override
  String get gender => 'الجنس';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get maleMembers => 'أعضاء ذكور';

  @override
  String get femaleMembers => 'أعضاء إناث';

  @override
  String get filterGenderAll => 'كل الأجناس';

  @override
  String get maleIncome => 'إيراد الذكور';

  @override
  String get femaleIncome => 'إيراد الإناث';

  @override
  String get migrateGenderToMale => 'تعيين الجنس (ذكر) للأعضاء الحاليين';

  @override
  String get migrateGenderConfirmTitle => 'تحديث بيانات الجنس؟';

  @override
  String get migrateGenderConfirmMessage =>
      'سيتم تعيين جميع المستخدمين الحاليين كـ «ذكر».';

  @override
  String get themeLight => 'الوضع الفاتح';

  @override
  String get themeDark => 'الوضع الداكن';

  @override
  String migrateGenderSuccess(int count) {
    return 'تم تحديث $count مستخدم';
  }
}
