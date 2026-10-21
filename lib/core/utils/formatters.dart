import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _number = NumberFormat.decimalPattern('en');
  static final _date = DateFormat('dd/MM/yyyy');

  static String number(num value) => _number.format(value);

  static String price(num value) => '${number(value)} جم';

  static String date(DateTime value) => _date.format(value);
}
