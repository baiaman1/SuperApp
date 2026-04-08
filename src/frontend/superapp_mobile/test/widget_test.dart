import 'package:flutter_test/flutter_test.dart';
import 'package:superapp_mobile/core/utils/formatters.dart';

void main() {
  test('formats money for KZT', () {
    final formatted = formatMoney(12500, currencyCode: 'KZT');

    expect(formatted, contains('12'));
    expect(formatted, contains('₸'));
  });
}
