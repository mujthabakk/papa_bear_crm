/// Shop clock is pinned to 11:00 on the real calendar day so the online-booking
/// clash in the V1 plan (Rahul booked at 11:15) is always visible.
DateTime shopNow() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, 11);
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

String attendanceKey(String staffId, DateTime day) =>
    '$staffId-${day.year}-${day.month}-${day.day}';

String digits(String value) => value.replaceAll(RegExp(r'\D'), '');

String inr(num value) {
  final negative = value < 0;
  final whole = value.abs().round();
  final text = whole.toString();
  final grouped = _indianGroup(text);
  return '${negative ? '−' : ''}₹$grouped';
}

String _indianGroup(String digitsOnly) {
  if (digitsOnly.length <= 3) return digitsOnly;
  final last3 = digitsOnly.substring(digitsOnly.length - 3);
  var rest = digitsOnly.substring(0, digitsOnly.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

String clock(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
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

String dayLabel(DateTime time) => '${time.day} ${_months[time.month - 1]}';

String fullDate(DateTime time) =>
    '${_weekdays[time.weekday - 1]}, ${time.day} ${_months[time.month - 1]} ${time.year}';

String monthLabel(DateTime time) => '${_months[time.month - 1]} ${time.year}';

String shortWeekday(DateTime time) => _weekdays[time.weekday - 1].substring(0, 3);

String rupeesInWords(num value) {
  final amount = value.round();
  if (amount == 0) return 'Rupees Zero only';
  return 'Rupees ${_spell(amount)} only';
}

const _ones = [
  '',
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
  'Six',
  'Seven',
  'Eight',
  'Nine',
  'Ten',
  'Eleven',
  'Twelve',
  'Thirteen',
  'Fourteen',
  'Fifteen',
  'Sixteen',
  'Seventeen',
  'Eighteen',
  'Nineteen',
];

const _tens = [
  '',
  '',
  'Twenty',
  'Thirty',
  'Forty',
  'Fifty',
  'Sixty',
  'Seventy',
  'Eighty',
  'Ninety',
];

String _spell(int n) {
  if (n == 0) return '';
  if (n < 20) return _ones[n];
  if (n < 100) {
    final rest = n % 10;
    return '${_tens[n ~/ 10]}${rest == 0 ? '' : ' ${_ones[rest]}'}';
  }
  if (n < 1000) {
    return '${_ones[n ~/ 100]} Hundred ${_spell(n % 100)}'.trim();
  }
  if (n < 100000) {
    return '${_spell(n ~/ 1000)} Thousand ${_spell(n % 1000)}'.trim();
  }
  if (n < 10000000) {
    return '${_spell(n ~/ 100000)} Lakh ${_spell(n % 100000)}'.trim();
  }
  return '${_spell(n ~/ 10000000)} Crore ${_spell(n % 10000000)}'.trim();
}
