/// Parses numeric input that may use Western or Arabic-Indic digits.
double? parseLocalizedDouble(String input) {
  final normalized = _normalizeNumericString(input.trim());
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String _normalizeNumericString(String value) {
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  const easternArabic = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();

  for (var i = 0; i < value.length; i++) {
    final char = value[i];
    final arabicIndex = arabicIndic.indexOf(char);
    if (arabicIndex >= 0) {
      buffer.write(arabicIndex);
      continue;
    }
    final easternIndex = easternArabic.indexOf(char);
    if (easternIndex >= 0) {
      buffer.write(easternIndex);
      continue;
    }
    if (char == '٫') {
      buffer.write('.');
      continue;
    }
    if (char == '٬' || char == '،') {
      continue;
    }
    buffer.write(char);
  }

  var result = buffer.toString().replaceAll(' ', '');
  if (!result.contains('.') && result.contains(',')) {
    result = result.replaceAll(',', '.');
  } else {
    result = result.replaceAll(',', '');
  }
  return result;
}
