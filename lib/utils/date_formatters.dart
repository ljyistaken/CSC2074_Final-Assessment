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
