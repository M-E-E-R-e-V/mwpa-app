class UtilDate {

  static int differenceInCalendarDays(DateTime later, DateTime earlier) {
    later = DateTime.utc(later.year, later.month, later.day);
    earlier = DateTime.utc(earlier.year, earlier.month, earlier.day);

    return later.difference(earlier).inDays;
  }

  static bool isOverDays(DateTime myDate, int addDays) {
    DateTime newDate = myDate.add(Duration(days: addDays));
    var diffDays = UtilDate.differenceInCalendarDays(newDate, myDate);

    if ( diffDays > addDays) {
      return true;
    }

    return false;
  }

}