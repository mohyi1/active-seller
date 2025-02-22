import 'package:intl/intl.dart';

class CustomDateTime {
  static String getDate = DateFormat('d MMMM, y', 'ar').format(DateTime.now());
  static String getDayName = DateFormat('EEEE', 'ar').format(DateTime.now());
  static String getLast7Date = DateFormat('EEEE', 'ar')
      .format(DateTime.now().subtract(Duration(days: 7)));
}
