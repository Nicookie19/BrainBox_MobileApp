class Clock {
  final DateTime Function() now;

  const Clock({required this.now});

  static const Clock real = Clock(now: DateTime.now);

  static Clock fixed(DateTime fixedTime) => Clock(now: () => fixedTime);

  static Clock offset(Duration offset) =>
      Clock(now: () => DateTime.now().add(offset));
}

extension DateTimeExtensions on DateTime {
  String get localDayKey =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  DateTime get startOfLocalDay => DateTime(year, month, day);

  DateTime get startOfNextLocalDay =>
      startOfLocalDay.add(const Duration(days: 1));

  bool isSameLocalDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
