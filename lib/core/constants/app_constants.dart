import 'package:gym_pro_manager/l10n/app_localizations.dart';

class AppConstants {
  static const appNameKey = 'appName';
  static const gymNameKey = 'gymName';

  static const defaultMonthlySubscriptionFeeEgp = 200.0;
  static const defaultSubscriptionDurationDays = 30;
  static const expiringSoonMaxDays = 2;

  static const expenseCategoryKeys = [
    'rent',
    'electricity',
    'water',
    'equipment',
    'maintenance',
    'salaries',
    'marketing',
    'other',
  ];

  /// Maps legacy English Firestore values to keys.
  static const legacyCategoryToKey = {
    'Rent': 'rent',
    'Electricity': 'electricity',
    'Water': 'water',
    'Equipment': 'equipment',
    'Maintenance': 'maintenance',
    'Salaries': 'salaries',
    'Marketing': 'marketing',
    'Other': 'other',
    'إيجار': 'rent',
    'كهرباء': 'electricity',
    'مياه': 'water',
    'معدات': 'equipment',
    'صيانة': 'maintenance',
    'رواتب': 'salaries',
    'تسويق': 'marketing',
    'أخرى': 'other',
  };

  static String normalizeCategoryKey(String value) {
    return legacyCategoryToKey[value] ?? value;
  }

  static String categoryLabel(AppLocalizations l10n, String keyOrValue) {
    final key = normalizeCategoryKey(keyOrValue);
    switch (key) {
      case 'rent':
        return l10n.categoryRent;
      case 'electricity':
        return l10n.categoryElectricity;
      case 'water':
        return l10n.categoryWater;
      case 'equipment':
        return l10n.categoryEquipment;
      case 'maintenance':
        return l10n.categoryMaintenance;
      case 'salaries':
        return l10n.categorySalaries;
      case 'marketing':
        return l10n.categoryMarketing;
      case 'other':
        return l10n.categoryOther;
      default:
        return keyOrValue;
    }
  }
}
