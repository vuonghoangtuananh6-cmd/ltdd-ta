// lib/utils/formatters.dart

import 'package:intl/intl.dart';

String formatPrice(double price) {
  if (price >= 10000) {
    var formatter = NumberFormat('#,###', 'en_US');
    String formatted = formatter.format(price).replaceAll(',', '.');
    return '$formattedđ';
  } else {
    return '\$${price.toStringAsFixed(0)}';
  }
}

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
