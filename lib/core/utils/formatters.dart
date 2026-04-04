import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0, 
  );

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
}