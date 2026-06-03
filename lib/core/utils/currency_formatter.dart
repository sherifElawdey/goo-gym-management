import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'ج.م.',
    decimalDigits: 2,
  );

  static String format(num value) => _currency.format(value);

  static String formatSensitive(num value, {required bool visible}) =>
      visible ? format(value) : '*****';
}
