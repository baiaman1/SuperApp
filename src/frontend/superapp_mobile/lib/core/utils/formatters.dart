import 'package:intl/intl.dart';

String formatMoney(
  double value, {
  required String currencyCode,
  bool signed = false,
}) {
  final normalizedCode = switch (currencyCode.trim().toUpperCase()) {
    '' || 'KZT' => 'KGS',
    final code => code,
  };

  final symbol = switch (normalizedCode) {
    'KGS' => 'сом',
    'USD' => r'$',
    'EUR' => '€',
    'RUB' => '₽',
    _ => normalizedCode,
  };

  final formatter = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: symbol,
    decimalDigits: value % 1 == 0 ? 0 : 2,
  );
  final formatted = formatter.format(value.abs());

  if (!signed) {
    return formatted;
  }

  final sign = value >= 0 ? '+' : '-';
  return '$sign$formatted';
}

String formatShortDate(DateTime value) {
  return DateFormat('d MMM, HH:mm', 'ru_RU').format(value);
}

String formatCompactDate(DateTime value) {
  return DateFormat('d MMM', 'ru_RU').format(value);
}
