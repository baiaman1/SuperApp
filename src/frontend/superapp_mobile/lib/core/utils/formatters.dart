import 'package:intl/intl.dart';

String formatMoney(
  double value, {
  required String currencyCode,
  bool signed = false,
}) {
  final symbol = switch (currencyCode.toUpperCase()) {
    'KZT' => '₸',
    'USD' => r'$',
    'EUR' => '€',
    'RUB' => '₽',
    _ => currencyCode.toUpperCase(),
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
