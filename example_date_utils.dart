
DateUtil dateUtil = DateUtil();

bool isToday(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date).inDays;
  return diff == 0 && now.day == date.day;
}

bool isDayOff(List<AvailableTimesForDate> time) {
  bool isDayOff = true;
  time.forEach((element) {
    if (element.timeType == TimeType.AVAILABLE ||
        element.timeType == TimeType.BOOKED ||
        element.timeType == TimeType.BREAK) {
      isDayOff = false;
    }
  });

  return isDayOff;
}

bool isFullyBooked(List<AvailableTimesForDate> time) {
  bool isFullyBooked = false;
  time.forEach((element) {
    if (element.timeType == TimeType.AVAILABLE) {
      isFullyBooked = true;
    }
  });

  return isFullyBooked;
}

List<Day> getDaysOfMonth(int month, int year, List<int> numberedDays) {
  List<Day> days = [];
  numberedDays.forEach((element) {
    Day day = Day();
    day.dayNumber = element;
    day.dayName = DateFormat('EEEE').format(DateTime(year, month, element));
    day.dateTime = DateTime(year, month, element);
    days.add(day);
  });

  return days;
}

String getMonthName(int month) {
  return dateUtil.month(month);
}

DateTime getStartDateDefault() {
  var now = Jiffy();
  return DateTime(now.year, now.month, now.date);
}

DateTime getLastDateDefault() {
  var now = Jiffy()..add(months: 2);
  return DateTime(now.year, now.month);
}

DateTime setToMidnight(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

int getCountFromDiffDate(DateTime firstDate, DateTime lastDate) {
  var yearsDifference = lastDate.year - firstDate.year;
  return 12 * yearsDifference + lastDate.month - firstDate.month;
}

int getDiffMonth(DateTime startDate, DateTime date) {
  return (date.year * 12 + date.month) -
      (startDate.year * 12 + startDate.month);
}
