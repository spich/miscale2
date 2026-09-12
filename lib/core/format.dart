import 'package:intl/intl.dart';

final _oneDecimal = NumberFormat('0.0', 'hr_HR');
final _twoDecimals = NumberFormat('0.00', 'hr_HR');
final _integer = NumberFormat('0', 'hr_HR');

String formatWeight(double kg) => _twoDecimals.format(kg);
String formatDecimal(double value) => _oneDecimal.format(value);
String formatInteger(double value) => _integer.format(value);

String formatDateTime(DateTime moment) =>
    DateFormat('d. MMMM y. HH:mm', 'hr_HR').format(moment);

String formatShortDate(DateTime moment) =>
    DateFormat('d.M.', 'hr_HR').format(moment);

String formatDate(DateTime moment) =>
    DateFormat('d.M.y.', 'hr_HR').format(moment);
