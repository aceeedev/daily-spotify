/// Returns [true] if [firstDate] and [secondDate] are sequential, meaning that
/// they are adjacent dates on the calendar.
///
/// Note: finding the difference between two dates inDays is not sufficient.
/// [More info](https://stackoverflow.com/a/52713358/12381757)
bool datesAreSequential(DateTime firstDate, DateTime secondDate) {
  DateTime firstDateWithoutTime =
      DateTime(firstDate.year, firstDate.month, firstDate.day);
  DateTime secondDateWithoutTime =
      DateTime(secondDate.year, secondDate.month, secondDate.day);

  return (secondDateWithoutTime.difference(firstDateWithoutTime).inHours / 24)
          .round() ==
      1;
}
