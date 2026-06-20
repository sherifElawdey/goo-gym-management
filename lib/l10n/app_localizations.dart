import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'Goo Gym'**
  String get appName;

  /// No description provided for @gymName.
  ///
  /// In ar, this message translates to:
  /// **'Goo Gym'**
  String get gymName;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get navAttendance;

  /// No description provided for @navMembers.
  ///
  /// In ar, this message translates to:
  /// **'الأعضاء'**
  String get navMembers;

  /// No description provided for @navFinance.
  ///
  /// In ar, this message translates to:
  /// **'المالية'**
  String get navFinance;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لإدارة النادي'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In ar, this message translates to:
  /// **'you@gym.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @secureAdminAccess.
  ///
  /// In ar, this message translates to:
  /// **'وصول آمن للمسؤولين'**
  String get secureAdminAccess;

  /// No description provided for @emailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريداً إلكترونياً صالحاً'**
  String get emailInvalid;

  /// No description provided for @passwordMinLength.
  ///
  /// In ar, this message translates to:
  /// **'ستة أحرف على الأقل'**
  String get passwordMinLength;

  /// No description provided for @createOwnerAdmin.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مسؤول المالك'**
  String get createOwnerAdmin;

  /// No description provided for @setupAdminSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إعداد صلاحيات كاملة للنادي.'**
  String get setupAdminSubtitle;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @signedInAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابك المسجّل'**
  String get signedInAccount;

  /// No description provided for @roleAdminFull.
  ///
  /// In ar, this message translates to:
  /// **'الدور: مسؤول (صلاحيات كاملة)'**
  String get roleAdminFull;

  /// No description provided for @firestoreAdminProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملف مسؤول في Firestore'**
  String get firestoreAdminProfile;

  /// No description provided for @gymBootstrapConfig.
  ///
  /// In ar, this message translates to:
  /// **'إعداد تهيئة النادي'**
  String get gymBootstrapConfig;

  /// No description provided for @createAdminFullAccess.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مسؤول (صلاحيات كاملة)'**
  String get createAdminFullAccess;

  /// No description provided for @signOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج؟'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج؟'**
  String get signOutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodEvening;

  /// No description provided for @members.
  ///
  /// In ar, this message translates to:
  /// **'الأعضاء'**
  String get members;

  /// No description provided for @visitors.
  ///
  /// In ar, this message translates to:
  /// **'الزوار'**
  String get visitors;

  /// No description provided for @revenue.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات'**
  String get revenue;

  /// No description provided for @balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get balance;

  /// No description provided for @todayAttendance.
  ///
  /// In ar, this message translates to:
  /// **'حضور اليوم'**
  String get todayAttendance;

  /// No description provided for @trendUp.
  ///
  /// In ar, this message translates to:
  /// **'+٪٨'**
  String get trendUp;

  /// No description provided for @expiringSoon.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي قريباً'**
  String get expiringSoon;

  /// No description provided for @expiringSoonSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اشتراكات تنتهي خلال ٥ أيام'**
  String get expiringSoonSubtitle;

  /// No description provided for @noExpiringSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اشتراكات منتهية قريباً'**
  String get noExpiringSubscriptions;

  /// No description provided for @allMembershipsUpToDate.
  ///
  /// In ar, this message translates to:
  /// **'جميع الاشتراكات سارية.'**
  String get allMembershipsUpToDate;

  /// No description provided for @memberDefault.
  ///
  /// In ar, this message translates to:
  /// **'عضو'**
  String get memberDefault;

  /// No description provided for @noPhoneOnFile.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم هاتف'**
  String get noPhoneOnFile;

  /// No description provided for @endsOnDaysLeft.
  ///
  /// In ar, this message translates to:
  /// **'تنتهي {date} · متبقي {days} يوم'**
  String endsOnDaysLeft(String date, int days);

  /// No description provided for @whatsappReminder.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً {name}، نذكّرك بأن اشتراك النادي ينتهي في {date}. يرجى تجديد العضوية.'**
  String whatsappReminder(String name, String date);

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterMembers.
  ///
  /// In ar, this message translates to:
  /// **'الأعضاء'**
  String get filterMembers;

  /// No description provided for @filterVisitors.
  ///
  /// In ar, this message translates to:
  /// **'الزوار'**
  String get filterVisitors;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @addVisitor.
  ///
  /// In ar, this message translates to:
  /// **'إضافة زائر'**
  String get addVisitor;

  /// No description provided for @registerMemberAttendance.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل حضور عضو'**
  String get registerMemberAttendance;

  /// No description provided for @registerMemberSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختيار عضو'**
  String get registerMemberSheetTitle;

  /// No description provided for @registerMemberSheetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الحضور لليوم المحدد'**
  String get registerMemberSheetSubtitle;

  /// No description provided for @memberAttendanceRecorded.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل حضور العضو'**
  String get memberAttendanceRecorded;

  /// No description provided for @noMembersToCheckIn.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أعضاء للتسجيل'**
  String get noMembersToCheckIn;

  /// No description provided for @noCheckInsToday.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد حضور لهذا اليوم'**
  String get noCheckInsToday;

  /// No description provided for @noCheckInsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف زائراً أو سجّل حضور عضو.'**
  String get noCheckInsSubtitle;

  /// No description provided for @newDailyVisitor.
  ///
  /// In ar, this message translates to:
  /// **'زائر يومي جديد'**
  String get newDailyVisitor;

  /// No description provided for @visitorSheetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء ملف وتسجيل الحضور'**
  String get visitorSheetSubtitle;

  /// No description provided for @fullNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل *'**
  String get fullNameRequired;

  /// No description provided for @phoneOptional.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف (اختياري)'**
  String get phoneOptional;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'+20 100 000 0000'**
  String get phoneHint;

  /// No description provided for @sessionPriceRequired.
  ///
  /// In ar, this message translates to:
  /// **'سعر الجلسة *'**
  String get sessionPriceRequired;

  /// No description provided for @amountHint.
  ///
  /// In ar, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @saveAndCheckIn.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وتسجيل الحضور'**
  String get saveAndCheckIn;

  /// No description provided for @searchNameOrPhone.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو الهاتف'**
  String get searchNameOrPhone;

  /// No description provided for @noResultsFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResultsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة بحث أخرى.'**
  String get tryDifferentSearch;

  /// No description provided for @noMembersYet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أعضاء بعد'**
  String get noMembersYet;

  /// No description provided for @addVisitorsFromAttendance.
  ///
  /// In ar, this message translates to:
  /// **'أضف زواراً من تبويب الحضور.'**
  String get addVisitorsFromAttendance;

  /// No description provided for @addMembersFromButton.
  ///
  /// In ar, this message translates to:
  /// **'اضغط الزر أعلاه لإضافة أول عضو.'**
  String get addMembersFromButton;

  /// No description provided for @addMember.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عضو'**
  String get addMember;

  /// No description provided for @newMemberSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'عضو جديد'**
  String get newMemberSheetTitle;

  /// No description provided for @newMemberSheetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل اشتراك شهري'**
  String get newMemberSheetSubtitle;

  /// No description provided for @subscriptionStartDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ بداية الاشتراك'**
  String get subscriptionStartDate;

  /// No description provided for @discountOptional.
  ///
  /// In ar, this message translates to:
  /// **'خصم (اختياري)'**
  String get discountOptional;

  /// No description provided for @subscriptionFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الاشتراك'**
  String get subscriptionFee;

  /// No description provided for @subscriptionFeeRequired.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الاشتراك *'**
  String get subscriptionFeeRequired;

  /// No description provided for @subscriptionFeeHint.
  ///
  /// In ar, this message translates to:
  /// **'رسوم الاشتراك: 200 ج.م.'**
  String get subscriptionFeeHint;

  /// No description provided for @saveMember.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saveMember;

  /// No description provided for @memberAddedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة العضو بنجاح'**
  String get memberAddedSuccess;

  /// No description provided for @invalidDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم أكبر من رسوم الاشتراك'**
  String get invalidDiscount;

  /// No description provided for @invalidSubscriptionFee.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رسوم اشتراك صالحة'**
  String get invalidSubscriptionFee;

  /// No description provided for @subscriptionSummary.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ: {amount} · ينتهي {date}'**
  String subscriptionSummary(String amount, String date);

  /// No description provided for @memberProfile.
  ///
  /// In ar, this message translates to:
  /// **'ملف العضو'**
  String get memberProfile;

  /// No description provided for @noPhone.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد هاتف'**
  String get noPhone;

  /// No description provided for @profileComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'الملف الكامل وتجديد الاشتراكات وسجل الاشتراكات قريباً.'**
  String get profileComingSoon;

  /// No description provided for @filterSubscriptionFrom.
  ///
  /// In ar, this message translates to:
  /// **'من تاريخ'**
  String get filterSubscriptionFrom;

  /// No description provided for @filterSubscriptionTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى تاريخ'**
  String get filterSubscriptionTo;

  /// No description provided for @clearDateFilter.
  ///
  /// In ar, this message translates to:
  /// **'مسح التواريخ'**
  String get clearDateFilter;

  /// No description provided for @subscriptionDetails.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الاشتراك'**
  String get subscriptionDetails;

  /// No description provided for @subscriptionEndDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ انتهاء الاشتراك'**
  String get subscriptionEndDate;

  /// No description provided for @subscriptionAmount.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الاشتراك'**
  String get subscriptionAmount;

  /// No description provided for @subscriptionStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get subscriptionStatus;

  /// No description provided for @statusActive.
  ///
  /// In ar, this message translates to:
  /// **'ساري'**
  String get statusActive;

  /// No description provided for @statusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get statusExpired;

  /// No description provided for @noActiveSubscription.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اشتراك نشط'**
  String get noActiveSubscription;

  /// No description provided for @renewSubscription.
  ///
  /// In ar, this message translates to:
  /// **'تجديد الاشتراك'**
  String get renewSubscription;

  /// No description provided for @endSubscription.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الاشتراك'**
  String get endSubscription;

  /// No description provided for @endSubscriptionConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الاشتراك؟'**
  String get endSubscriptionConfirmTitle;

  /// No description provided for @endSubscriptionConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنهاء اشتراك هذا العضو اليوم ولن يُعتبر عضواً نشطاً.'**
  String get endSubscriptionConfirmMessage;

  /// No description provided for @subscriptionEnded.
  ///
  /// In ar, this message translates to:
  /// **'تم إنهاء الاشتراك'**
  String get subscriptionEnded;

  /// No description provided for @pickNewEndDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخ انتهاء جديد'**
  String get pickNewEndDate;

  /// No description provided for @subscriptionRenewed.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث تاريخ انتهاء الاشتراك'**
  String get subscriptionRenewed;

  /// No description provided for @endDateBeforeStart.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية'**
  String get endDateBeforeStart;

  /// No description provided for @daysRemaining.
  ///
  /// In ar, this message translates to:
  /// **'متبقي {days} يوم'**
  String daysRemaining(int days);

  /// No description provided for @editUser.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteUser;

  /// No description provided for @editUserSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات المستخدم'**
  String get editUserSheetTitle;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveChanges;

  /// No description provided for @deleteUserConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المستخدم؟'**
  String get deleteUserConfirmTitle;

  /// No description provided for @deleteUserConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف المستخدم وسجل حضوره. الاشتراكات المنتهية تبقى في السجلات المالية. تُحذف الاشتراكات النشطة فقط. لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteUserConfirmMessage;

  /// No description provided for @userUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بيانات المستخدم'**
  String get userUpdatedSuccess;

  /// No description provided for @userDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المستخدم'**
  String get userDeletedSuccess;

  /// No description provided for @nameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get nameRequired;

  /// No description provided for @memberBadge.
  ///
  /// In ar, this message translates to:
  /// **'عضو'**
  String get memberBadge;

  /// No description provided for @visitorBadge.
  ///
  /// In ar, this message translates to:
  /// **'زائر'**
  String get visitorBadge;

  /// No description provided for @previousMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر السابق'**
  String get previousMonth;

  /// No description provided for @currentMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الحالي'**
  String get currentMonth;

  /// No description provided for @expenses.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات'**
  String get expenses;

  /// No description provided for @netProfit.
  ///
  /// In ar, this message translates to:
  /// **'صافي الربح'**
  String get netProfit;

  /// No description provided for @chartRev.
  ///
  /// In ar, this message translates to:
  /// **'إيراد'**
  String get chartRev;

  /// No description provided for @chartExp.
  ///
  /// In ar, this message translates to:
  /// **'مصروف'**
  String get chartExp;

  /// No description provided for @chartProfit.
  ///
  /// In ar, this message translates to:
  /// **'ربح'**
  String get chartProfit;

  /// No description provided for @chartBal.
  ///
  /// In ar, this message translates to:
  /// **'رصيد'**
  String get chartBal;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In ar, this message translates to:
  /// **'لا مصروفات هذا الشهر'**
  String get noExpensesThisMonth;

  /// No description provided for @noExpensesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اضغط الزر أعلاه لتسجيل الإيجار والمرافق وغيرها.'**
  String get noExpensesSubtitle;

  /// No description provided for @expenseAddedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل المصروف بنجاح'**
  String get expenseAddedSuccess;

  /// No description provided for @addExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف'**
  String get addExpense;

  /// No description provided for @expenseRecordedMonth.
  ///
  /// In ar, this message translates to:
  /// **'يُسجّل للشهر الحالي'**
  String get expenseRecordedMonth;

  /// No description provided for @expenseTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get expenseTitle;

  /// No description provided for @expenseTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'إيجار شهري'**
  String get expenseTitleHint;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'التصنيف'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// No description provided for @saveExpense.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المصروف'**
  String get saveExpense;

  /// No description provided for @somethingWentWrong.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get tryAgain;

  /// No description provided for @categoryRent.
  ///
  /// In ar, this message translates to:
  /// **'إيجار'**
  String get categoryRent;

  /// No description provided for @categoryElectricity.
  ///
  /// In ar, this message translates to:
  /// **'كهرباء'**
  String get categoryElectricity;

  /// No description provided for @categoryWater.
  ///
  /// In ar, this message translates to:
  /// **'مياه'**
  String get categoryWater;

  /// No description provided for @categoryEquipment.
  ///
  /// In ar, this message translates to:
  /// **'معدات'**
  String get categoryEquipment;

  /// No description provided for @categoryMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة'**
  String get categoryMaintenance;

  /// No description provided for @categorySalaries.
  ///
  /// In ar, this message translates to:
  /// **'رواتب'**
  String get categorySalaries;

  /// No description provided for @categoryMarketing.
  ///
  /// In ar, this message translates to:
  /// **'تسويق'**
  String get categoryMarketing;

  /// No description provided for @categoryOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get categoryOther;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @enableExpiryNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل تنبيهات انتهاء الاشتراك'**
  String get enableExpiryNotifications;

  /// No description provided for @expiryNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يُدار عبر Firebase Cloud Messaging'**
  String get expiryNotificationsSubtitle;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية (مصر)'**
  String get languageArabic;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الصلاحية. انشر قواعد firestore.rules وأنشئ مستند المسؤول.'**
  String get errorPermissionDenied;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorNotInAdmins.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب غير مسجّل كمسؤول/موظف. اطلب من مالك النادي إضافتك.'**
  String get errorNotInAdmins;

  /// No description provided for @errorAdminNotCreated.
  ///
  /// In ar, this message translates to:
  /// **'لم يُنشأ ملف المسؤول. تحقق من قواعد Firestore.'**
  String get errorAdminNotCreated;

  /// No description provided for @errorNotAssignedAdmins.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب غير مُعيَّن في مجموعة المسؤولين.'**
  String get errorNotAssignedAdmins;

  /// No description provided for @errorNoAdminRole.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد دور مسؤول/موظف لهذا الحساب.'**
  String get errorNoAdminRole;

  /// No description provided for @validationEnterValidEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريداً إلكترونياً صالحاً'**
  String get validationEnterValidEmail;

  /// No description provided for @validationMinPassword.
  ///
  /// In ar, this message translates to:
  /// **'٦ أحرف على الأقل'**
  String get validationMinPassword;

  /// No description provided for @openInMembersTab.
  ///
  /// In ar, this message translates to:
  /// **'عرض في تبويب الأعضاء'**
  String get openInMembersTab;

  /// No description provided for @openInAttendanceTab.
  ///
  /// In ar, this message translates to:
  /// **'عرض في تبويب الحضور'**
  String get openInAttendanceTab;

  /// No description provided for @openInFinanceTab.
  ///
  /// In ar, this message translates to:
  /// **'عرض في تبويب المالية'**
  String get openInFinanceTab;

  /// No description provided for @revenueFromSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'اشتراكات الأعضاء'**
  String get revenueFromSubscriptions;

  /// No description provided for @revenueFromVisitorSessions.
  ///
  /// In ar, this message translates to:
  /// **'جلسات الزوار (اليوم)'**
  String get revenueFromVisitorSessions;

  /// No description provided for @memberSessionsToday.
  ///
  /// In ar, this message translates to:
  /// **'حضور الأعضاء المدفوع (اليوم)'**
  String get memberSessionsToday;

  /// No description provided for @subscriptionCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الاشتراكات'**
  String get subscriptionCount;

  /// No description provided for @sessionCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الجلسات'**
  String get sessionCount;

  /// No description provided for @totalRevenue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات'**
  String get totalRevenue;

  /// No description provided for @totalExpenses.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصروفات'**
  String get totalExpenses;

  /// No description provided for @netBalance.
  ///
  /// In ar, this message translates to:
  /// **'صافي الرصيد'**
  String get netBalance;

  /// No description provided for @revenueBreakdownSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الاشتراكات يشمل جميع سجلات الاشتراك في النظام. إيراد الزوار من جلسات اليوم فقط.'**
  String get revenueBreakdownSubtitle;

  /// No description provided for @allSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'جميع الاشتراكات'**
  String get allSubscriptions;

  /// No description provided for @todayPaidSessions.
  ///
  /// In ar, this message translates to:
  /// **'جلسات اليوم المدفوعة'**
  String get todayPaidSessions;

  /// No description provided for @monthExpenses.
  ///
  /// In ar, this message translates to:
  /// **'مصروفات الشهر'**
  String get monthExpenses;

  /// No description provided for @biometricPromptShell.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من هويتك لفتح التطبيق'**
  String get biometricPromptShell;

  /// No description provided for @biometricPromptFinanceAmounts.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من هويتك لعرض المبالغ المالية'**
  String get biometricPromptFinanceAmounts;

  /// No description provided for @showFinanceAmounts.
  ///
  /// In ar, this message translates to:
  /// **'عرض المبالغ'**
  String get showFinanceAmounts;

  /// No description provided for @financeAmountsHidden.
  ///
  /// In ar, this message translates to:
  /// **'المبالغ مخفية للخصوصية'**
  String get financeAmountsHidden;

  /// No description provided for @financeChartHidden.
  ///
  /// In ar, this message translates to:
  /// **'الرسم البياني مخفي حتى عرض المبالغ'**
  String get financeChartHidden;

  /// No description provided for @lockScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحتوى مقفل'**
  String get lockScreenTitle;

  /// No description provided for @lockScreenSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدم بصمة الإصبع أو كلمة مرور حسابك للمتابعة'**
  String get lockScreenSubtitle;

  /// No description provided for @unlockWithBiometric.
  ///
  /// In ar, this message translates to:
  /// **'فتح بالبصمة'**
  String get unlockWithBiometric;

  /// No description provided for @unlockWithPassword.
  ///
  /// In ar, this message translates to:
  /// **'فتح بكلمة المرور'**
  String get unlockWithPassword;

  /// No description provided for @reenterPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get reenterPasswordTitle;

  /// No description provided for @reenterPasswordSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة مرور حسابك للمتابعة'**
  String get reenterPasswordSubtitle;

  /// No description provided for @biometricUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'البصمة غير متاحة على هذا الجهاز'**
  String get biometricUnavailable;

  /// No description provided for @biometricFailedTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحقق بالبصمة. حاول مرة أخرى أو استخدم كلمة المرور.'**
  String get biometricFailedTryAgain;

  /// No description provided for @gender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get gender;

  /// No description provided for @genderMale.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get genderFemale;

  /// No description provided for @maleMembers.
  ///
  /// In ar, this message translates to:
  /// **'أعضاء ذكور'**
  String get maleMembers;

  /// No description provided for @femaleMembers.
  ///
  /// In ar, this message translates to:
  /// **'أعضاء إناث'**
  String get femaleMembers;

  /// No description provided for @filterGenderAll.
  ///
  /// In ar, this message translates to:
  /// **'كل الأجناس'**
  String get filterGenderAll;

  /// No description provided for @maleIncome.
  ///
  /// In ar, this message translates to:
  /// **'إيراد الذكور'**
  String get maleIncome;

  /// No description provided for @femaleIncome.
  ///
  /// In ar, this message translates to:
  /// **'إيراد الإناث'**
  String get femaleIncome;

  /// No description provided for @migrateGenderToMale.
  ///
  /// In ar, this message translates to:
  /// **'تعيين الجنس (ذكر) للأعضاء الحاليين'**
  String get migrateGenderToMale;

  /// No description provided for @migrateGenderConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث بيانات الجنس؟'**
  String get migrateGenderConfirmTitle;

  /// No description provided for @migrateGenderConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تعيين جميع المستخدمين الحاليين كـ «ذكر».'**
  String get migrateGenderConfirmMessage;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get themeDark;

  /// No description provided for @migrateGenderSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث {count} مستخدم'**
  String migrateGenderSuccess(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
