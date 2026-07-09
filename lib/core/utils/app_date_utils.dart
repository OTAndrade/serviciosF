import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static final DateFormat _firebaseDateFormat = DateFormat('dd-MM-yyyy');

  static String firebaseToday() => _firebaseDateFormat.format(DateTime.now());

  static String firebaseDate(DateTime date) => _firebaseDateFormat.format(date);
}
