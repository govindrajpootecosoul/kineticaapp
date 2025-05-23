import 'package:intl/intl.dart';

String formatNumberStringWithComma(String numberString) {
  final number = double.tryParse(numberString.replaceAll(",", "")) ?? 0;
  final formatter = NumberFormat.decimalPattern('en_US');
  return formatter.format(number);
}
