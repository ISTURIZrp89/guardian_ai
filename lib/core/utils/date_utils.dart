import 'package:intl/intl.dart';

final class DateUtils {
  DateUtils._();

  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _storageFormat =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  static final DateFormat _clinicalDateFormat = DateFormat('dd/MMM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');

  static String formatDisplay(DateTime date) => _displayFormat.format(date);
  static String formatStorage(DateTime date) => _storageFormat.format(date);
  static String formatClinical(DateTime date) =>
      _clinicalDateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDayMonth(DateTime date) => _dayMonthFormat.format(date);

  static DateTime? parseStorage(String date) {
    try {
      return _storageFormat.parse(date);
    } catch (_) {
      return null;
    }
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years > 0) return '$years años';
    return '$months meses';
  }
}
