import 'package:cloud_firestore/cloud_firestore.dart';

Timestamp? dateTimeToTimestamp(DateTime? dateTime) {
  if(dateTime==null) return null;
  return Timestamp.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch);
}

DateTime timestampToDateTime(Timestamp timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
}

extension DayUtils on DateTime {
  /// The UTC date portion of a datetime, without the minutes, seconds, etc.
  DateTime get atMidnight {
    return DateTime.utc(year, month, day);
  }

  /// Checks that the two [DateTime]s share the same date.
  bool isSameDay(DateTime d2) {
    return year == d2.year && month == d2.month && day == d2.day;
  }
}
