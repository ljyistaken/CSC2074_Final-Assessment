const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String fullDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]} ${date.year}';

String monthName(int month) => _months[month - 1];

String timeLabel(int hour) {
  final value = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  final period = hour >= 12 ? 'PM' : 'AM';
  return '${value.toString().padLeft(2, '0')}:00 $period';
}

/// Renders a stored party-size int back into the same label shown on the
/// selection chips (see select_time_party_screen.dart / modify_booking_
/// screen.dart), so "5+" isn't silently displayed as a plain "5" anywhere
/// a booking's party size is shown as text.
String partySizeLabel(int size) {
  if (size >= 5) return '5+ People';
  return size == 1 ? '1 Person' : '$size People';
}