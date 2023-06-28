/// UtilDate
class UtilDate {

  /// differenceInCalendarDays
  static int differenceInCalendarDays(DateTime later, DateTime earlier) {
    later = DateTime.utc(later.year, later.month, later.day);
    earlier = DateTime.utc(earlier.year, earlier.month, earlier.day);

    return later.difference(earlier).inDays;
  }

  /// isOverDays
  static bool isOverDays(DateTime myDate, int addDays) {
    DateTime newDate = myDate.add(Duration(days: addDays));
    var diffDays = UtilDate.differenceInCalendarDays(newDate, myDate);

    if ( diffDays > addDays) {
      return true;
    }

    return false;
  }

  /// isCurrentDate
  static bool isCurrentDate(DateTime aDate) {
    final now = DateTime.now();

    if ((now.year == aDate.year) && (now.month == aDate.month) && (now.day == aDate.day)) {
      return true;
    }

    return false;
  }

}