import 'package:intl/intl.dart';

class StringUtils {
  StringUtils._();

  static String formatPriceNumber(num number) {
    var formatter = NumberFormat.decimalPattern('vi');
    return formatter.format(number);
  }
}
